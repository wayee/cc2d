﻿package cc.vo.map
{
	public class MapInfo
	{
		public static var showGrid:Boolean = false;
		
		public var mapID:int;					// 地图 ID
		public var mapGridX:int;				// 水平块个数, 格子/块, 每个格子32像素
		public var mapGridY:int;				// 垂直块个数
		public var width:int;					// 地图尺寸, 像素
		public var height:int;
		public var mapUrl:String;				// 地图 url
		public var zoneMapDir:String;			// 地图族图片 所在目录		"xxxxx/" + "x_y.jpg"
		public var smallMapUrl:String;			// 小地图 url
		public var slipcovers:Array;			// 覆盖物信息, 元素类型={pixel_x, pixel_y, sourcePath}
		public var mapData:Object;
	}
}