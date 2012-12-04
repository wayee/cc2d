package wit.manager
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;

	/**
	 * 布局管理
	 * 界面显示的所有 DisplayObject 都由布局管理器管理
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class LayoutManager
	{
		// 最底/高层/东/西/南/北/中，共7个层次
		private static var _bottom:Sprite;
		private static var _top:Sprite;
		private static var _east:Sprite;
		private static var _south:Sprite;
		private static var _west:Sprite;
		private static var _north:Sprite;
		private static var _center:Sprite;
		
		public function LayoutManager()
		{
			throw new Error("LayoutManager class is static class only"); 
		}
		
		public static function initLayout(parent:DisplayObjectContainer):void
		{
			_bottom = new Sprite;
			_east = new Sprite;
			_south = new Sprite;
			_west = new Sprite;
			_north = new Sprite;
			_center = new Sprite;
			_top = new Sprite;
			parent.addChild(_bottom);
			parent.addChild(_east);
			parent.addChild(_south);
			parent.addChild(_west);
			parent.addChild(_north);
			parent.addChild(_center);
			parent.addChild(_top);
		}
		
		public static function appendBottom(child:DisplayObject):void
		{
			_bottom.addChild(child);
		}
		
		public static function appendEast(child:DisplayObject):void
		{
			_east.addChild(child);
		}
		
		public static function appendSouth(child:DisplayObject):void
		{
			_south.addChild(child);
		}
		
		public static function appendWest(child:DisplayObject):void
		{
			_west.addChild(child);
		}
		
		public static function appendNorth(child:DisplayObject):void
		{
			_north.addChild(child);
		}
		
		public static function appendCenter(child:DisplayObject):void
		{
			_center.addChild(child);
		}
		
		public static function appendTop(child:DisplayObject):void
		{
			_top.addChild(child);
		}
		
		public static function getRoot():DisplayObjectContainer
		{
			return _top.parent;
		}
		
		public static function getCenter():DisplayObjectContainer
		{
			return _center;
		}
		public static function getTop():DisplayObjectContainer
		{
			return _top;
		}
		public static function getBottom():DisplayObjectContainer
		{
			return _bottom;
		}
		public static function getNorth():DisplayObjectContainer
		{
			return _north;
		}
	}
}