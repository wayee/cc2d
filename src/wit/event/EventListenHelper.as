package wit.event
{
	import flash.events.EventDispatcher;

	/**
	 * 事件监听助手
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class EventListenHelper
	{
        private static var _eventDispatchCenter:EventDispatchCenter = EventDispatchCenter.getInstance();

        public function EventListenHelper()
		{
            throw new Error('This is a static class.');
        }
		
		/**
		 * 监听事件
		 * @param type 事件的类型
		 * @param listener 处理事件的侦听器函数
		 * @param dispatcher 事件发送器
		 * @param useCapture 定侦听器是运行于捕获阶段、目标阶段还是冒泡阶段
		 * @param priority 事件侦听器的优先级，数字越大，优先级越高
		 * @param useWeakReference 确定对侦听器的引用是强引用，还是弱引用
		 */
        public static function addEvent(type:String, listener:Function, dispatcher:EventDispatcher=null, 
										useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
            var eventDispatcher:EventDispatcher = dispatcher || _eventDispatchCenter;
            eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
		
		/**
		 * 移除事件监听 
		 */
        public static function removeEvent(type:String, listener:Function, dispatcher:EventDispatcher=null, 
										   useCapture:Boolean=false):void
		{
            var eventDispatcher:EventDispatcher = dispatcher || _eventDispatchCenter;
            eventDispatcher.removeEventListener(type, listener, useCapture);
        }
		
		/**
		 * 是否存在事件监听 
		 */
        public static function hasEvent(type:String, dispatcher:EventDispatcher=null):Boolean
		{
            var eventDispatcher:EventDispatcher = dispatcher || _eventDispatchCenter;
            return (eventDispatcher.hasEventListener(type));
        }
		
		/**
		 * 检查是否用此 EventDispatcher 对象或其任何始祖为指定事件类型注册了事件侦听器 
		 * @param type
		 * @param dispatcher
		 * @return bool
		 */
        public static function willTrigger(type:String, dispatcher:EventDispatcher=null):Boolean
		{
            var eventDispatcher:EventDispatcher = dispatcher || _eventDispatchCenter;
            return eventDispatcher.willTrigger(type);
        }
    }
}