package wit.manager
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import wit.event.EventDispatchHelper;
	import wit.event.EventListenData;
	import wit.event.EventListenHelper;
	import wit.log.Log4a;

	/**
	 * 事件管理器 
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class EventManager
	{
		private static var _eventArr:Array = [];
		
		public function EventManager()
		{
			throw new Error('This is a static class.');
		}
		
		/**
		 * 触发事件 
		 */
		public static function dispatchEvent(event:Event, eventDispatcher:EventDispatcher=null):void
		{
			EventDispatchHelper.dispatchEvent(event, eventDispatcher);
		}
		
		/**
		 * 添加事件监听 
		 */
		public static function addEvent(type:String, listener:Function, eventDispatcher:EventDispatcher=null, 
										useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if (hasSameEvent(type, listener, eventDispatcher, useCapture, priority, useWeakReference)){
				return;
			}
			_eventArr[_eventArr.length] = new EventListenData(type, listener, eventDispatcher, useCapture, priority, useWeakReference);
			Log4a.Info("EventManager.addEvent::_eventArr.length:" + getEventsNum());
			EventListenHelper.addEvent(type, listener, eventDispatcher, useCapture, priority, useWeakReference);
		}
		
		/**
		 * 删除事件监听 
		 */
		public static function removeEvent(type:String, listener:Function, eventDispatcher:EventDispatcher=null, useCapture:Boolean=false):void
		{
			var eventData:EventListenData;
			for each (eventData in _eventArr) {
				if (eventData.type == type && eventData.listener == listener && 
					eventData.dispatcher == eventDispatcher && eventData.useCapture == useCapture) {
					_eventArr.splice(_eventArr.indexOf(eventData), 1);
					Log4a.Info("EventManager.removeEvent::_eventArr.length:" + getEventsNum());
					break;
				}
			}
			EventListenHelper.removeEvent(type, listener, eventDispatcher, useCapture);
		}
		
		public static function hasEvent(type:String, eventDispatcher:EventDispatcher=null):Boolean
		{
			return EventListenHelper.hasEvent(type, eventDispatcher);
		}
		
		public static function willTrigger(type:String, eventDispatcher:EventDispatcher=null):Boolean
		{
			return EventListenHelper.willTrigger(type, eventDispatcher);
		}
		
		/**
		 * 事件监听数量 
		 */
		public static function getEventsNum():int
		{
			return _eventArr.length;
		}
		
		/**
		 * 获取事件发送器的事件数量
		 * @param eventDispatcher
		 * @return int 次数
		 */
		public static function getEventsNumByDispatcher(eventDispatcher:EventDispatcher):int
		{
			var eventData:EventListenData;
			var num:int;
			for each (eventData in _eventArr) {
				if (eventData.dispatcher == eventDispatcher){
					num++;
				}
			}
			return num;
		}
		
		/**
		 * 批量监听事件 
		 */
		public static function addEvents(events:Array, listener:Function, eventDispatcher:EventDispatcher=null, 
										 useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			var type:String;
			if (!events || events.length == 0) {
				return;
			}
			
			for each (type in events) {
				addEvent(type, listener, eventDispatcher, useCapture, priority, useWeakReference);
			}
		}
		
		/**
		 * 批量删除事件监听 
		 */
		public static function removeEvents(events:Array, listener:Function, eventDispatcher:EventDispatcher=null, 
											useCapture:Boolean=false):void
		{
			var type:String;
			if (!events || events.length == 0) {
				return;
			}
			
			for each (type in events) {
				removeEvent(type, listener, eventDispatcher, useCapture);
			}
		}
		
		/**
		 * 删除所有的事件监听
		 */
		public static function removeAllEvents():void
		{
			var eventData:EventListenData;
			for each (eventData in _eventArr) {
				EventListenHelper.removeEvent(eventData.type, eventData.listener, eventData.dispatcher, eventData.useCapture);
			}
			_eventArr = [];
			trace("EventManager.removeAllEvents::_eventArr.length:0");
		}
		
		/**
		 * 根据发送器EventDispatcher来删除事件监听 
		 */
		public static function removeEventsByDispatcher(dispatcher:EventDispatcher):void
		{
			var index:int;
			var eventData:EventListenData;
			index = 0;
			while (index < _eventArr.length) {
				eventData = _eventArr[index];
				if (eventData.dispatcher == dispatcher) {
					EventListenHelper.removeEvent(eventData.type, eventData.listener, eventData.dispatcher, eventData.useCapture);
					_eventArr.splice(index, 1);
				}
				index++;
			}
			Log4a.Info("EventManager.removeEventsByDispatcher::_eventArr.length:" + getEventsNum());
		}
		
		/**
		 * 是否有相同的事件 
		 */
		public static function hasSameEvent(type:String, listener:Function, eventDispatcher:EventDispatcher=null, 
											useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):Boolean
		{
			var eventData:EventListenData;
			var b:Boolean;
			for each (eventData in _eventArr) {
				if (eventData.equals(type, listener, eventDispatcher, useCapture, priority, useWeakReference)){
					b = true;
					break;
				}
			}
			return b && hasEvent(type);
		}
	}
}