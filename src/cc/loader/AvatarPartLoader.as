package cc.loader
{
	import flash.events.Event;
	
	import cc.CCCharacter;
	import cc.tools.SceneCache;
	import cc.vo.avatar.AvatarParamData;
	import cc.vo.avatar.AvatarPartStatus;
	import wit.loader.LoadData;
	import wit.loader.RslLoader;
	import wit.manager.RslLoaderManager;

    public class AvatarPartLoader
	{
		/**
		 * 加载部件数据
		 */
        public static function loadAvatarPart(sceneChar:CCCharacter, avatarParamData:AvatarParamData=null):void {
            var apsRes:Object = null;
            var aps:AvatarPartStatus = null;
            var tryLoadCount:int = 0;
            var loadSourceComplete:Function = null;
            var loadError:Function = null;
			
            var paramData:AvatarParamData = avatarParamData;			// avatar part data
            paramData = avatarParamData !=null ? avatarParamData.clone() : new AvatarParamData();
//			trace('[AvatarPartLoader.loadAvatarPart 111]', 'load ' + paramData.sourcePath, 'paramData.clearSameType:'+paramData.clearSameType, ' sceneChar:'+sceneChar, 'sceneChar.usable:'+sceneChar.usable);
//			trace('[AvatarPartLoader.loadAvatarPart 111]', 'load ' + paramData.sourcePath);
			
            if (sceneChar != null && sceneChar.usable && paramData.sourcePath != null && paramData.sourcePath != "") {
				// 删除正在加载的同类数据
                if (paramData.clearSameType) {
                    SceneCache.RemoveWaitingAvatar(sceneChar, null, paramData.avatarPartType);
                }
				
				// 如果没有该 URL 路径, 则新建加载
                if ( !SceneCache.avatarXmlCache.has(paramData.sourcePath) ) {
					
					// 定义加载操作, 设置解密函数(LoadData decode 参数), 执行加载
                    var loadSource:Function = function():void
					{
//						trace('[AvatarPartLoader.loadAvatarPart 222]', 'load ' + paramData.sourcePath);
                        var loadData:LoadData = new LoadData(paramData.sourcePath, null, null, loadError, "", "", RslLoader.TARGET_SAME, 0);
                        RslLoaderManager.load([loadData], loadSourceComplete);
                    }
					// 定义 加载完成
                    loadSourceComplete = function():void
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
                                aps.delay = avatarXMLPartData.@time;					// 每帧播放时间（毫秒）
                                aps.repeat = avatarXMLPartData.@repeat;
                                aps.width = avatarXMLPartData.@width;
                                aps.height = avatarXMLPartData.@height;
                                aps.tx = avatarXMLPartData.@tx;
                                aps.ty = avatarXMLPartData.@ty;
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
                            SceneCache.DowithWaiting(paramData.sourcePath, apsRes);
                        } else {
                            loadError(null, null, false);
                        }
                    };
					// 定义加载失败
                    loadError = function(errorLoadData:LoadData=null, event:Event=null, b:Boolean=true):void
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
                            SceneCache.DowithWaiting(paramData.sourcePath, null);
                            paramData.executeCallBack(sceneChar);
                        }
                    };
					
					// 添加等待队列, 然后调用  loadSource 被加载
					// addWaitingLoadAvatar 
					// addWaitingAddAvatar 
                    SceneCache.avatarXmlCache.push({data:null}, paramData.sourcePath);
                    SceneCache.AddWaitingLoadAvatar(sceneChar, paramData, loadSource);
                    tryLoadCount = 0;
                }
				// 已经有缓存了, 则从缓存中获取
				else {
                    apsRes = SceneCache.avatarXmlCache.get(paramData.sourcePath).data;
                    if (apsRes == null) {
                        SceneCache.AddWaitingLoadAvatar(sceneChar, paramData.clone());
//						trace('[AvatarPartLoader.loadAvatarPart 333]', 'exec SceneCache.addWaitingLoadAvatar ' + paramData.sourcePath, SceneCache.waitingLoadAvatars[paramData.sourcePath].length);
                    } else {
                        SceneCache.AddWaitingAddAvatar(sceneChar, paramData.clone(), apsRes);
//						trace('[AvatarPartLoader.loadAvatarPart 333]', 'exec SceneCache.addWaitingAddAvatar ' + paramData.sourcePath);
                    }
                }
            }
			// 播放每一帧
			else {
                paramData.executeCallBack(sceneChar, null, true, true, true, true, true, true, 0, 0, 0, 0, 0, 0);
            }
        }
    }
}