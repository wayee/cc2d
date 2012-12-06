package cc.utils
{
	import cc.define.CharAngleType;
	import cc.vo.map.SceneInfo;
	
	import flash.geom.Point;
	
	import wit.utils.ZMath;
	
	/**
	 * 转换器
	 *   块和像素点转换
	 *   角度转换 
	 */
    public class Transformer
	{
		// tile -> zone
        public static function transTilePoint2ZonePoint(pos:Point):Point
		{
            return new Point(int(pos.x / SceneInfo.ZONE_SCALE), int(pos.y / SceneInfo.ZONE_SCALE));
        }
		
		/**
		 * tile坐标 -> pixel坐标
		 */
        public static function transTilePoint2PixelPoint(tilePoint:Point):Point {
            return new Point(tilePoint.x * SceneInfo.TILE_WIDTH, tilePoint.y * SceneInfo.TILE_HEIGHT);
        }
		
		/**
		 * pixel坐标 -> tile坐标
		 */
        public static function transPixelPoint2TilePoint(pixelPoint:Point):Point {
//            return new Point(int(pixelPoint.x / SceneConfig.TILE_WIDTH), int(pixelPoint.y / SceneConfig.TILE_HEIGHT));
            return new Point(Math.ceil(pixelPoint.x / SceneInfo.TILE_WIDTH), Math.ceil(pixelPoint.y / SceneInfo.TILE_HEIGHT));
        }
		
		public static function transZoneTilePoint2ZonePixelPoint(pos:Point):Point
		{
            return new Point(pos.x * SceneInfo.ZONE_WIDTH, pos.y * SceneInfo.ZONE_HEIGHT);
        }
		
        public static function transAngle2LogicAngle(p_angle:Number, p_logic:int=8):int {
            var logicAngle:Number = ZMath.getNearAngel((p_angle - 90), p_logic);
			
            return CharAngleType[("ANGEL_" + logicAngle)];
        }
        
		public static function transLogicAngle2Angle(p_logicAngle:int, p_logic:int=8):Number {
            var angle:Number = (360 / p_logic);
            return (p_logicAngle * angle) % 360;
        }
    }
}