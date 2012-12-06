package cc.loader
{
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	
	import cc.CCScene;
	import cc.events.CCEvent;
	import cc.events.CCEventActionProcess;
	import cc.tools.SceneCache;
	import cc.tools.SceneLoader;
	import cc.utils.CCG;
	import cc.utils.Transformer;
	import cc.vo.map.MapInfo;
	import cc.vo.map.MapTile;
	import cc.vo.map.SceneInfo;
	
	import com.adobe.serialization.json.JSON;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Point;
	
	import wit.event.EventDispatchCenter;
	import wit.loader.LoadData;
	import wit.manager.LoaderManager;
	import wit.utils.Fun;

	public class MapLoader
	{
		public static function LoadMapConfig(mapPicId:int, targetScene:CCScene, 
											 completeHandler:Function=null, updateHandler:Function=null):void {
			var newOnComplete:Function = function (event:Event):void {
				var data:String;
				if (event.target is LoadingItem) {
					data = event.target.content;
				} else {
					data = event.target.data;
				}
				
				// 使用加密/解密
//				if (CCG.decode != null) {
//					data = ZZip.extractFristTextFileContent(data, CCG.decode);	
//					if (data == ""){
//						return;
//					}
//				}
				
				/**
				 * JSON 格式，建立MapConfig对象
				 * {
				 *   "id":1234, "name":"earthSceneA", "mapGridX":水平格子数, "mapGridY":垂直格子数,
				 *   "slipcovers":[{"id":123, "x":111, "y":222}, {}, ...], 
				 *   "tiles":"0,0,0,0,0,0,0,0"
				 * }
				 * 
				 * tiles中，0可通过, 1不可通过, 2可通过并遮挡
				 * 
				 */
				
				data = data.replace(/\s/g, ''); // 去掉json字符串中的所有空白
				var dataObj:Object = JSON.decode(data);
				if (!dataObj) return;
				
				var mapConfig:MapInfo = new MapInfo;
				mapConfig.mapID = dataObj.id;
				mapConfig.mapGridX = dataObj.mapGridX;	// 水平格子(块)数量 
				mapConfig.mapGridY = dataObj.mapGridY;	// 垂直格子(块)数量
				mapConfig.width = mapConfig.mapGridX * SceneInfo.TILE_WIDTH;			// 宽度
				mapConfig.height = mapConfig.mapGridY * SceneInfo.TILE_HEIGHT;			// 高度
				mapConfig.zoneMapDir = CCG.getZoneMapFolder(dataObj.pic.toString()); 	// 地图族路径
				mapConfig.smallMapUrl = CCG.GetSmallMapPath(dataObj.pic + '.jpg'); 		// 小地图路径
				
				// 覆盖物
//				if (dataObj && dataObj.slipcovers) {
//					var covers:Array = dataObj.slipcovers;
//					var sourcePath:String = '';
//					var coverObj:Object;
//					if (covers && covers.length>0) {
//						for each (var cover:Object in covers) {
//							sourcePath = ElfG.getAvatarMapSlipcoverPath(cover.id);
//							coverObj = {pixelX:int(cover.x), pixelY:int(cover.y), sourcePath:sourcePath};
//							mapConfig.slipcovers.push(coverObj);
//						}
//					}
//				}
				
				// 地图位置信息
				var tileInfo:Array = String(dataObj.tiles).split(',');
				var len:int = tileInfo.length;
				var transports:Object = SceneCache.transports;			// [ mapId_x_y ] != undefined => 传送点
				var mapId:int = mapConfig.mapID;
				var mapTile:Object = {};		// [ x_y ] = MapTile
				var mapSolids:Object = {};		// [ x_y ] = isSolid
				var tx:int;
				var ty:int;
				var tileValue:int;
				var realTiles:Object = new Object;
				var tilePoint:Point;
				for (var i:int=1; i<=len; i++) { // [0, 0] 开始
					tilePoint = Transformer.TransId2TilePoint(i, mapConfig.mapGridX, mapConfig.mapGridY);
					tx = tilePoint.x;
					ty = tilePoint.y;
					tileValue = int(tileInfo[i-1]);
					realTiles[i] = tileInfo[i-1];
					mapTile[tx + '_' + ty] = new MapTile(tx, ty, tileValue==1, tileValue==0, tileValue==2, transports[mapId+'_'+tx+'_'+ty]!=undefined);
					mapSolids[tx + '_' + ty] = tileValue==1 ? 1 : 0;
				}
				
//				mapConfig.grid = tileInfo;
				mapConfig.mapData = {tiles:realTiles, mapGridX:dataObj.mapGridX, mapGridY:dataObj.mapGridY, id:dataObj.id, pic:dataObj.pic};
				
				tileInfo.splice(0);
				tileInfo = null;
				
				if (completeHandler != null){
					
					completeHandler(mapConfig, mapTile, mapSolids);	// [MapInfo, MapTile[], int[]]
				}
			}
			// 暂停小地图
			SceneLoader.smallMapImgLoader.pauseAll();
			SceneLoader.smallMapImgLoader.removeAll();
			
			var loadData:LoadData = new LoadData(CCG.GetMapConfigPath(mapPicId + '.json'), newOnComplete, updateHandler);
			LoaderManager.load([loadData], SceneLoader.smallMapImgLoader);
		}
		
		public static function LoadSmallMap(scene:CCScene):void {
			var loadSmallMapComplete:Function = function (event:Event):void {
				var loadItem:LoadingItem = (event.target as LoadingItem);
				var smallMap:Bitmap = loadItem.content as Bitmap;
				if (smallMap) {
					smallMap.width = scene.mapConfig.width;
					smallMap.height = scene.mapConfig.height;
					scene.sceneSmallMapLayer.addChild(smallMap);				// 添加小地图显示
					var sceneEvent:CCEvent = new CCEvent(CCEvent.PROCESS, CCEventActionProcess.LOAD_SMALL_MAP_COMPLETE, smallMap.bitmapData);
					EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
				}
			}
			Fun.clearChildren(scene.sceneSmallMapLayer, true);					// clearup
			SceneLoader.smallMapImgLoader.pauseAll();
			SceneLoader.smallMapImgLoader.removeAll();
			
			LoaderManager.lazyLoad(loadSmallMapComplete, SceneLoader.smallMapImgLoader, false, scene.mapConfig.smallMapUrl);
		}
	}
}