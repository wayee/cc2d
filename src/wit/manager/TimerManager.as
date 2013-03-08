package wit.manager
{
	import flash.utils.Dictionary;
	
	import wit.log.Log4a;
	import wit.timer.SuperTimer;
	import wit.timer.TimerData;
	import wit.timer.TimerHelper;
	import wit.timer.TimerOption;

	/**
	 * 定时器管理器
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class TimerManager
	{
		private static var _timerArr:Array = [];
		private static var _timerDict:Dictionary = new Dictionary;
		
		public function TimerManager()
		{
			throw new Error('This is a static class.');
		}
		
		/**
		 * 获取定时器数量 
		 * @return int 数量
		 */
		public static function getTimersNum():int
		{
			return _timerArr.length;
		}
		
		/**
		 * 创建一个一次性普通的定时器 
		 * @param delay Timer.delay 延迟时间(毫秒)
		 * @param repeat Timer.repeat 重复次数
		 * @param handler 定时器函数
		 * @param params 定时器函数的参数
		 * @param compHandler 完成后的函数
		 * @param compParams 完成后的函数的参数
		 * @param autoStart 是否立即开始
		 */
		public static function createOneOffTimer(delay:Number, repeat:Number, handler:Function, 
												 params:Array=null, compHandler:Function=null, 
												 compParams:Array=null, autoStart:Boolean=true):void
		{
			TimerHelper.createTimer(delay, repeat, handler, params, compHandler, compParams, autoStart);
		}
		
		/**
		 * 创建一个普通的定时器 
		 * @param delay Timer.delay 延迟时间(毫秒)
		 * @param repeat Timer.repeat 重复次数
		 * @param handler 定时器函数
		 * @param params 定时器函数的参数
		 * @param compHandler 完成后的函数
		 * @param compParams 完成后的函数的参数
		 * @param autoStart 是否立即开始
		 * @return TimerData 定时器数据Vo
		 */
		public static function createTimer(delay:Number, repeat:Number, handler:Function, 
										   params:Array=null, compHandler:Function=null, 
										   compParams:Array=null, autoStart:Boolean=true):TimerData
		{
			var data:TimerData = TimerHelper.createTimer(delay, repeat, handler, params, compHandler, compParams, autoStart);
			_timerArr[_timerArr.length] = data;
			Log4a.Info(("TimerManager.createTimer::_timerArr.length:" + getTimersNum()));
			return data;
		}
		
		/**
		 * 创建一个一次性精准的定时器 
		 * @return TimerData 
		 */
		public static function createOneOffExactTimer(duration:Number, from:Number, to:Number, 
													  updateHandler:Function=null, compHandler:Function=null, 
													  updateStep:Number=0):void
		{
			TimerHelper.createExactTimer(duration, from, to, updateHandler, compHandler, updateStep);
		}
		
		/**
		 * 创建一个精准的定时器 
		 * @return TimerData 
		 */
		public static function createExactTimer(duration:Number, from:Number, to:Number, 
												updateHandler:Function=null, compHandler:Function=null, 
												updateStep:Number=0):TimerData
		{
			var data:TimerData = TimerHelper.createExactTimer(duration, from, to, updateHandler, compHandler, updateStep);
			_timerArr[_timerArr.length] = data;
			Log4a.Info("TimerManager.createTimer::_timerArr.length:" + getTimersNum());
			return data;
		}
		
		/**
		 * 删除一个定时器 
		 * @param value TimerData 定时器数据
		 */		
		public static function deleteTimer(value:TimerData):void
		{
			var data:TimerData;
			var num:int = _timerArr.length;
			while (num-- > 0) {
				data = _timerArr[num];
				if (data == value){
					_timerArr.splice(num, 1);
					Log4a.Info("TimerManager.deleteTimer::_timerArr.length:" + getTimersNum());
					data.destroy();
					break;
				}
			}
		}
		
		/**
		 * 删除所有定时器 
		 */
		public static function deleteAllTimers():void
		{
			var data:TimerData;
			for each (data in _timerArr) {
				data.destroy();
			}
			_timerArr = [];
			Log4a.Info("TimerManager.deleteAllTimers::_timerArr.length:0");
		}
		
		
		///////////////////////////////////
		// 多功能全局定时器
		///////////////////////////////////
		
		/**
		 * 多功能定时器
		 * 根据不同的定时器id，开启不同的定时器，例如：需要开始每秒都运行的定时器，
		 * timeid可以穿1进来，需要开启每分钟都运行的定时器，timeid可以传60进来，
		 * 这就是timeid约定以秒为单位，可以让同一时间的需求共享同一定时器，当每种类
		 * 型的定时器都执行完，定时器自动停止并删除
		 * 
		 * @param handler 回调函数
		 * @param params 回调函数参数
		 * @param completeHandler 完成回调函数
		 * @param completeParams 完成回调函数参数
		 * @param delay 延迟间隔 	 (unit: second)
		 * @param times 次数 int  default:1
		 * 
		 */	
		public static function createGlobalTimer(handler:Function, params:Array=null, delay:int=1, times:int=1, completeHandler:Function=null, completeParams:Array=null):void
		{
			if ( !(handler is Function)) return;
			if (times <= 0) return;
			
			var id:String = 'timer_'+delay;
			if ( !_timerDict.hasOwnProperty(id) || !(_timerDict[id] is SuperTimer) ) {
				var timer:SuperTimer = new SuperTimer(delay);
				_timerDict[id] = timer;
			} 
			
			var superTimer:SuperTimer = (_timerDict[id] as SuperTimer);
			if (superTimer.has(handler)) {
				var timerOp:TimerOption = superTimer.get(handler);
				timerOp.times = times;
				timerOp.params = params;
				timerOp.completeHandler = completeHandler;
				timerOp.completeParams = completeParams;
			} else {
				superTimer.add(new TimerOption(handler, params, delay, times, completeHandler, completeParams));
			}
		}
		
		/**
		 * 是否有一个全局定时器的回调 
		 * @param handler 回调函数
		 * @param delay 时间间隔
		 */		
		public static function hasGlobalHandler(handler:Function, delay:int):Boolean
		{
			var id:String = 'timer_'+delay;
			
			return _timerDict.hasOwnProperty(id) && (_timerDict[id] as SuperTimer).has(handler);
		}
		
		/**
		 * 删除一个全局定时器的回调 
		 * @param handler 回调函数
		 * @param delay 时间间隔
		 */		
		public static function deleteGlobalHandler(handler:Function, delay:int):void
		{
			var id:String = 'timer_'+delay;
			if ( _timerDict.hasOwnProperty(id) ) {
				(_timerDict[id] as SuperTimer).remove(handler);
			} 
		}
		
		/**
		 * 删除一个全局定时器 
		 * @param delay 时间间隔
		 */
		public static function deleteGlobalTimer(delay:int):void
		{
			var id:String = 'timer_'+delay;
			SuperTimer(_timerDict[id]).dispose();
			_timerDict[id] = null;
			delete _timerDict[id];
		}
	}
}