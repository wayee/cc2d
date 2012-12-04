package wit.net
{
	import com.adobe.serialization.json.JSON;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * Socket 连接器
	 * 
	 * @author lei.zhang@globalnet-inc.com
	 */
	public class CJSONSocket extends Socket implements IConnection
	{
		private static const PROXY_REG_METHOD_ID:int  = 1;  /// 登录后需调注册方法
		private static const PROXY_REQ_METHOD_ID:int  = 3;  /// proxy的req方法id
		private static const WORKER_REQ_METHOD_ID:int = 1;  /// worker的req方法id
		
		private static const PROXY_GROUP_TYPE:int = 0;  /// proxy所属的组类型id
		private static const CLIENT_GROUP_ID:int = 1;   /// client在proxy定义的组类型中的组id
		
		/// 读取数据阶段枚举
		private static const READ_SCT_HEADER:int = 0x0001;
		private static const READ_DATA:int       = 0x0002;
		
		// 字节顺序
		static public const ENDIAN:String			= Endian.LITTLE_ENDIAN;
//		static public const ENDIAN:String			= Endian.BIG_ENDIAN;
		
		private var m_sct_header:CSctHeader = new CSctHeader;
		private var m_read_stat:int         = READ_SCT_HEADER;
		private var m_host:String           = new String;
		private var m_port:int              = 0;
		private var _compress:Boolean;
		private var _isConnecting:Boolean	= false;
		
		/// 上层回调方法
		private var _onError:Function    = null;		// funciton(string):void;
		private var _onConnect:Function  = null;		// function():void;
		private var _onResponse:Function = null;		// function(object):void;
		
		public function CJSONSocket( host:String = null, port:int = 0 ) 
		{
//			Security.loadPolicyFile("xmlsocket://" + host + ":" + 8006); 
			endian = ENDIAN;
			add_listener();
			m_host     = host;
			m_port     = port;
	        super(m_host, m_port);
    	}
		
		private function get_str_bytes( str:String ):int
		{
			var buff:ByteArray = new ByteArray();
			buff.writeMultiByte( str, "utf-8" );
			return buff.length;
		}
		
		private function simulate_http():void
		{
			try
			{
				// GET / HTTP/1.1
				// tgw_l7_forward\r\nHost: app12345-54321.qzoneapp.com:8002\r\n\r\n 
//				var http_head:String = "GET / HTTP/1.1\r\nHost:" + m_host + ":" + m_port + "\r\n\r\n";
				var http_head:String = "tgw_l7_forward\r\nHost:" + m_host + ":" + m_port + "\r\n\r\n";
				writeUTFBytes( http_head );
				flush();
			}
			catch(e:IOError)
			{
				trace(e);
			}			
		}
		
		private function reg():void
		{
	        try
	        {
	        	var total_size:int = CSctHeader.SIZE + CProxyRegHeader.SIZE;
	        	write_sct_header( total_size );
	        	write_proxy_reg_header();
	            flush();
	        }
	        catch(e:IOError)
	        {
	            trace(e);
	        }
		}		
		
		/**
		 * 重连 
		 */
		public function reconnect():void
		{
			this.connect(m_host, m_port);
		}

		/**
		 * 发送请求
		 */
	    public function request( obj:Object, compress:Boolean = true ):void
		{
			_compress = compress;
			
			if (_isConnecting === false) {
//				throw new Error('Please check whether or not socket connected.');
				dispatchEvent(new CNetEvent(CNetEvent.SOCKET_DISCONNECT));
				return;
			}
			
			var data:String        = JSON.encode( obj );
			var cookie:String      = obj['act'];
			var zip_data:ByteArray = new ByteArray();
			var data_len:int       = this.get_str_bytes( data );
			var cookie_len:int     = this.get_str_bytes( cookie );
			if( compress )
			{
				zip_data.writeUTFBytes(data);
				zip_data.compress();
				data_len = zip_data.length;
			}
			
	        var total_size:int = CSctHeader.SIZE + CProxyReqHeader.SIZE 
									+ CWorkerReqHeader.SIZE + data_len + cookie_len;

			var now:Date = new Date();
			trace("bin_connect", "request", "[", now.toDateString(), now.toTimeString(), "]", data );
	        try
	        {
	        	write_sct_header( total_size );
				write_proxy_req_header( cookie );
				write_worker_req_header(compress);
				if( compress )
					writeBytes( zip_data );
				else
					writeUTFBytes( data );
	            flush();
	        }
	        catch(e:IOError)
	        {
	            trace(e);
	        }
		}
    	
    	private function add_listener():void
    	{
    		addEventListener(Event.CLOSE, on_close);
	        addEventListener(Event.CONNECT, on_connect);
	        addEventListener(IOErrorEvent.IO_ERROR, on_err);
	        addEventListener(SecurityErrorEvent.SECURITY_ERROR, on_security_err);
	        addEventListener(ProgressEvent.SOCKET_DATA, on_read);
    	}
	
		private function write_sct_header( size:int ):void
		{
			writeUnsignedInt(size);
		}
		
		private function write_proxy_reg_header():void
		{
			writeShort( PROXY_REG_METHOD_ID );
			var group_num:int = 1; /// 注册的组个数
			var fd:int=0;
			writeUnsignedInt( fd );
			writeShort( group_num );
			writeShort( PROXY_GROUP_TYPE );
			writeUnsignedInt(CLIENT_GROUP_ID);
		}

		private function write_proxy_req_header( cookie:String ):void
		{
			writeShort( PROXY_REQ_METHOD_ID );
			writeShort( this.get_str_bytes( cookie ) );
			writeUTFBytes( cookie );
		}
		
		private function write_worker_req_header(compress:Boolean):void
		{
			writeUnsignedInt(0);
			writeUnsignedInt(0);
			writeShort(0);
			writeUnsignedInt(0);
			writeShort( WORKER_REQ_METHOD_ID );
			if( compress )
				writeShort( 1 );
			else
				writeShort( 0 );
		}
		
	    private function on_connect(event:Event):void 
	    {
	        trace("connectHandler: " + event);
			
			// 模拟http头部，用于通过腾讯的端口，服务器会忽略该内容
			simulate_http();
			
			// 注册包
	        reg();
			_isConnecting = true;
			if( _onConnect != null ) _onConnect();
	    }
	    
        private function on_close(event:Event):void 
        {
	        trace("closeHandler: " + event);
			_isConnecting = false;
			dispatchEvent(new CNetEvent(CNetEvent.SOCKET_DISCONNECT));
	    }
	
	    private function on_err(event:IOErrorEvent):void 
	    {
	        trace("ioErrorHandler: " + event);
	    }
	
	    private function on_security_err(event:SecurityErrorEvent):void 
	    {
	        trace("securityErrorHandler: " + event);
	    }
	
	    private function on_read(event:ProgressEvent):void 
	    {
	      	trace( "bin_connect, on_read", bytesAvailable );
  
  			while(1)
  			{
  				switch( m_read_stat )
	        	{
	        	case READ_SCT_HEADER:
	        		if( bytesAvailable >= CSctHeader.SIZE )
	        		{
						var head:uint = readUnsignedInt();
//						m_sct_header.m_size  = ( head >> 8 ) & 0x00FFFFFF;
//						m_sct_header.m_isZip = head & 0x000000FF;
						m_sct_header.m_size  = head & 0x00FFFFFF;
						m_sct_header.m_isZip = ( head >> 24 ) & 0x000000FF;
						if( !m_sct_header.is_valid() )
						{
							trace("bytesAvailable:", bytesAvailable);
							trace( "sct head is invalid, close!" );
							close();
							return;
						}
	        			if( m_sct_header.m_size <= CSctHeader.SIZE )
	        			{
	        				trace( "head size is invalid, close!" );
							close();
							return;
	        			}						
						m_read_stat = READ_DATA;
					}
					else {
						return;
					}
	        	case READ_DATA:
	        		if( bytesAvailable + CSctHeader.SIZE >= m_sct_header.m_size )
	        		{
	        			var data:ByteArray = new ByteArray;
						data.endian        = this.endian;
	        			var data_size:int  = m_sct_header.m_size - CSctHeader.SIZE;
	        			readBytes( data, 0, data_size );
						
						if (m_sct_header.m_isZip == 1) {
							data.uncompress();
						}
						var dataString:String = String(data);
						
						trace("bin_connect", "response:" + dataString );		
						var obj:Object = JSON.decode(dataString);
						
		        		_onResponse( JSON.decode( dataString ) );
	        			m_read_stat = READ_SCT_HEADER;
	        		}
	        		else {
	        			return;
					}
					break;
	        	}
  			}
  		}

		public function set onConnect(value:Function):void
		{
			_onConnect = value;
		}

		public function set onResponse(value:Function):void
		{
			_onResponse = value;
		}

		public function set onError(value:Function):void
		{
			_onError = value;
		}

		public function get isConnecting():Boolean
		{
			return _isConnecting;
		}
	    
	} // class end
} // pack end
