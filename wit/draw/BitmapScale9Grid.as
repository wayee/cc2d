package wit.draw
{  
	import flash.display.Sprite;  
	import flash.display.Bitmap;  
	import flash.display.BitmapData;  
	import flash.geom.Rectangle;  
	import flash.geom.Point;  
	
	/**
	 * 位图九宫格实现
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class BitmapScale9Grid extends Sprite  
	{  
		private var source:Bitmap;  
		private var scaleGridTop:Number;  
		private var scaleGridBottom:Number;  
		private var scaleGridLeft:Number;  
		private var scaleGridRight:Number;  
		
		private var leftUp:Bitmap;  
		private var leftCenter:Bitmap;  
		private var leftBottom:Bitmap;  
		private var centerUp:Bitmap;  
		private var center:Bitmap;  
		private var centerBottom:Bitmap;  
		private var rightUp:Bitmap;  
		private var rightCenter:Bitmap;  
		private var rightBottom:Bitmap;  
		
		private var _width:Number;  
		private var _height:Number;  
		
		private var minWidth:Number;  
		private var minHeight:Number;  
		
		public function BitmapScale9Grid(source:Bitmap, scaleGridTop:Number, scaleGridBottom:Number, 
										 scaleGridLeft:Number, scaleGridRight:Number )   
		{  
			this.source = source;  
			this.scaleGridTop = scaleGridTop;  
			this.scaleGridBottom = scaleGridBottom;  
			this.scaleGridLeft = scaleGridLeft;  
			this.scaleGridRight = scaleGridRight;  
			init();  
			
		}  
		
		private function init():void
		{  
			_width = source.width;  
			_height = source.height;  
			
			leftUp = getBitmap(0, 0, scaleGridLeft, scaleGridTop);  
			this.addChild(leftUp);  
			
			leftCenter = getBitmap(0, scaleGridTop, scaleGridLeft, scaleGridBottom - scaleGridTop);  
			this.addChild(leftCenter);  
			
			leftBottom = getBitmap(0, scaleGridBottom, scaleGridLeft, source.height - scaleGridBottom);  
			this.addChild(leftBottom);  
			
			centerUp = getBitmap(scaleGridLeft, 0, scaleGridRight - scaleGridLeft, scaleGridTop);  
			this.addChild(centerUp);  
			
			center = getBitmap(scaleGridLeft, scaleGridTop, scaleGridRight - scaleGridLeft, scaleGridBottom - scaleGridTop);  
			this.addChild(center);  
			
			centerBottom = getBitmap(scaleGridLeft, scaleGridBottom, scaleGridRight - scaleGridLeft, source.height - scaleGridBottom);  
			this.addChild(centerBottom);  
			
			rightUp = getBitmap(scaleGridRight, 0, source.width - scaleGridRight, scaleGridTop);  
			this.addChild(rightUp);  
			
			rightCenter = getBitmap(scaleGridRight, scaleGridTop, source.width - scaleGridRight, scaleGridBottom - scaleGridTop);  
			this.addChild(rightCenter);  
			
			rightBottom = getBitmap(scaleGridRight, scaleGridBottom, source.width - scaleGridRight, source.height - scaleGridBottom);  
			this.addChild(rightBottom);  
			
			minWidth = leftUp.width + rightBottom.width;  
			minHeight = leftBottom.height + rightBottom.height;  
		}  
		
		/**
		 * 获取九宫后的位图 
		 * @param x
		 * @param y
		 * @param w
		 * @param h
		 * @return bitmap
		 */
		private function getBitmap(x:Number, y:Number, w:Number, h:Number):Bitmap
		{  
			var bit:BitmapData = new BitmapData(w, h);  
			bit.copyPixels(source.bitmapData, new Rectangle(x, y, w, h), new Point(0, 0));  
			var bitMap:Bitmap = new Bitmap(bit);  
			bitMap.x = x;  
			bitMap.y = y;  
			return bitMap;  
		}  
		
		/**
		 * 设置宽度 
		 * @param w
		 */
		override public function set width(w:Number):void
		{  
			if (w < minWidth) {  
				w = minWidth;  
			}  
			_width = w;  
			refurbishSize();  
		}  
		
		/**
		 * 设置高度 
		 * @param h
		 */
		override public function set height(h:Number):void
		{  
			if (h < minHeight) {  
				h = minHeight;  
			}  
			_height = h;  
			refurbishSize();  
		}  
		
		/**
		 * 刷新尺寸 
		 */
		private function refurbishSize():void
		{  
			leftCenter.height = _height - leftUp.height - leftBottom.height;  
			leftBottom.y = _height - leftBottom.height;  
			centerUp.width = _width - leftUp.width - rightUp.width;  
			center.width = centerUp.width;  
			center.height = leftCenter.height;  
			centerBottom.width = center.width;  
			centerBottom.y = leftBottom.y;  
			rightUp.x = _width - rightUp.width;  
			rightCenter.x = rightUp.x;  
			rightCenter.height = center.height;  
			rightBottom.x = rightUp.x;  
			rightBottom.y = leftBottom.y;  
		}  
	}  
}