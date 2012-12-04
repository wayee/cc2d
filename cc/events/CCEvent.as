package cc.events
{
	import flash.events.Event;

	/**
	 * 场景角色对象动作事件
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class CCEvent extends Event
	{
        public static const INTERACTIVE:String = "CCEvent.interactive";
        public static const WALK:String = "CCEvent.walk";
        public static const STATUS:String = "CCEvent.status";
        public static const PROCESS:String = "CCEvent.process";

		private var action:String;
		private var data:Object;
		
		/**
		 * 场景事件类 
		 * @param type 事件类型
		 * @param action 事件动作
		 * @param data 事件数据
		 * @param bubbles 是否冒泡
		 * @param cancelable 否可以阻止与事件相关联的行为
		 * 
		 */
        public function CCEvent(type:String, action:String="", data:Object=null, 
								bubbles:Boolean=false, cancelable:Boolean=false) {
            super(type, bubbles, cancelable);
			
			this.action = action;
			this.data = data;
        }
		
		public function get Data():Object {
			return data;
		}
		
		public function get Action():String {
			return action;
		}
		
        override public function clone():Event {
            return new CCEvent(type, action, data, bubbles, cancelable);
        }
		
        override public function toString():String {
            return "[CCEvent]";
        }
    }
}