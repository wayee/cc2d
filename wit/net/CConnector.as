package wit.net
{
	import wit.utils.Singleton;

	/**
	 * 连接管理器
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class CConnector extends Singleton
	{
		public static function get instance():CConnector
		{
			return Singleton.getInstanceOrCreate(CConnector) as CConnector;
		}
		
		public function connect(conn:IConnection):void
		{
			_conn = conn;
			_conn.onConnect = CRequestor.instance.onConnect;
			_conn.onResponse = CResponder.instance.onResponse;
		}
		
		public function get conn():IConnection
		{
			return _conn;
		}
		
		private var _conn:IConnection;
	}
}