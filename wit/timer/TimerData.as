package wit.timer
{
	import flash.utils.Timer;

	/**
	 * 定时器数据
	 * <br> 是对 Timer 的扩展
	 * <br> 可随时取消 Timer
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class TimerData
	{
		private var _timer:Timer;
		private var _destroy:Function;
		
		public function TimerData(timer:Timer, handler:Function)
		{
			this._timer = timer;
			this._destroy = handler;
		}
		
		/**
		 * 定时器 
		 */
		public function get timer():Timer
		{
			return this._timer;
		}
		
		/**
		 * 释放定时器 
		 */
		public function get destroy():Function
		{
			return this._destroy;
		}
	}
}