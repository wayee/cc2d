package cc.graphics.layers
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	
	import cc.CCScene;
	import cc.tools.SceneCache;
	import wit.loader.LoadData;
	import wit.utils.Fun;

	/**
	 * 地图背景
	 * 
	 * <li>单背景图，无需分块显示
	 * <b>背景图加载流程</b>
	 * <li> 加载背景图, 保存到 SceneCache.mapImgCache
	 * <li> 该缓存只被 SceneSingleMapLayer 使用
	 */
    public class SceneSingleMapLayer extends Sprite
	{
        private var _scene:CCScene;						// 当前场景
        private var _currentCameraPos:Point;			// 当前视区/地图位置
        private var _waitingLoadDatas:Object;			// 等待加载的列表, [key] = LoadData
		private var _currentMap:Bitmap;
		
        public function SceneSingleMapLayer(scene:CCScene)
		{
            super();
            _currentCameraPos = new Point(int.MAX_VALUE, int.MAX_VALUE);
            _waitingLoadDatas = {};
            _scene = scene;
            mouseEnabled = false;
            mouseChildren = false;
        }
		
        public function dispose():void
		{
            Fun.clearChildren(this, false, false);
            _currentCameraPos = new Point(int.MAX_VALUE, int.MAX_VALUE);
//            _currentMapZone = null;
            _waitingLoadDatas = {};
        }
		
        public function initMap():void
		{
			loadMap();
        }
		
		/**
		 * 更新地图位置
		 */
        public function run():void
		{
			// 如果坐标未变更, 则不更新
            if (_currentCameraPos.x == _scene.sceneCamera.PixelX && _currentCameraPos.y == _scene.sceneCamera.PixelY) {
                return;
            }
			
			// 跟随当前视区, 计算地图位置
            _currentCameraPos.x = _scene.sceneCamera.PixelX;
            _currentCameraPos.y = _scene.sceneCamera.PixelY;
			
        }
		
		/**
		 * 加载地图
		 */
        private function loadMap():void
		{
			var filePath:String = _scene.mapConfig.mapUrl;
			var loadData:LoadData = null;
			
			// 如果地图已经缓存过，直接使用
			if (SceneCache.mapImgCache.has(filePath)) {
				_currentMap = SceneCache.mapImgCache.get(filePath) as Bitmap;
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