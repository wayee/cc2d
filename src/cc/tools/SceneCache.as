package cc.tools
{
	import cc.CCCharacter;
	import cc.CCRender;
	import cc.define.AvatarPartID;
	import cc.define.AvatarPartType;
	import cc.graphics.avatar.CCAvatarPart;
	import cc.vo.avatar.AvatarImgData;
	import cc.vo.avatar.AvatarParamData;
	import cc.vo.avatar.AvatarPlayCondition;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import wit.cache.Cache;
	import wit.handler.HandlerThread;
	import wit.manager.CacheManager;
	import wit.manager.RslLoaderManager;
	import wit.utils.HashMap;

	/**
	 * 场景资源缓存
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class SceneCache
	{
        public static const UNINSTALL_DELAY_TIME:int = 120000;

        private static var LOAD_AVATAR_DELAY:int = 10;
        private static var ADD_AVATAR_DELAY:int = 10;
		
		/**
		 * 地图 
		 */		
        public static var transports:Object = {};			// 可通过块区域: [ mapid_x_y ] = 可通过标志
        public static var mapZones:Object = {};				// [ x_y ] = MapZone, 在 SceneMapLayer.initMapZones 中初始化
        public static var currentMapZones:Object = {};		// 当前可见范围内的 MapZone
		
        public static var mapImgCache:Cache = CacheManager.creatNewCache("mapImgCache");	// [url] = Bitmap
        
		public static var mapTiles:Object = {};				// [ x_y ] = MapTile, x = tx, y = ty
        public static var mapSolids:Object = {};			// [ x_y ] = isSolid
        public static var mapSolids2:Object = {};			// [ x_y ] = Cell
        public static var mapNodes:Array = [];

		/**
		 * 角色 
		 */
		public static var calculatedAstarData:Object = {};
        
		public static var waitingLoadAvatarHT:HandlerThread = new HandlerThread();
		public static var waitingLoadAvatarFun:Object = new Object();
        public static var waitingLoadAvatars:Object = new Object();
		
        public static var waitingAddAvatarHT:HandlerThread = new HandlerThread();
        public static var waitingAddAvatars:Array = [];
		
        public static var avatarXmlCache:Cache = CacheManager.creatNewCache("avatarXmlCache");	// xml 信息的缓存, key=sourcePath, value={data:apsRes}, 其中 apsRes={type->AvatarPartStatus}
        public static var avatarImgCache:Cache = CacheManager.creatNewCache("avatarImgCache");
        public static var waitingRemoveAvatarImgs:Object = {};
        private static var count:int = 0;
		
		public static var spCollections:Dictionary = new Dictionary;	// 角色形象单帧数据集合
		
		public static var currentMapCharacters:Object = {};		// {mapId:[SceneCharacter, ...], ...}
		
		/**
		 * 法术 
		 */
		public static var effects:HashMap = new HashMap;
		public static var effectPool:HashMap = new HashMap;
		
		/**
		 * 纸娃娃 
		 */
		public static var avatars:HashMap = new HashMap;
		public static var avatarPool:HashMap = new HashMap;

//        public static function getMapSolids2(x:int, y:int):Cell{
//            return ((mapSolids2[((x + "_") + y)] as Cell));
//        }
		
		/**
		 * 添加加载角色等待队列
		 * <br> 等待加载的队列
		 */
        public static function addWaitingLoadAvatar(sceneChar:CCCharacter, 
													avatarParamData:AvatarParamData, 
													loadSource:Function=null):void {
            var exists:Boolean;
            var avatarData:Array;
            if (loadSource != null) {
                waitingLoadAvatarFun[avatarParamData.sourcePath] = loadSource;
                waitingLoadAvatarHT.push(loadSource, null, LOAD_AVATAR_DELAY);
//				trace('[ScaneCache.addWaitingLoadAvatar 444]', avatarParamData.sourcePath);
            }
            var avatarDataArr:Array = waitingLoadAvatars[avatarParamData.sourcePath]; // 每个角色都有多个数据，如站立，跑步，攻击和受伤等等
            if (avatarDataArr == null) {
                waitingLoadAvatars[avatarParamData.sourcePath] = [[sceneChar, avatarParamData]];
            } else {
				// 如果存在就不用加入了
                for each (avatarData in avatarDataArr) {
                    if (sceneChar == avatarData[0] && sceneChar.id == avatarData[0].id 
						&& avatarParamData.sourcePath == avatarData[1].sourcePath) {
						exists = true;
                        break;
                    }
                }
				
                if (!exists) {
                    waitingLoadAvatars[avatarParamData.sourcePath].push([sceneChar, avatarParamData]);
                } else {
//					trace('[ScaneCache.addWaitingLoadAvatar 555]', avatarParamData.sourcePath);
				}
            }
        }
		
		/**
		 * 添加等待加入角色队列 
		 * <br> 角色对象加载完成，等待加入显示
		 * 
		 * @param sceneChar
		 * @param avatarParamData
		 * @param avatarParamDataRes Object see SceneCache.avatarXmlCache.get(paramData.sourcePath).data
		 * 
		 */
        public static function addWaitingAddAvatar(sceneChar:CCCharacter, 
												   avatarParamData:AvatarParamData, 
												   avatarParamDataRes:Object):void {
            var arr:Array = null;
            var ht_addAvatarPart:Function = null;
			
            ht_addAvatarPart = function ():void {
                var index:int = waitingAddAvatars.indexOf(arr);
                if (index != -1) {
                    waitingAddAvatars.splice(index, 1);
                }
				// 角色加入显示列表
                addAvatarPart(sceneChar, avatarParamData, avatarParamDataRes);
            }
            arr = [sceneChar, avatarParamData, ht_addAvatarPart];
            waitingAddAvatars.push(arr);
            waitingAddAvatarHT.push(ht_addAvatarPart, null, ADD_AVATAR_DELAY);
        }
		
		
		/**
		 * 删除正在等待的角色 
		 * @param sceneChar
		 * @param avatarPartID
		 * @param avatarPartType
		 * @param except_char_arr
		 * 
		 */
        public static function removeWaitingAvatar(sceneChar:CCCharacter=null, 
												   avatarPartID:String=null, 
												   avatarPartType:String=null, 
												   except_char_arr:Array=null):void {
            var removeLoadFun:Function = function(sourcePath:String):void
			{
                var loadSource:Function = waitingLoadAvatarFun[apd.sourcePath];
                if (loadSource != null) {
                    waitingLoadAvatarHT.removeHandler(loadSource);
                }
            };
			
            var watingArrKey:String = null;
            var watingArr:Array = null;
            var newWatingArr:Array = null;
            var arr:Array = null;
            var sc:CCCharacter = null;
            var apd:AvatarParamData = null;
			// watingArrKey => avatarParamData.sourcePath
			// watingArr => [[sceneChar, avatarParamData], ...];
            for (watingArrKey in waitingLoadAvatars) {
                watingArr = waitingLoadAvatars[watingArrKey];
                if (watingArr != null && watingArr.length > 0) {
                    newWatingArr = [];
                    for each (arr in watingArr) {
                        sc = arr[0];
                        apd = arr[1];
						if ((AvatarPartID.IsDefaultKey(apd.Id) || (except_char_arr != null && except_char_arr.indexOf(sc) != -1))
							|| !(((sceneChar == null || (sc == sceneChar && sc.id == sceneChar.id)) && (avatarPartID == null || 
								apd.Id == avatarPartID)) && (avatarPartType == null || (apd.avatarPartType == avatarPartType)))) {
                            newWatingArr.push(arr);
                        } else {
                            apd.executeCallBack(sceneChar);
                        }
                    }
					
                    if (newWatingArr.length > 0) {
                        waitingLoadAvatars[watingArrKey] = newWatingArr;
                    } else {
                        delete waitingLoadAvatars[watingArrKey];
                        removeLoadFun(watingArrKey);
                    }
                } else { // 没有可加载的数据，直接清楚数据及其handler(loadSource())
                    delete waitingLoadAvatars[watingArrKey];
                    removeLoadFun(watingArrKey);
                }
            }
			
			var arr1:Array = null;
			var len:int = waitingAddAvatars.length;
			var sc1:CCCharacter = null;
			var addFun:Function = null;
			var apd1:AvatarParamData = null;
			
            while (len > 0) {
				len = len -1;
                arr1 = waitingAddAvatars[len]; // [sceneChar, avatarParamData, ht_addAvatarPart]
                
				sc1 = arr1[0];
                apd1 = arr1[1];
                addFun = arr1[2];
                
				if ((except_char_arr != null && except_char_arr.indexOf(sc1) != -1) || 
					!(((sceneChar == null || (sc1 == sceneChar && sc1.id == sceneChar.id)) && (avatarPartID == null || 
						apd1.Id == avatarPartID)) && (avatarPartType == null || (apd1.avatarPartType == avatarPartType)))) {
                } else {
                    waitingAddAvatars.splice(len, 1);
                    waitingAddAvatarHT.removeHandler(addFun);
                }
            }
        }
		
		/**
		 * 添加队列中的部件
		 * @param sourcePath
		 * @param avatarParamDataRes Object see SceneCache.avatarXmlCache.get(paramData.sourcePath).data
		 * 
		 */
        public static function dowithWaiting(sourcePath:String, avatarParamDataRes:Object=null):void {
            var arr:Array;
            var sceneChar:CCCharacter;
            var avatarParamData:AvatarParamData;
            var unitArr:Array;
            if (avatarParamDataRes != null) {
                arr = waitingLoadAvatars[sourcePath];
                if (arr != null && arr.length > 0) {
                    for each (unitArr in arr) {
                        sceneChar = unitArr[0];
                        avatarParamData = unitArr[1];
                        addWaitingAddAvatar(sceneChar, avatarParamData, avatarParamDataRes);
                    }
                }
            }
//			trace('[ScaneCache.dowithWaiting]', sourcePath + ' ' + arr.length + ' times');
            delete waitingLoadAvatars[sourcePath];
        }
		
		/**
		 * 添加部件 
		 * @param sceneChar
		 * @param avatarParamData
		 * @param avatarParamDataRes
		 * 
		 */		
        private static function addAvatarPart(sceneChar:CCCharacter, avatarParamData:AvatarParamData, avatarParamDataRes:Object):void {
            if (sceneChar == null || !sceneChar.usable) {
                avatarParamData.executeCallBack(sceneChar);
                return;
            }
			
            if (avatarParamData.useType == 1) {
                avatarParamData.executeCallBack(sceneChar);
                return;
            }
            if (avatarParamData.avatarPartType == AvatarPartType.BODY) {
                if (avatarParamData.Id == AvatarPartID.BLANK) {
                    if (sceneChar.hasTypeAvatarParts(AvatarPartType.BODY)) {
                        avatarParamData.executeCallBack(sceneChar);
                        return;
                    }
                } else {
                    sceneChar.removeAvatarPartByID(AvatarPartID.BLANK, false);
                }
            }
			
            var part:CCAvatarPart = CCAvatarPart.createAvatarPart(avatarParamData.Id, avatarParamData.avatarPartType, avatarParamData.depth, avatarParamData.useType, avatarParamDataRes, avatarParamData.vars);
            part.avatarParamData = avatarParamData.clone();
            part.isBlank = (avatarParamData.Id == AvatarPartID.BLANK);
			
            var avatarPlayCondition:AvatarPlayCondition = sceneChar.avatar.playCondition;
            if (avatarPlayCondition != null) {
                avatarPlayCondition = avatarPlayCondition.clone();
            }
            sceneChar.addAvatarPart(part, avatarParamData.clearSameType);
            if (sceneChar.usable) {
                part.playTo(sceneChar.avatar.status, sceneChar.avatar.logicAngle, avatarParamData.rotation, avatarPlayCondition);
            }
        }
		
		/**
		 * 每 1000 帧检查1次(30秒), 当资源超过2分钟没有使用, 则释放它
		 */
        public static function checkUninstall():void {
            var name:String;
            if (++count < 1000) {		// 1000 次检查一次
                return;
            }
            count = (count % 1000);
            var nowTime:int = CCRender.nowTime;
            for (name in waitingRemoveAvatarImgs) {
                if ((nowTime - waitingRemoveAvatarImgs[name]) > UNINSTALL_DELAY_TIME) {	//  > 120 秒
                    doUninstallAvatarImg(name);				//删除对象
                    waitingRemoveAvatarImgs[name] = null;
                    delete waitingRemoveAvatarImgs[name];
                }
            }
        }
		
		/**
		 * 释放资源, 减少引用技术, 如果<=0则记录到释放队列中
		 */
        public static function uninstallAvatarImg(name:String):void {
            var avatarImgData:AvatarImgData;
            if (avatarImgCache.has(name)) {
                avatarImgData = avatarImgCache.get(name) as AvatarImgData;
                avatarImgData.useNum = avatarImgData.useNum - 1;		// 减少引用计数
                if (avatarImgData.useNum <= 0) {
                    if ( !waitingRemoveAvatarImgs.hasOwnProperty(name) ) {
                        waitingRemoveAvatarImgs[name] = CCRender.nowTime;	// 记录当前时间
                    }
                }
            }
        }
		
		/**
		 * 删除对象, 执行删除动作
		 */
        private static function doUninstallAvatarImg(name:String):void {
            var data:AvatarImgData;
            if (avatarImgCache.has(name)) {
                data = avatarImgCache.get(name) as AvatarImgData;
                if (data.useNum <= 0) {
                    data.dir07654.dispose();
                    data.dir07654 = null;
                    if (data.dir123 != null){
                        data.dir123.dispose();
                        data.dir123 = null;
                    }
                    avatarImgCache.remove(name);
                }
            }
        }
		
		/**
		 * 检索1个资源, 新建, 或复用, 增加引用计数，获取镜像
		 * @param name 资源类名
		 */
        public static function installAvatarImg(name:String, only1LogicAngel:Boolean):AvatarImgData {
            var avatarImgData:AvatarImgData;
            var bm0:BitmapData;
            var bm1:BitmapData;
            var width:Number;
            var height:Number;
            var matrix:Matrix;
            var bm2:BitmapData;
			
			// 资源不存在, 新建
            if (!avatarImgCache.has(name)) {
                bm0 = RslLoaderManager.getInstance(name, 100, 100) as BitmapData;
                if (bm0 != null){
                    width = bm0.width;
                    height = bm0.height;
                    if (!only1LogicAngel) {
                        bm1 = new BitmapData(width, ((height * 3) / 5), true, 0);	// 镜像的高度 = 正向的3/5，就是中间的三个方向做镜像
                        bm1.copyPixels(bm0, new Rectangle(0, (height / 5), width, ((height * 3) / 5)), new Point(0, 0));
                    } else {
	                    bm1 = new BitmapData(width, height, true, 0);
	                    bm1.copyPixels(bm0, new Rectangle(0, 0, width, height), new Point(0, 0));
					}
                    matrix = new Matrix();
                    matrix.scale(-1, 1);
                    matrix.translate(bm1.width, 0);
                    bm2 = new BitmapData(bm1.width, bm1.height, true, 0);
                    bm2.draw(bm1, matrix);
                    bm1 = bm2;
					
                    avatarImgData = new AvatarImgData(bm0, bm1, 1);	// 2个镜像的图片
                    avatarImgCache.push(avatarImgData, name);
                }
            }
			// 已经存在, 增加引用计数
			else {
                avatarImgData = avatarImgCache.get(name) as AvatarImgData;
                avatarImgData.useNum = avatarImgData.useNum + 1;
            }
			
			// 从删除队列中清空
            if (waitingRemoveAvatarImgs.hasOwnProperty(name)) {
                waitingRemoveAvatarImgs[name] = null;
                delete waitingRemoveAvatarImgs[name];
            }
            return avatarImgData;
        }
    }
}