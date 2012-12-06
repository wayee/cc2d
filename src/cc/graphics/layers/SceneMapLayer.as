package cc.graphics.layers
{
	import cc.CCScene;
	import cc.tools.SceneCache;
	import cc.utils.SceneUtil;
	import cc.utils.Transformer;
	import cc.vo.map.MapZone;
	import cc.vo.map.SceneInfo;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	
	import wit.handler.HandlerThread;
	import wit.loader.LoadData;
	import wit.loader.RslLoader;
	import wit.log.Log4J;
	import wit.utils.Fun;
	import wit.utils.ZMath;
	
	public class SceneMapLayer extends Sprite
	{
		private static const MAX_ZONE_CACHE_X:int = 3;
		private static const MAX_ZONE_CACHE_Y:int = 2;
		
		private var scene:CCScene;						// 当前场景
		private var currentMapPos:Point;			// 当前视区/地图位置
		private var currentMapZone:MapZone;			// 当前左上角位置的 zone
		private var waitingLoadData:Object;			// 等待加载的列表, [key] = LoadData
		
		public function SceneMapLayer(p_scene:CCScene) {
			super();
			this.currentMapPos = new Point(int.MAX_VALUE, int.MAX_VALUE);
			this.waitingLoadData = {};
			this.scene = p_scene;
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		public function Dispose():void {
			Fun.clearChildren(this, false, false);
			this.currentMapPos = new Point(int.MAX_VALUE, int.MAX_VALUE);
			this.currentMapZone = null;
			this.waitingLoadData = {};
		}
		
		/**
		 * @from Scene.switchScene
		 */
		public function InitMapZones():void {
			var map:Object = {};
			var zone_x:int;
			var zone_y:int;
			var zone:MapZone;
			var zone_width:int = (this.scene.mapConfig.mapGridX / SceneInfo.ZONE_SCALE);		// 族宽度
			var zone_height:int = (this.scene.mapConfig.mapGridY / SceneInfo.ZONE_SCALE);		// 族高度
			
			zone_x = 0;
			while (zone_x < zone_width) {
				zone_y = 0;
				while (zone_y < zone_height) {
					zone = new MapZone(this);		// 新建地图族, zone.showContainer (ShowContainer)被添加到自己的孩子中
					zone.tileWidth = SceneInfo.ZONE_WIDTH;		// 设置 块 尺寸		// 在这里, 1块实际上为1区
					zone.tileHeight = SceneInfo.ZONE_HEIGHT;
					zone.TileX = zone_x;							// 块坐标
					zone.TileY = zone_y;
					zone.showContainer.x = zone.PixelX;			// 像素尺寸
					zone.showContainer.y = zone.PixelY;
					map[((zone_x + "_") + zone_y)] = zone;		// [ x_y ] = MapZone
					zone_y++;
				}
				zone_x++;
			}
            SceneCache.MapZones = map;
		}
		
		public function Run():void {
			// 如果坐标未变更, 则不更新
			if (this.currentMapPos.x == this.scene.sceneCamera.PixelX && 
				this.currentMapPos.y == this.scene.sceneCamera.PixelY) {
				return;
			}
			
			// 跟随当前视野, 计算地图位置
			this.currentMapPos.x = this.scene.sceneCamera.PixelX;
			this.currentMapPos.y = this.scene.sceneCamera.PixelY;
			
			this.loadMap();
		}
		
		private function loadMap():void {
			var currentZone:MapZone;
			var loadDataList:Array;
			var loadData:LoadData;
			var distance:int;
			var point_list:Array;
			var zone_width:int;
			var zone_height:int;
			var point:Point;
			var key:String;
			var thread:HandlerThread;
			var loader:Loader;
			var currentZones:Object = {};
			
			// 根据当前视区, 取得当前左上角的 zone 对象
			var tile_pos:Point = Transformer.TransPixelPoint2TilePoint(new Point(this.scene.sceneCamera.PixelX, this.scene.sceneCamera.PixelY));
			var zone_pos:Point = Transformer.TransTilePoint2ZonePoint(tile_pos);
			var zone:MapZone = SceneCache.MapZones[(zone_pos.x + "_" + zone_pos.y)];
			if (!zone) {
				return;
			}
			
			// 如果 zone 变更, 则进行加载处理
			if (this.currentMapZone != zone) {
				// 搜索视区内的所有块 point_list
				point_list = SceneUtil.FindViewZonePoints(new Point(zone.TileX, zone.TileY), this.scene.sceneCamera.ZoneRangeXY.x, this.scene.sceneCamera.ZoneRangeXY.y);
				zone_width = (this.scene.mapConfig.mapGridX / SceneInfo.ZONE_SCALE);		// 地图 zone 尺寸
				zone_height = (this.scene.mapConfig.mapGridY / SceneInfo.ZONE_SCALE);
				loadDataList = [];
				for each (point in point_list) {
					if (point.x < 0 || point.x >= zone_width || point.y < 0 || point.y >= zone_height) {
						// pass
					} else {
						key = ((point.x + "_") + point.y);					// key
						currentZone = SceneCache.InViewMapZones[key];		// zone = currentMapZones
						// 如果 currentMapZones 为空, 则从 mapZones 中获取
						if (currentZone == null) {
							currentZone = SceneCache.MapZones[key];			// zone = mapZones
							currentZones[key] = currentZone;				// save to currentZones
						}
						// 否则如果 currentMapZones 非空, 则删除 currentMapZones
						else {
							currentZones[key] = currentZone;
							SceneCache.InViewMapZones[key] = null;		// 删除该位置
							delete SceneCache.InViewMapZones[key];
						}
						// 结果: currentZones[ key ] = currentZone; 
						
						// 如果没有在等待队列中, 则添加到等待队列
						if (this.waitingLoadData[key] == null) {		// 如果某个图片加载失败, 则会被重复添加
							// 计算 _loccurrentZoneone 的距离
							distance = -(Math.round(ZMath.getDistanceSquare(currentZone.PixelX, currentZone.PixelY, zone.PixelX, zone.PixelY)));
							loadData = this.addMapZone(currentZone, distance);		// 添加
							if (loadData) {
								loadDataList.push(loadData);
								this.waitingLoadData[key] = loadData;
							}
						}
					}
				}
				
				// 遍历等待队列, 按优先级排列, 然后放到 thread 中去执行
				if (loadDataList.length > 0) {
					loadDataList.sortOn(["priority"], [(Array.NUMERIC | Array.DESCENDING)]);
					thread = new HandlerThread();
					for each (loadData in loadDataList) {
						loader = loadData.userData.loader;
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadData.onComplete);
						loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadData.onError);
						loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadData.onError);
						thread.push(loader.load, [new URLRequest(loadData.url)], 10);	// 等待10毫秒后运行
					}
				}
				
				// 删除 currentMapZones 中的 zone, 所以这里是 视野外的 zone
				var inViewZones:Object = SceneCache.InViewMapZones;
				for (key in SceneCache.InViewMapZones) {
					currentZone = SceneCache.InViewMapZones[key];
					
					// 从孩子中删除  showContainer
					if (this.contains(currentZone.showContainer)){
						this.removeChild(currentZone.showContainer);		// 超出视野的 zone 被删除
					}
					
					// 删除缓存
					if (Math.abs(currentZone.TileX - zone.TileX) > (this.scene.sceneCamera.ZoneRangeXY.x + MAX_ZONE_CACHE_X) 
						|| Math.abs(currentZone.TileY - zone.TileY) > (this.scene.sceneCamera.ZoneRangeXY.y + MAX_ZONE_CACHE_Y)) {
						SceneCache.MapImgCache.remove(currentZone.showContainer.name);
					}
				}
				
				SceneCache.InViewMapZones = currentZones;
				this.currentMapZone = zone;
			}
		}
		
		private function addMapZone(zone:MapZone, distance:int):LoadData {
			var loadData:LoadData = null;
			var key:String = null;
			var filePath:String = null;
			var mapZone:MapZone = zone;
			var priority:int = distance;
			
			// 如果它的内容为空, 则加载
			if (mapZone.showContainer.numChildren == 0) {
				key = ((mapZone.TileX + "_") + mapZone.TileY);
				filePath = ((this.scene.mapConfig.zoneMapDir + key) + ".jpg");		// 全路径名
				
				// 根据 filePath 搜索缓存, 如果存在, 直接使用
				if (SceneCache.MapImgCache.has(filePath)) {
					mapZone.showContainer.addChild((SceneCache.MapImgCache.get(filePath) as Bitmap));
				}
					// 否则, 新建加载任务
				else {
					// 加载完成
					var itemLoadComplete:Function = function (event:Event):void {
						SceneCache.MapImgCache.push(event.target.content, (event.currentTarget as LoaderInfo).url);	// 加入缓存
						mapZone.showContainer.addChild(event.target.content);						// 显示位图
						mapZone.showContainer.name = (event.currentTarget as LoaderInfo).url;		// url 作为 name
						waitingLoadData[key] = null;		// 删除任务
						delete waitingLoadData[key];
						Log4J.Info("加载地图完成" + filePath);
					};
					
					// 加载错误
					var itemLoadError:Function = function (event:Event):void {
						loadData.userData.retry++;		// 增加重试次数
						if (loadData.userData.retry > 3){
							Log4J.Info(("尝试加载地图" + filePath) + "3次均失败，已经放弃加载");
							waitingLoadData[key] = null;								// 放弃加载
							delete waitingLoadData[key];
						} else {
							loadData.userData.loader.load(new URLRequest(filePath));	// 继续加载
						}
					};
					
					// 构造 LoadData
					loadData = new LoadData(filePath, itemLoadComplete, null, itemLoadError, "", filePath, RslLoader.TARGET_SAME, priority);
					loadData.userData = {
						loader:new Loader(),
						retry:0
					}
				}
			}
			
			// 添加为自己的孩子
			if (mapZone.showContainer.parent != this){
				this.addChild(mapZone.showContainer);
			}
			return loadData;
		}
	}
}