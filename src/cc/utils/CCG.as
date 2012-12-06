package cc.utils
{
	public class CCG
	{
		public static var frameRate:int = 24;						// 当前 fps
		public static var stepTime:Number = (1000 / frameRate);		// 每帧时间长度(毫秒)
		
		public static var resourcePath:String = "";					// 资源的路径
		public static var mapConfig:String = "scene/c/";				// 地图配置路径
		public static var zoneMapPath:String = "scene/";					// 地图路径
		public static var mapSmallPath:String = "scene/s/";			// 小地图路径
		
		public static function GetResPath(resUrl:String):String {
			return resourcePath + resUrl;
		}
		
		public static function GetMapConfigPath(mapId:String):String {
			return resourcePath + mapConfig + mapId;
		}
		
		public static function GetSmallMapPath(mapId:String):String {
			return resourcePath + mapSmallPath + mapId;
		}
		
		public static function getZoneMapFolder(mapId:String):String {
			return resourcePath + zoneMapPath + mapId + '/';
		}
	}
}