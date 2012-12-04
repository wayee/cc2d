package cc.graphics.layers
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import cc.vo.map.MapInfo;
	
	/**
	 * 场景中的网格
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class SceneGrid extends Sprite
	{
		public static var showGridIndex:Boolean = false;
		private static const BG_COLOR:uint = 0x333333;
		
		private static const MASK_COLOR:uint = 0x000088;
		private static const FILL_COLOR:uint = 0x008800;
		private static const THROUGH:Number = 0;
		private static const BLOCK:Number = 0.6;
		private var _grid:Shape;
		private var _tfArr:Array;
		
		public function SceneGrid()
		{
			_grid = new Shape;
			_tfArr = new Array;
		}
		
		/**
		 * 显示网格 
		 * @param grid
		 * @param gridX
		 * @param gridY
		 * @param w
		 * @param h
		 */		
		public function show(grid:Object, gridX:int, gridY:int, w:int, h:int):void
		{
			if (MapInfo.showGrid === false) return;
			
			addChild(_grid);
			draw(grid, gridX, gridY, w, h);
		}
		
		/**
		 * 隐藏网格 
		 */
		public function hide():void
		{
			var g:Graphics = _grid.graphics;
			g.clear();
			clearTF();
			if (contains(_grid)) removeChild(_grid);
		}
		
		public function fillTiles( fillGrids:Array, gridX:int, gridY:int, w:int, h:int ):void
		{
			if ( !contains(_grid) )
				return;

			var g:Graphics = _grid.graphics;	
			for (var i:int=0; i<fillGrids.length; i++) {
				var index:int = fillGrids[i];
				
				var y:int = int( ( index - 1 ) / gridX ) + 1;;
				var x:int = ( index - 1 ) % gridX + 1;
				
				g.beginFill(FILL_COLOR, 0.7);
				g.lineStyle(1);
				g.drawRect(x*w, y*h, w, h);
				g.endFill();
			}
		}
		
		/**
		 * 绘制网格 
		 * @param grid
		 * @param gridX
		 * @param gridY
		 * @param w
		 * @param h
		 * 
		 */
		private function draw(grid:Object, gridX:int, gridY:int, w:int, h:int):void
		{
			var g:Graphics = _grid.graphics;
			g.clear();
			clearTF();
			
			for (var i:int=1; i<=gridX; i++) {
				for (var j:int=1; j<=gridY; j++) {
//					var index:int = j*gridX + i + 1;
					var index:int = (j - 1 ) * gridX + i;
					var al:Number = grid[index] == 0 ? THROUGH : BLOCK;
					// 显示格子编号
					if (showGridIndex) {
						var tf:TextField = new TextField;
						tf.x = i*w;
						tf.y = j*h;
						tf.text = index + "\n" + (i+1) + ', ' + (j+1);
						addChild(tf);
						_tfArr.push(tf);
					}
					
					g.beginFill(BG_COLOR, al);
					g.lineStyle(1);
					g.drawRect((i-1)*w, (j-1)*h, w, h);
					g.endFill();

					if( grid[index] == 2 )
					{						
						g.beginFill(MASK_COLOR, al);
						g.lineStyle(1);
						g.drawRect((i-1)*w, (j-1)*h, w, h);
						g.endFill();						
					}
				}
			}
		}
		
		private function clearTF():void
		{
			var tf:TextField;
			for (var i:int=0; i<_tfArr.length; i++) {
				tf = _tfArr[i];
				if (contains(tf)) {
					removeChild(tf);
				}
				delete _tfArr[i];
//				_tfArr.splice(i, 1);
			}
			_tfArr.length = 0;
		}
	}
}