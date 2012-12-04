package wit.timer
{
	/**
	 * 定时器 Vo
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class TimerOption
	{
		public var handler:Function;
		public var params:Array;
		public var delay:int;
		public var times:int;
		public var leftDelay:int;
		
		/**
		 * 定时器参数实体 
		 * @param handler 函数
		 * @param params 参数
		 * @param delay 延时间隔
		 * @param times 次数
		 * 
		 */
		public function TimerOption(handler:Function, params:Array, delay:int, times:int=1)
		{
			this.handler = handler;
			this.params = params;
			this.delay = delay;
			this.leftDelay = delay;
			this.times = times;
		}
		
		public function callBack():void
		{
			handler.apply(null, params);
		}
		
		public function resetDelay():void
		{
			leftDelay = delay;
		}
	}
}