package wit.net
{
	import wit.utils.Singleton;

	/**
	 * 请求管理器 
	 * 
	 * @author Andy Cai
	 * @version $Id$
	 * 
	 */
	public class CRequestor extends Singleton
	{
		
		public static function get instance():CRequestor
		{
			return Singleton.getInstanceOrCreate(CRequestor) as CRequestor;
		}
		
		public function onConnect():void
		{
			// TODO: Socket 连接后做初始化工作
			// 例如链接后可以请求所有登录后的初始化数据，角色基本信息，当前场景信息等
			
			dispatchEvent(new CNetEvent(CNetEvent.CONNECT_COMPLETED));
			
//			if (_data != null)
//				send(_data, _compress)
		}
		
		public function setSendingHandler(value:CRequestParam, compress:Boolean = false):void
		{
			_data = value;
			_compress = compress;
		}
		
		/**
		 * 支持 socket 和 http 
		 * @param value
		 * @param compress
		 * 
		 */		
		public function send(value:Object, compress:Boolean = false):void
		{
			// value = {'act': String, 'param': Object}
			CConnector.instance.conn.request(value, compress);
			_data = null;
		}
		
		private var _data:CRequestParam;
		private var _compress:Boolean;
	}
}