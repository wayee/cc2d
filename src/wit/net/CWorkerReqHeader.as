package wit.net
{
	/**
	 * @author lei.zhang@kunlun-inc.com
	 */
	public class CWorkerReqHeader 
	{		
		/// 消息头大小
		public static const SIZE:int = 18;

		public var m_fd:int      		= 0; // 套接字
		public var m_remote_ip:int   	= 0; // 套接字远端ip
		public var m_remote_port:int 	= 0; // 套接字远端端口
		public var m_date:int        	= 0; // 套接字创建时间
		public var m_method_id:int   	= 0; // 方法id
		public var m_flag:int           = 0; // 数据是否压缩
	} // class end
} // pack end
