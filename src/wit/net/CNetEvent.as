package wit.net
{
	import flash.events.Event;
	
	/**
	 * 这个就是传说中的网络回报事件，简称NE，NB差远了
	 * 网络层事件:连接成功、响应成功等
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * @version $Id$
	 * 
	 */
	public class CNetEvent extends Event
	{
		public static const NAME:String						= 'CNetEvent 2011-8-30'; 
		public static const CONNECT_COMPLETED:String		= NAME + 'CONNECT_COMPLETED'; 
		public static const RESPONSE_TO_MODEL:String		= NAME + 'RESPONSE_TO_MODEL'; 
		public static const SOCKET_DISCONNECT:String		= NAME + 'SOCKET_DISCONNECT'; 
		
		private var _data:Object;
		
		public function CNetEvent(type:String, data:Object = null)
		{
			super(type, false, false);
			
			_data = data;
		}

		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}

	}
}