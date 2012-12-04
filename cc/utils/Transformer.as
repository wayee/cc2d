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
//        public static function transTilePoint2ZonePoint(pos:Point):Point
//		{
//            return new Point(int(pos.x / SceneConfig.ZONE_SCALE), int(pos.y / SceneConfig.ZONE_SCALE));
//        }
		
		/**
		 * 普通场景
		 */
		// tile坐标 -> pixel坐标
        public static function transTilePoint2PixelPoint(tilePoint:Point):Point
		{
            return new Point(tilePoint.x * SceneInfo.TILE_WIDTH, tilePoint.y * SceneInfo.TILE_HEIGHT);
        }
		
		// pixel坐标 -> tile坐标
        public static function transPixelPoint2TilePoint(pixelPoint:Point):Point
		{
//            return new Point(int(pixelPoint.x / SceneConfig.TILE_WIDTH), int(pixelPoint.y / SceneConfig.TILE_HEIGHT));
            return new Point(Math.ceil(pixelPoint.x / SceneInfo.TILE_WIDTH), Math.ceil(pixelPoint.y / SceneInfo.TILE_HEIGHT));
        }
		
//		public static function transZoneTilePoint2ZonePixelPoint(pos:Point):Point
//		{
//            return new Point(pos.x * SceneConfig.ZONE_WIDTH, pos.y * SceneConfig.ZONE_HEIGHT);
//        }
		
		/**
		 * 角度 -> 0-8
		 */
        public static function transAngle2LogicAngle(angle:Number, logic:int=8):int
		{
            var logicAngle:Number = ZMath.getNearAngel((angle - 90), logic);
			
            return CharAngleType[("ANGEL_" + logicAngle)];
        }
        
		public static function transLogicAngle2Angle(logicAngle:int, logic:int=8):Number
		{
            var angle:Number = (360 / logic);
            return (logicAngle * angle) % 360;
        }
    }
}