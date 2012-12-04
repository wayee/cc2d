package wit.timer
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import wit.manager.HandlerManager;
	
	/**
	 * 定时器助手
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class TimerHelper
	{
		private static const _timeRegExp:RegExp = /(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)/;
		public static const SEC:int = 1;
		public static const MIN:int = 60;
		public static const HRS:int = 60*60;
		public static const DAY:int = 60*60*24;
		public static const WEEK:int = 60*60*24*7;
		
		public function TimerHelper()
		{
			throw new Error('This is a static class.');
		}
		
		/**
		 * 建立一个定时器, 由 Timer 实现
		 * 
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
			// 执行  handler( params )
			var timerHandler:Function = function(event:TimerEvent):void
			{
				HandlerManager.execute(handler, params);
			};
			
			// 停止定时器, 并执行 compHandler( compParams )
			var timerCompleteHandler:Function = function(event:TimerEvent):void
			{
				destroy();
				HandlerManager.execute(compHandler, compParams);
			};
			
			var destroy:Function = function():void
			{
				if (timer) {
					timer.stop();
					timer.removeEventListener(TimerEvent.TIMER, timerHandler);
					timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteHandler);
					timer = null;
				}
			};
			
			var timer:Timer;
			timer = new Timer(delay, repeat);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteHandler);
			
			if (autoStart) {
				timer.start();
			}
			
			return new TimerData(timer, destroy);
		}
		
		/**
		 * 建立精准定时器, 由  TweenLite 内部实现
		 * @return TimerData 定时器数据Vo
		 */
		public static function createExactTimer(duration:Number, from:Number, to:Number, 
												updateHandler:Function=null, compHandler:Function=null, 
												updateStep:Number=0):TimerData
		{
			var obj:* = null;
			var i:Number;
			var absUpdateStep:Number;
			
			var onUpdate1:Function = function ():void
			{
				if (Math.abs((obj.i - i)) >= absUpdateStep) {
					i = obj.i;
					if (updateHandler != null) {
						updateHandler(obj.i);
					}
				}
			};
			
			var onUpdate2:Function = function ():void
			{
				if (updateHandler != null) {
					updateHandler(obj.i);
				}
			};
			
			var onComplete:Function = function ():void
			{
				if (updateHandler != null) {
					updateHandler(obj.i);
				}
				if (compHandler != null) {
					compHandler();
				}
			};
			
			var destroy:Function = function ():void
			{
				TweenLite.killTweensOf(obj);
			};
			
			obj = {i:from};
			var onUpdate:Function = updateStep != 0 ? onUpdate1 : onUpdate2;
			
			TweenLite.to(obj, duration, {
				i:to,
				onUpdate:onUpdate,
				onComplete:onComplete,
				ease:Linear.easeNone
			});
			
			i = from;
			
			absUpdateStep = Math.abs(updateStep);
			
			return new TimerData(null, destroy);
		}
		
		/**
		 * 解析服务器时间格式, 如果失败, 则返回默认的 0 值(1977年....)
		 * @param str 日期字符串
		 * @return Date
		 * 
		 */
		public static function parseTime(str:String):Date{
			var obj:Object = _timeRegExp.exec(str);
			if(!obj){
				var d:Date = new Date;
				d.time = 0;
				return d;
			}
			d = new Date(obj[1], obj[2] - 1, obj[3], obj[4], obj[5], obj[6]);
			return d;
		}
		
		/**
		 * 计算时间差，返回秒数 
		 * @param start
		 * @param end
		 * @return int 秒数
		 */
		public static function subtract(start:String, end:String):int
		{
			return int( (parseTime(end).getTime() - parseTime(start).getTime())/1000 );
		}
		
		// 格式化: 秒 -> 时分		// sec=秒数, hunit=小时单位, munit=分钟单位
		public static function fmt_sec_to_hm(sec:Number, hunit:String=null, munit:String=null):String{
			sec += 59;
			var h:int = sec / 3600;		
			sec %= 3600;
			var m:int = sec / 60;
			
			var str:String = "";
			if(h>0) str += "" + h + (hunit || '小时');
			if(m>0) str += "" + m + (munit || '分钟');
			if(str == "") str = "0" + (munit || '分钟');
			
			return str;
		}
		
		/**
		 * 格式化时间，返回Array[hourStr,minuteStr,secondStr]
		 * @param secnods秒数
		 * @return Array [hourStr,minuteStr,secondStr]
		 */
		public static function fmtSeond(secnods:int):Array
		{	
			var hourStr:String = '';
			var minuteStr:String = '';
			var secondStr:String = '';
			var hour:int;
			var minute:int;
			var second:int;
			minute = secnods / MIN;
			second = secnods % MIN;
			hour = secnods / HRS;
			minute = minute % MIN;
			if (hour == 0){
				hourStr = '00';
			}else{
				if(hour < 10){
					hourStr = '0'+hour; //补零
				}else{
					hourStr = ''+hour;
				}
			}
			if (minute == 0){
				minuteStr = '00';
			}else{
				if(minute < 10){
					minuteStr = '0'+minute;
				}else{
					minuteStr = ''+minute;
				}
			}
			if (second == 0){
				secondStr = '00';
			}else{
				if(second < 10){
					secondStr = '0'+second;
				}else{
					secondStr = ''+second;
				}
			}
			return [hourStr,minuteStr,secondStr];
		}
		
		/**
		 * 转换成 00:00:00 时间格式 
		 */
		public static function formatHMS(seconds:int):String
		{
			var arr:Array = fmtSeond(seconds);
			return arr[0] + ':' + arr[1] + ':' + arr[2];
		}
		
		/**
		 * 时间戳转换成Date对象 
		 */
		public static function transDate(num:Number):Date
		{
			return new Date(num*1000);
		}
		
		/**
		 * 获得客户端时间毫秒数
		 */
		public static function getTime():Number
		{
			var d:Date = new Date;
			return d.getTime();
		}
		
		/**
		 * 获得客户端时间秒数
		 */
		public static function getSecTime():Number
		{
			return int(getTime()/1000);
		}
		
		/**
		 * 获得客户端时间毫秒数
		 */
		public static function getMilliSecTime():Number
		{
			return getTime();
		}
		
	}
}