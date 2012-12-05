package cc
{
	import cc.vo.map.SceneInfo;
	
	import flash.display.DisplayObjectContainer;
	
	import wit.utils.Fun;
	
	/**
	 * 游戏对象基类
	 * <li>子类包含: CCCharacter, MapTile, MapZone, CCCamera 
	 */
	public class CCNode
	{
		public var id:int = 0;
		public var name:String = "";
		public var data:Object;											// 任意数据
		public var showContainer:CCHead;								// Sprite, 关联的容器, 启用时, 需要设置它的父容器
		
		// 尺寸, 这里的块是个可变的概念, 可以为一个 TILE, 或者为1个ZONE
		public var tileWidth:Number = SceneInfo.TILE_WIDTH;				// 块尺寸
		public var titleHeight:Number = SceneInfo.TILE_HEIGHT;
		
		protected var tileX:int = 0;									// 块坐标
		protected var tileY:int = 0;
		protected var pixelX:Number = 0;								// 像素坐标
		protected var pixelY:Number = 0;
		
		private var useContainer:Boolean = false;						// 是否使用容器
		
		/**
		 * 像素坐标x
		 * <li> 设置 pixelX/y, tileX/y, showContainer.x/y
		 */
		public function get PixelX():Number {
			return pixelX;
		}
		
		public function set PixelX(value:Number):void {
			pixelX = value;
			tileX = Math.ceil(pixelX / tileWidth);
			if (showContainer != null && showContainer.x != pixelX) {
				showContainer.x = pixelX;				// 移动关联容器
			}
		}
		
		/**
		 * 像素坐标y
		 */
		public function get PixelY():Number {
			return pixelY;
		}
		
		public function set PixelY(value:Number):void {
			pixelY = value;
			tileY = Math.ceil(pixelY / titleHeight);
			if (showContainer != null && showContainer.y != pixelY) {
				showContainer.y = pixelY;
			}
		}
		
		public function get TileX():int {
			return tileX;
		}
		
		public function set TileX(value:int):void {
			tileX = value;
			pixelX = tileX * tileWidth;
			if (showContainer != null && showContainer.x != pixelX) {
				showContainer.x = pixelX;									// 移动关联容器
			}
		}
		
		public function get TileY():int {
			return tileY;
		}
		
		public function set TileY(value:int):void {
			tileY = value;
			pixelY = tileY * titleHeight;
			if (showContainer != null && showContainer.y != pixelY) {
				showContainer.y = pixelY;
			}
		}
		
		/**
		 * 是否使用容器 
		 * @return bool
		 */
		public function get UseContainer():Boolean {
			return useContainer;
		}
		
		/**
		 * 启用关联容器
		 * <li> ShowContainer的坐标值和pixelX, pixelY一致
		 * 
		 * @param parent 关联容器的父容器, 如 Scene.sceneHeadLayer
		 * @param visible 可见性
		 */
		public function EnableContainer(parent:DisplayObjectContainer=null, visible:Boolean=true):void {
			useContainer = true;
			if (showContainer == null) {
				showContainer = new CCHead();
				showContainer.x = pixelX;
				showContainer.y = pixelY;
			}
			showContainer.visible = visible;
			if (parent != null) {
				parent.addChild(showContainer);
			}
		}
		
		public function DisableContainer():void	{
			useContainer = false;
			if (showContainer != null) {
				if (showContainer.parent != null) {
					showContainer.parent.removeChild(showContainer);
				}
				Fun.clearChildren(showContainer, true);
				showContainer = null;
			}
		}
	}
}