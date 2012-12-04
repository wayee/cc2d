package wit.handler
{
	import flash.utils.Dictionary;

	/**
	 * Delegate 类允许您在特定作用域内运行函数
	 * 方法/函数委托，方便处理事件监听时传参
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class Delegate
	{
		private static var funDict:Dictionary = new Dictionary;

		/**
		 * 创建函数委托，不需要手动删除
		 *  
		 * @param func 需要委托的函数
		 * @param args 函数的参数
		 * @return Function
		 * 
		 */
		public static function create(func:Function, ...args):Function
		{
			return createWithArgs(func, args);
		}

		/**
		 * 创建函数委托，需要手动删除
		 *  
		 * @param func 需要委托的函数
		 * @param args 函数的参数
		 * @return Function
		 * 
		 */
		public static function createListener(func:Function, ...args):Function
		{
			return createWithArgs(func, args, true);
		}

		private static function createWithArgs(func:Function, args:*, needRemove:Boolean = false):Function
		{
			var f:Function = function():* {
				var func0:Function = arguments.callee.func;
				var parameters:Array = arguments.concat(args);
				return func0.apply(null, parameters);
			};

			f["func"] = func;

			if (needRemove) {
				funDict[func] = f;
			}
			return f;
		}

		/**
		 * 获取函数
		 *  
		 * @param fun 函数名
		 * @param autoDelete 获取后自动删除
		 * @return Function
		 * 
		 */
		public static function getFunction(func:Function, autoDelete:Boolean=true):Function
		{
			if (funDict[func] != null) {
				var f:Function = funDict[func] as Function;
				if (autoDelete) {
					delFunction(func);
				}
				return f;
			} else {
				return func;
			}
		}

		/**
		 * 删除委托过的函数 
		 * @param func
		 * 
		 */		
		public static function delFunction(func:Function):void
		{
			funDict[func] = null;
			delete funDict[func];
		}
	}
}