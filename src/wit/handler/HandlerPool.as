package wit.handler
{
	/**
	 * 操作线程池
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class HandlerPool
	{
		private static var _threads:Array = [];
		
		public function HandlerPool()
		{
		}
		
		public static function getThread():HandlerThread
		{
			if (_threads.length <= 0) {
				_threads.push(new HandlerThread);
			}
//			trace('[HandlerThreadPool] 借出一枚，线程数量：', _threads.length);
			return _threads.shift();
		}
		
		public static function recycleThread(thread:HandlerThread):void
		{
			_threads.push(thread);
//			trace('[HandlerThreadPool] 回收一枚，线程数量：', _threads.length);
		}
	}
}