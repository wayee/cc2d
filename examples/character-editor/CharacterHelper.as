package
{
	import cc.tools.SceneCache;
	import cc.vo.avatar.AvatarParamData;
	import cc.vo.avatar.AvatarPartStatus;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	import wit.handler.HandlerThread;
	import wit.loader.LoadData;
	import wit.loader.RslLoader;
	import wit.manager.RslLoaderManager;
	import cc.ext.CCSpriteSheet;

	/**
	 * 场景对象助手
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class CharacterHelper
	{
		/**
		 * 获取角色对象 
		 */
		public static function getAvatar(path:String, callback:Function=null, errCallback:Function=null, angle:int=0, status:String='stand', data:Object=null):void
		{
			loadAvatar(path, callback, errCallback, angle, status, data);
		}
		
		public static function loadAvatar(path:String, callback:Function=null, errCallback:Function=null, angle:int=0, status:String='stand', data:Object=null):void
		{
			var loadComplete:Function = function(apsRes:Object):void	// apsRes = {type:new AvatarPartStatus, ...}
			{
				if (apsRes == null) return;
				var standAps:AvatarPartStatus = apsRes[status];
				
				var spriteSheet:CCSpriteSheet = new CCSpriteSheet(status, apsRes, angle);
				spriteSheet.data = data;
				if (callback != null) {
					callback(spriteSheet);
				}
			};
			
			var loadError:Function = function(apsRes:Object):void	// apsRes = {type:new AvatarPartStatus, ...}
			{
				if (errCallback != null) errCallback();
			};
			
			var avatarParamData:AvatarParamData = new AvatarParamData(path);
			loadAvatarPart(avatarParamData, loadComplete, loadError);
		}

		private static var waitingLoadAvatars:Object = new Object;
		private static var waitingLoadAvatarHT:HandlerThread = new HandlerThread();
		private static var LOAD_AVATAR_DELAY:int = 10;
		public static function addWaitingLoadAvatar(avatarParamData:AvatarParamData, callback:Function, loadSource:Function=null):void
		{
			var exists:Boolean;
			var avatarData:Array;
			
			if (loadSource != null) {
				waitingLoadAvatarHT.push(loadSource, null, LOAD_AVATAR_DELAY);
			}
			
			var avatarDataArr:Array = waitingLoadAvatars[avatarParamData.sourcePath];
			if (avatarDataArr == null) {
				waitingLoadAvatars[avatarParamData.sourcePath] = [[avatarParamData, callback]];
			} else {
				for each (avatarData in avatarDataArr) {
					if (callback == avatarData[1] && avatarParamData.sourcePath == avatarData[0].sourcePath) {
						exists = true;
						break;
					}
				}
				if (!exists) {
					waitingLoadAvatars[avatarParamData.sourcePath].push([avatarParamData, callback]);
				}
			}
		}
		
		public static function dowithWaiting(sourcePath:String, avatarParamDataRes:Object):void
		{
			var arr:Array;
			var callback:Function;
			var unit:Array;
			if (avatarParamDataRes != null) {
				arr = waitingLoadAvatars[sourcePath];
				if (arr != null && arr.length > 0) {
					for each (unit in arr) {
						callback = unit[1];
						if (callback != null) callback(avatarParamDataRes);
					}
				}
			}
			delete waitingLoadAvatars[sourcePath];
		}
		
		/**
		 * 加载资源
		 * 
		 * callback(apsRes:Object) 
		 */
		public static function loadAvatarResource(path:String, callback:Function, errCallback:Function=null ,progressCallback:Function = null):void
		{
			var avatarParamData:AvatarParamData = new AvatarParamData(path);
			loadAvatarPart(avatarParamData, callback, errCallback, progressCallback);
		}

		/**
		 * 加载角色对象 
		 * 
		 */
		public static function loadAvatarPart(avatarParamData:AvatarParamData=null, callback:Function=null, errCallback:Function=null,progressCallback:Function = null):void
		{
			var apsRes:Object = null;
			var aps:AvatarPartStatus = null;
			var tryLoadCount:int = 0;
			var paramData:AvatarParamData = avatarParamData;
			paramData = avatarParamData != null ? avatarParamData.clone() : new AvatarParamData;
			
			// 如果没有该 URL 路径, 则新建加载
			if ( !SceneCache.avatarXmlCache.has(paramData.sourcePath) ) {
				
				//定义加载中进度
				var progressHandler:Function = function(loadData:LoadData, e:ProgressEvent):void
				{
					if(progressCallback != null){
						progressCallback(e.bytesLoaded, e.bytesTotal);
					}
				}
					
				// 定义加载操作, 设置解密函数(LoadData decode 参数), 执行加载
				var loadSource:Function = function():void
				{
					var loadData:LoadData = new LoadData(paramData.sourcePath, loadSourceComplete, progressHandler, loadError, "", "", RslLoader.TARGET_SAME, 0);
					RslLoaderManager.load([loadData]);
				};
				
				// 定义 加载完成
				var loadSourceComplete:Function = function(loadData:LoadData, e:Event):void
				{
					var avatarXMLData:XML;
					var avatarXMLPartData:XML;
					var classRef:Class = RslLoaderManager.getClass(paramData.className);		// 获得类型名
					if (classRef != null){
						// avatarXMLData = X_M_L 是个 XML 内容, SWF 中定义该常量, 表示了该 部位的信息。好处是一次加载数据和动画
						// 另一个想法：可以分离xml到单独的xml文件，登录时全部加载，考虑数据量大小
						avatarXMLData = RslLoaderManager.getClass(paramData.className).X_M_L as XML;		
						apsRes = {};							// [动画类型] = AvatarPartStatus/动作定义 
						for each (avatarXMLPartData in avatarXMLData.children()) {
							aps = new AvatarPartStatus();		// 动画定义
							aps.type = avatarXMLPartData.@type;
							aps.frame = avatarXMLPartData.@frame;
							aps.delay = avatarXMLPartData.@time;		// 延时
							aps.repeat = avatarXMLPartData.@repeat;
							aps.width = avatarXMLPartData.@width;
							aps.height = avatarXMLPartData.@height;
							aps.tx = avatarXMLPartData.@tx;
							aps.ty = avatarXMLPartData.@ty;
							aps.mx = avatarXMLPartData.@mx;
							aps.my = avatarXMLPartData.@my;
							aps.wx = avatarXMLPartData.@wx;
							aps.wy = avatarXMLPartData.@wy;
							aps.only1Angle = avatarXMLPartData.@only1Angel;
							aps.classNamePrefix = (paramData.className + ".");
							apsRes[aps.type] = aps;
						}
						
						// 保存到 SceneCache.avatarXmlCache 中 
						if (SceneCache.avatarXmlCache.has(paramData.sourcePath)) {
							SceneCache.avatarXmlCache.get(paramData.sourcePath).data = apsRes;
						} else {
							SceneCache.avatarXmlCache.push({data:apsRes}, paramData.sourcePath);
						}
						
						dowithWaiting(paramData.sourcePath, apsRes);
						
					} else {
						loadError(null, null, false);
					}
				};
				
				// 定义加载失败
				var loadError:Function = function(errorLoadData:LoadData=null, event:Event=null, b:Boolean=true):void
				{
					var stop:Boolean;
					if (b){
						tryLoadCount++;
						if (tryLoadCount < 3) {
							stop = false;
							loadSource();
						} else {
							stop = true;
						}
					}
					if (stop) {
						if (SceneCache.avatarXmlCache.has(paramData.sourcePath)){
							SceneCache.avatarXmlCache.remove(paramData.sourcePath);
						}
						if (errCallback != null) errCallback(null);
					}
				};
				
				SceneCache.avatarXmlCache.push({data:null}, paramData.sourcePath);
				addWaitingLoadAvatar(avatarParamData, callback, loadSource);
				tryLoadCount = 0;
					
			} else { // 已经有缓存了, 则从缓存中获取
				apsRes = SceneCache.avatarXmlCache.get(paramData.sourcePath).data;
				if (apsRes == null) {
					addWaitingLoadAvatar(paramData.clone(), callback);
				} else {
					if (callback != null) {
						callback(apsRes);
					}
				}
			}
		}
	}
}