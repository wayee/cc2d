package cc.graphics.layers
{
	import cc.CCScene;
	import cc.tools.SceneCache;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	
	import wit.loader.LoadData;
	import wit.utils.Fun;

    public class SceneSingleMapLayer extends Sprite
	{
        private var scene:CCScene;						// 当前场景
        private var _currentCameraPos:Point;			// 当前视区/地图位置
        private var _waitingLoadDatas:Object;			// 等待加载的列表, [key] = LoadData
		private var _currentMap:Bitmap;
		
        public function SceneSingleMapLayer(p_scene:CCScene) {
            super();
            _currentCameraPos = new Point(int.MAX_VALUE, int.MAX_VALUE);
            _waitingLoadDatas = {};
            scene = p_scene;
            mouseEnabled = false;
            mouseChildren = false;
        }
		
        public function Dispose():void {
            Fun.clearChildren(this, false, false);
            _currentCameraPos = new Point(int.MAX_VALUE, int.MAX_VALUE);
//            _currentMapZone = null;
            _waitingLoadDatas = {};
        }
		
        public function InitMapZones():void {
			loadMap();
        }
		
        public function Run():void {
			// 如果坐标未变更, 则不更新
            if (_currentCameraPos.x == scene.sceneCamera.PixelX && _currentCameraPos.y == scene.sceneCamera.PixelY) {
                return;
            }
			
			// 跟随当前视区, 计算地图位置
            _currentCameraPos.x = scene.sceneCamera.PixelX;
            _currentCameraPos.y = scene.sceneCamera.PixelY;
        }
		
        private function loadMap():void {
			var filePath:String = scene.mapConfig.mapUrl;
			var loadData:LoadData = null;
			
			// 如果地图已经缓存过，直接使用
			if (SceneCache.MapImgCache.has(filePath)) {
				_currentMap = SceneCache.MapImgCache.get(filePath) as Bitmap;
				addChild(_currentMap);
			} else {
				// 加载完成
				var itemLoadComplete:Function = function (event:Event):void {
					_currentMap = event.target.content as Bitmap;
					SceneCache.mapImgCache.push(_currentMap, (event.currentTarget as LoaderInfo).url);	// 加入缓存
					addChild(_currentMap);
				};
				
				// 加载错误
				var itemLoadError:Function = function (event:Event):void {
					loadData.userData.retry++;		// 增加重试次数
					if (loadData.userData.retry > 3){
//						ZLog.add((("######尝试加载地图" + filePath) + "3次均失败，已经放弃加载"));
					} else {
						loadData.userData.loader.load(new URLRequest(filePath));	// 继续加载
					}
				};
				
				// 构造 LoadData
				loadData = new LoadData(filePath, itemLoadComplete, null, itemLoadError, "", filePath);
				loadData.userData = {
					loader:new Loader(),
					retry:0
				}
				loadData.userData.loader.load(new URLRequest(filePath));
				loadData.userData.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadData.onComplete);
				loadData.userData.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadData.onError);
				loadData.userData.loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadData.onError);
			}
        }
    }
}