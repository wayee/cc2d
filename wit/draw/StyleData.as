package wit.draw
{
	/**
	 * 绘图风格
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class StyleData
	{
		public static const DEFAULT:StyleData = new StyleData(0, 0, 1, 0, 1);
		
		public var lineThickness:Number;			// 线 粗细
		public var lineColor:uint;					// 线 颜色
		public var lineAlpha:Number;				// 线 透明度
		public var fillColor:uint;					// 填充 色
		public var fillAlpha:Number;				// 填充 透明度
		
		/**
		 * 线粗细, 线颜色, 线透明, 填充颜色, 填充透明
		 */
		public function StyleData(thick:Number=0, color:uint=0, alpha:Number=1, bgcolor:uint=0, bgAlpha:Number=1)
		{
			this.lineThickness = thick;
			this.lineColor = color;
			this.lineAlpha = alpha;
			this.fillColor = bgcolor;
			this.fillAlpha = bgAlpha;
		}
	}
}