package cc.utils
{
	import cc.define.CharAngleType;
	import cc.vo.map.SceneInfo;
	
	import flash.geom.Point;
	
	import wit.utils.math;
	
    public class Transformer
	{
        public static function TransTilePoint2ZonePoint(p_tile:Point):Point {
            return new Point(int(p_tile.x / SceneInfo.ZONE_SCALE), int(p_tile.y / SceneInfo.ZONE_SCALE));
        }
		
        public static function TransTilePoint2PixelPoint(p_tile:Point):Point {
            return new Point(p_tile.x * SceneInfo.TILE_WIDTH, p_tile.y * SceneInfo.TILE_HEIGHT);
        }
		
        public static function TransPixelPoint2TilePoint(pixelPoint:Point):Point {
//            return new Point(int(pixelPoint.x / SceneConfig.TILE_WIDTH), int(pixelPoint.y / SceneConfig.TILE_HEIGHT));
            return new Point(Math.ceil(pixelPoint.x / SceneInfo.TILE_WIDTH), Math.ceil(pixelPoint.y / SceneInfo.TILE_HEIGHT));
        }
		
		public static function TransZoneTilePoint2ZonePixelPoint(p_tile:Point):Point {
            return new Point(p_tile.x * SceneInfo.ZONE_WIDTH, p_tile.y * SceneInfo.ZONE_HEIGHT);
        }
		
        public static function TransAngle2LogicAngle(p_angle:Number, p_logic:int=8):int {
            var logicAngle:Number = math.getNearAngel((p_angle - 90), p_logic);
			
            return CharAngleType[("ANGEL_" + logicAngle)];
        }
        
		public static function TransLogicAngle2Angle(p_logicAngle:int, p_logic:int=8):Number {
            var angle:Number = (360 / p_logic);
            return (p_logicAngle * angle) % 360;
        }
		
		public static function TransTilePoint2Id(p_tile:Point, mapGridX:int, mapGridY:int):int {
			return (p_tile.y-1) * mapGridX + p_tile.x;
		}
		
		public static function TransId2TilePoint(id:int, mapGridX:int, mapGridY:int):Point {
			var tile:Array;
			var tx:int = int(id-1)%mapGridX + 1;
			var ty:int = int(id-1)/mapGridX + 1;
			
			return new Point(tx, ty);
		}
		
		public static function TransIds2TilePoints(ids:Array, mapGridX:int, mapGridY:int):Array {
			var tiles:Array = new Array;
			for each (var id:int in ids) {
				tiles.push(TransId2TilePoint(id, mapGridX, mapGridY));
			}
			return tiles;
		}
    }
}