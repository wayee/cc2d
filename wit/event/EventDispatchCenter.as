package wit.event
{
	import flash.events.EventDispatcher;

	/**
	 * 事件派发中心
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class EventDispatchCenter extends EventDispatcher
	{
		private static var _instance:EventDispatchCenter;
		
		public function EventDispatchCenter()
		{
			if (_instance != null) {
				throw new Error('This is a singleton class.');
			}
			_instance = this;
		}
		
		public static function getInstance():EventDispatchCenter
		{
			if (_instance == null) {
				_instance = new EventDispatchCenter();
			}
			return _instance;
		}
	}
}