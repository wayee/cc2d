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
		public var completeHandler:Function;
		public var completeParams:Array;
		public var autoStart:Boolean;
		
		/**
		 * 定时器参数实体 
		 * @param handler 函数
		 * @param params 参数
		 * @param delay 延时间隔
		 * @param times 次数
		 * 
		 */
		public function TimerOption(p_handler:Function, p_params:Array, p_delay:int=1, p_times:int=1, p_completeHandler:Function=null, p_completeParams:Array=null, p_autoStart:Boolean=true)
		{
			this.handler = p_handler;
			this.params = p_params;
			this.completeHandler = p_completeHandler;
			this.completeParams = p_completeParams;
			this.delay = p_delay;
			this.leftDelay = p_delay;
			this.times = p_times;
			this.autoStart = p_autoStart;
		}
		
		public function callBack():void
		{
			handler.apply(null, params);
		}
		
		public function complete():void
		{
			completeHandler.apply(null, completeParams);
		}
		
		public function resetDelay():void
		{
			leftDelay = delay;
		}
	}
}