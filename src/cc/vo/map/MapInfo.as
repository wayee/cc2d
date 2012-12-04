package cc.vo.map
{
	/**
	 * 地图配置信息
	 * <li> mapGridX, mapGridY 水平块和垂直块数量
	 * <li> mapUrl, smallMapUrl 地图和小地图url
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class MapInfo
	{
		public static var showGrid:Boolean = false;
		
		public var mapID:int;					// 地图 ID
		public var mapGridX:int;				// 水平块个数, 格子/块, 每个格子32像素
		public var mapGridY:int;				// 垂直块个数
		public var width:int;					// 地图尺寸, 像素
		public var height:int;
		public var mapUrl:String;				// 地图 url
		public var smallMapUrl:String;			// 小地图 url
		public var slipcovers:Array;			// 覆盖物信息, 元素类型={pixel_x, pixel_y, sourcePath}
//		public var grid:Array;
		public var mapData:Object;
	}
}
