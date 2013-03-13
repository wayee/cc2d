package wit.timer
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import wit.utils.HashMap;
	
	/**
	 * 高级定时器
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 */
	public class SuperTimer
	{
		private static const TIME_SEPARATOR:int = 1000;		// millisecond
		private var _dict:HashMap = new HashMap;	// HashMap.content: TimerOption, TimerOption,...
		private var _timer:Timer;
		private var _interval:int;				// seconds
		
		/**
		 * @param interval 定时器 delay
		 */
		public function SuperTimer(interval:int) { _interval = interval }
		
		public function start():void
		{
			if (_timer == null) {
				_timer = new Timer(TIME_SEPARATOR*_interval);
				_timer.addEventListener(TimerEvent.TIMER, onTimerEvent);
				_timer.start();
			}
		}
		
		private function onTimerEvent(event:TimerEvent):void
		{
			// 定时器没内容，清除定时器
			if (_dict.size() <= 0) {
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, onTimerEvent);
				_timer = null;
				return;
			}
			
//			trace('time id:' + _interval + '  _dict.size():'+_dict.size());
			_dict.eachValue(handle);
			function handle(option:TimerOption):void {
				if (option.times > 0) {
					option.times -= 1;
					option.callBack();
				} else {
					if (option.completeHandler != null) {
						option.complete();
					}
					_dict.remove(option.handler);
				}
			}
		}
		
		public function get(handler:Function):TimerOption
		{
			if (_dict.containsKey(handler)) {
				return _dict.get(handler);
			}
			return null;
		}
		
		public function add(option:TimerOption):void
		{
			_dict.put(option.handler, option);
			if (option.autoStart) {
				option.callBack();
			}
			start();
		}
		
		public function has(handler:Function):Boolean
		{
			return _dict.containsKey(handler);
		}
		
		public function remove(handler:Function):void
		{
			_dict.remove(handler);
		}
		
		public function dispose():void
		{
			_dict.clear();
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, onTimerEvent);
			_timer = null;
		}
	}
}