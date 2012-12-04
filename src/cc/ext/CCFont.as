package cc.ext
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * 位图字体
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class CCFont
	{
		public static const ALIGN_LEFT:uint = 0;
		public static const ALIGN_RIGHT:uint = 1;
		public static const ALIGN_CENTER:uint = 2;
		
		public static const SET1:String = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
		public static const SET2:String = "0123456789";
		public static const SET3:String = "0123456789+-";
		public static const SET4:String = "0123456789+-!";
		
		private var _fontSet:BitmapData;
		private var _offsetX:uint;
		private var _offsetY:uint;
		private var _characterWidth:uint;
		private var _characterHeight:uint;
		private var _characterSpacingX:uint;
		private var _characterSpacingY:uint;
		private var _characterPerRow:uint;
		private var _grabData:Array;
		
		public function CCFont()
		{
		}
		
		/**
		 * 初始化
		 * @param font 位图字体数据
		 * @param width 字符的宽度
		 * @param height 字符的长度
		 * @param chars
		 * @param charsPerRow
		 * @param xSpacing
		 * @param ySpacing
		 * @param xOffset
		 * @param yOffset
		 * 
		 */
		public function init(font:BitmapData, width:uint, height:uint, 
							chars:String, charsPerRow:uint,
							xSpacing:uint=0, ySpacing:uint=0,
							xOffset:uint=0, yOffset:uint=0):void
		{
			_fontSet = font;
			
			_characterWidth = width;
			_characterHeight = height;
			_characterSpacingX = xSpacing;
			_characterSpacingY = ySpacing;
			_characterPerRow = charsPerRow;
			_offsetX = xOffset;
			_offsetY = yOffset;
			
			_grabData = new Array;
			
			var currentX:uint = _offsetX;
			var currentY:uint = _offsetY;
			var r:uint = 0;
			
			var len:int = chars.length;
			for (var c:uint = 0; c<len; c++) {
				_grabData[chars.charCodeAt(c)] = new Rectangle(currentX, currentY, _characterWidth, _characterHeight);
				
				r++;
				
				if (r == _characterPerRow) { // 换行
					r = 0;
					currentX = _offsetX;
					currentY += _characterHeight + _characterSpacingY;
				} else {
					currentX += _characterWidth + _characterSpacingX;
				}
			}
		}
		
		/**
		 * 获取单行字符位图数据
		 * 
		 * @param text 字符串
		 * @param customSpacingX 水平间隔
		 * @param autoUpperCase 自动转换成大写
		 * @return BitmapData
		 * 
		 */
		public function getLine(text:String, customSpacingX:uint=0, autoUpperCase:Boolean=true):BitmapData
		{
			if (autoUpperCase) {
				text = text.toUpperCase();
			}
			
			text = removeUnsupportedCharacters(text);
			
			if (text.length * (_characterWidth + customSpacingX) > 2880) {
				throw Error('字符串太长，不能转换成位图字符');
			}
			
			var x:int = 0;
			var output:BitmapData = new BitmapData(text.length * (_characterWidth + customSpacingX), _characterHeight, true, 0xf);
			
			pasteLine(output, text, 0, 0, customSpacingX);
			
			return output;
		}
		
		/**
		 * 获取多行字符位图数据 
		 * 
		 * @param text 字符串
		 * @param customSpacingX 水平间隔
		 * @param customSpacingY 垂直间隔
		 * @param autoUpperCase 自动转换成大写
		 * @return BitmapData
		 * 
		 */		
		public function getMultiLine(text:String, customSpacingX:uint=0, customSpacingY:uint=0, align:int=0, autoUpperCase:Boolean=true):BitmapData
		{
			if (autoUpperCase) {
				text = text.toUpperCase();
			}
			
			text = removeUnsupportedCharacters(text, false);
			
			var lines:Array = text.split("\n");
			var lineCount:uint = lines.length;
			
			var longestLine:uint = getLongestLine(text);
			
			if (longestLine * (_characterWidth + customSpacingX) > 2880 ||
				lineCount * (_characterHeight + customSpacingY) - customSpacingY > 2880) {
				throw Error('字符串太长，不能转换成位图字符');
			}
			
			var x:int = 0;
			var y:int = 0;
			var output:BitmapData = new BitmapData(longestLine * (_characterWidth + customSpacingX), (lineCount * (_characterHeight + customSpacingY)) - customSpacingY, true, 0xf);
			
			for (var i:int=0; i<lineCount; i++) {
				switch (align) {
					case ALIGN_LEFT:
						x = 0;
						break;
					case ALIGN_CENTER:
						x = (output.width/2) - ((lines[i].length * (_characterWidth + customSpacingX)) / 2);
						x += customSpacingX / 2;
						break;
					case ALIGN_RIGHT:
						x = output.width - (lines[i].length * (_characterWidth + customSpacingX));
						break;
				}
				
				pasteLine(output, lines[i], x, y, customSpacingX);
				
				y += _characterHeight + customSpacingY;
			}
			
			return output;
		}
		
		/**
		 * 获取最长的行字符数
		 *  
		 * @param text 字符串
		 * @return uint
		 * 
		 */
		private function getLongestLine(text:String):uint
		{
			var lines:Array = text.split("\n");
			
			var longestLine:uint = 0;
			
			for (var i:uint = 0; i < lines.length; i++) {
				if (lines[i].length > longestLine) {
					longestLine = lines[i].length;
				}
			}
			
			return longestLine;
		}
		
		/**
		 * 粘贴字符串行 
		 * @param output 输出位图
		 * @param text 字符串
		 * @param x 初始的x位置
		 * @param y 初始的y位置
		 * @param customSpacingX 自定义水平空白
		 * 
		 */
		private function pasteLine(output:BitmapData, text:String, x:uint=0, y:uint=0, customSpacingX:uint=0):void
		{
			var len:int = text.length;
			for (var c:uint=0; c<len; c++) {
				if (text.charAt(c) == ' ') {
					x += _characterWidth + customSpacingX;
				} else {
					if (_grabData[text.charCodeAt(c)] is Rectangle) {
						output.copyPixels(_fontSet, _grabData[text.charCodeAt(c)], new Point(x, y));
						x += _characterWidth + customSpacingX;
					}
				}
			}
		}
		
		/**
		 * 删除不支持的字符 
		 * @param text 字符串
		 * @param stripCR 过滤换行符
		 * @return String 过滤后的字符串
		 * 
		 */
		private function removeUnsupportedCharacters(text:String, stripCR:Boolean=true):String
		{
			var newString:String = "";
			
			var len:int = text.length;
			for (var c:uint=0; c<len; c++) {
				if (_grabData[text.charCodeAt(c)] is Rectangle || text.charCodeAt(c) == 32 ||
					(stripCR == false && text.charAt(c) == "\n")) {
					newString = newString.concat(text.charAt(c));
				}
			}
			
			return newString;
		}
	}
}