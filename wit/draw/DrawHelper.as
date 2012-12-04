package wit.draw
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	/**
	 * 画线/矩形/圆
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class DrawHelper 
	{
		public function DrawHelper()
		{
			throw (new Error("This is a static class."));
		}
		
		/**
		 * 神灯请给我画出一条直线吧 
		 * 
		 * @param disp 哪个对象要画直线？
		 * @param start 起始位置
		 * @param end 结束位置
		 * @param style 线的样式
		 * @param clear 是否清除之前画的？
		 * 
		 */
		public static function drawLine(disp:*, start:Point, end:Point, 
										style:StyleData=null, clear:Boolean=false):void
		{
			if (!disp){
				return;
			}
			
			style = style || StyleData.DEFAULT;
			var g:Graphics = disp.graphics;
			if (clear){
				g.clear();
			}
			
			g.lineStyle(style.lineThickness, style.lineColor, style.lineAlpha);
			g.moveTo(start.x, start.y);
			g.lineTo(end.x, end.y);
		}
		
		/**
		 * 神灯请给我画出一个矩形吧 
		 * 
		 * @param disp 哪个对象要画矩形？
		 * @param start 起始位置
		 * @param end 结束位置
		 * @param style 线的样式
		 * @param clear 是否清除之前画的？
		 * 
		 */
		public static function drawRect(disp:*, start:Point, end:Point, 
										style:StyleData=null, clear:Boolean=false):void
		{
			if (!disp){
				return;
			}
			
			style = style || StyleData.DEFAULT;
			var g:Graphics = disp.graphics;
			if (clear){
				g.clear();
			}
			
			g.lineStyle(style.lineThickness, style.lineColor, style.lineAlpha);
			g.beginFill(style.fillColor, style.fillAlpha);
			g.moveTo(start.x, start.y);
			g.lineTo(end.x, start.y);
			g.lineTo(end.x, end.y);
			g.lineTo(start.x, end.y);
			g.lineTo(start.x, start.y);
			g.endFill();
		}
		
		/**
		 * 神灯请给我画出一圆吧 
		 * 
		 * @param disp 哪个对象要画圆？
		 * @param start 起始位置
		 * @param end 结束位置
		 * @param style 线的样式
		 * @param clear 是否清除之前画的？
		 * 
		 */
		public static function drawCircle(disp:*, start:Point, end:Point, 
										  style:StyleData=null, clear:Boolean=false):void
		{
			if (!disp) {
				return;
			}
			
			style = style || StyleData.DEFAULT;
			var g:Graphics = disp.graphics;
			if (clear) {
				g.clear();
			}
			
			g.lineStyle(style.lineThickness, style.lineColor, style.lineAlpha);
			g.beginFill(style.fillColor, style.fillAlpha);
			g.drawCircle(start.x, start.y, Math.sqrt((((end.x - start.x) * (end.x - start.x)) + ((end.y - start.y) * (end.y - start.y)))));
			g.endFill();
		}
	}
}