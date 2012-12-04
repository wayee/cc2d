package wit.utils
{
	import flash.utils.Dictionary;

	/**
	 * 第一次工具，游戏中有很多都需要第一次
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class FirstTimeHelper
	{
		/**
		 * key 值定义 
		 */		
		
		public static var firstTimeDict:Dictionary = new Dictionary;
		
		public function FirstTimeHelper()
		{
		}
		
		/**
		 * 设置次数 
		 */
		public static function setTimes(key:String, times:int):void
		{
			firstTimeDict[key] = times;
		}
		
		/**
		 * 增加次数 
		 */
		public static function addTimes(key:String, times:int=1):void
		{
			if (hasKey(key)) {
				firstTimeDict[key] = int(firstTimeDict[key]) + times;
			} else {
				firstTimeDict[key] = times;
			}
		}
		
		/**
		 * 清除次数 
		 */
		public static function clearTimes(key:String):void
		{
			if (hasKey(key)) {
				firstTimeDict[key] = null;
				delete firstTimeDict[key];
			}
		}
		
		/**
		 * 是否第一次 
		 */
		public static function isFirstTime(key:String):Boolean
		{
			var b:Boolean = false;
			if ( !hasKey(key) ) {
				b = true;
			} else {
				if (firstTimeDict[key] == 1) b = true;
			}
			return b;
		}
		
		/**
		 * 是否存在key
		 */
		public static function hasKey(key:String):Boolean
		{
			return firstTimeDict.hasOwnProperty(key);
		}
		
		/**
		 * equal =
		 */
		public static function eq(key:String, num:int):Boolean
		{
			var b:Boolean = false;
			if (hasKey(key)) {
				b = firstTimeDict[key] == num;
			}
			return b;
		}
		
		/**
		 * greater than > 
		 */
		public static function gt(key:String, num:int):Boolean
		{
			var b:Boolean = false;
			if (hasKey(key)) {
				b = firstTimeDict[key] > num;
			}
			return b;
		}
		
		/**
		 * greater or equal >=
		 */
		public static function ge(key:String, num:int):Boolean
		{
			var b:Boolean = false;
			if (hasKey(key)) {
				b = firstTimeDict[key] >= num;
			}
			return b;
		}
		
		/**
		 * less than < 
		 */
		public static function lt(key:String, num:int):Boolean
		{
			var b:Boolean = false;
			if (hasKey(key)) {
				b = firstTimeDict[key] < num;
			}
			return b;
		}
		
		/**
		 * less or equal <= 
		 */
		public static function le(key:String, num:int):Boolean
		{
			var b:Boolean = false;
			if (hasKey(key)) {
				b = firstTimeDict[key] <= num;
			}
			return b;
		}
	}
}