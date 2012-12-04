package wit.event
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * 时间派发助手
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class EventDispatchHelper
	{
        private static var _eventDispatchCenter:EventDispatchCenter = EventDispatchCenter.getInstance();

        public function EventDispatchHelper()
		{
            throw new Error('This is a static class');
        }
		
        public static function dispatchEvent(event:Event, eventDispatcher:EventDispatcher=null):void
		{
            var dispatcher:EventDispatcher = eventDispatcher || _eventDispatchCenter;
			dispatcher.dispatchEvent(event);
        }
    }
}