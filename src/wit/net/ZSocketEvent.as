package wit.net
{
	import flash.events.Event;
	
	import wit.event.BaseEvent;

	/**
	 * Socket自定义事件
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class ZSocketEvent extends BaseEvent
	{
        public static const LOGIN_SUCCESS:String = "ZSocketEvent..loginSuccess";
        public static const LOGIN_FAILURE:String = "ZSocketEvent..loginFailure";
        public static const CLOSE:String = "ZSocketEvent..close";

		
        public function ZSocketEvent(type:String, action:String="", data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
            super(type, action, data, bubbles, cancelable);
        }
		
        override public function clone():Event
		{
            return new ZSocketEvent(type, action, data, bubbles, cancelable);
        }
		
        override public function toString():String
		{
            return ("[ZSocketEvent]");
        }
    }
}