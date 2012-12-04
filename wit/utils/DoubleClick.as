package wit.utils
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer; 

	/**
	 * 模拟双击
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class DoubleClick 
	{
		private static var _timer:Timer;
		private static var _counter:int = -1;
		private static var _clickEvent:MouseEvent;
		private static var _timerEvent:Boolean = false;
		
		private static function _click(e:MouseEvent):void 
		{
			if (_timerEvent) {
				_timerEvent = false;
				return;
			}
			if (_counter == 1) {
			    _timer.stop();
			    var edc:MouseEvent = new MouseEvent(MouseEvent.DOUBLE_CLICK, e.bubbles, e.cancelable, e.localX, e.localY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta);
			    e.target["dispatchEvent"](edc);
			    _counter = 0;
		   	} else {
			    _counter++;
			    _clickEvent = e;
			    _timer.start();
		   	}
		   	e.stopImmediatePropagation();
		}
		
		private static function _stopTimer(e:MouseEvent):void 
		{
			if (_timer.running) {
				_timer.stop();
			}
		}
		
		private static function _dispatch(e:TimerEvent):void 
		{
			_timerEvent = true;
			_clickEvent.target["dispatchEvent"](_clickEvent);
			_counter = 0;
		}
		
		public static function init(iObject:InteractiveObject, delay:int = 200, priority:int = 999):void 
		{
			if(_counter == -1) {
				_timer = new Timer(delay, 1);
				_clickEvent = null;
				_counter = 0;
				_timer.addEventListener(TimerEvent.TIMER, _dispatch);
			}else {
				if(_timer.delay != delay) {
					_timer.delay = delay;
				}
			}
			iObject.addEventListener(MouseEvent.MOUSE_DOWN, _stopTimer, false, priority);
			iObject.addEventListener(MouseEvent.CLICK, _click, false, priority);
			iObject.doubleClickEnabled = false;
		}
		
		public function DoubleClick()
		{    
			throw new Error("DoubleClick class is static class only");    
		}  
	}
}