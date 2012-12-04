package wit.event
{
	import flash.events.Event;

	/**
	 * 自定义事件基类
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class BaseEvent extends Event
	{
        public static const INIT_COMPLETE:String = "BaseEvent.initComplete";
        public static const UPDATE:String = "BaseEvent.update";
        public static const COMPLETE:String = "BaseEvent.complete";

        public var action:String;
        public var data:Object;

		/**
		 * 事件基类，加入数据对象和行为参数 
		 * @param type 事件类型
		 * @param action 事件动作
		 * @param data 事件数据
		 * @param bubbles 是否冒泡
		 * @param cancelable 否可以阻止与事件相关联的行为
		 * 
		 */
        public function BaseEvent(type:String, action:String="", data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
            super(type, bubbles, cancelable);
			
            this.action = action;
            this.data = data;
        }
        
		override public function clone():Event
		{
            return new BaseEvent(type, this.action, this.data, bubbles, cancelable);
        }
        
		override public function toString():String
		{
            return "[BaseEvent]";
        }

    }
}