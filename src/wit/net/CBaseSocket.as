package wit.net
{     
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.ObjectEncoding;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.ByteArray;
	
	
	/**
	 * Socket 类
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class CBaseSocket extends EventDispatcher
	{  
		private var _host:String;  
		private var _port:uint;  
		private var _socket:Socket;  
		
		public function CBaseSocket(host:String, port:uint=80)
		{  
			this._host = host;  
			this._port = port;
			this._socket = new Socket();  
			this._socket.objectEncoding = ObjectEncoding.AMF3;            
			Security.loadPolicyFile("xmlsocket://" + this.host + ":" + this.port);  
			this._socket.addEventListener(Event.CONNECT, handler);  
			this._socket.addEventListener(Event.CLOSE, handler);  
			this._socket.addEventListener(IOErrorEvent.IO_ERROR, handler);  
			this._socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handler);  
			this._socket.addEventListener(ProgressEvent.SOCKET_DATA, handler);  
		}  
		
		public function get host():String
		{  
			return _host;  
		}  
		
		public function get port():uint
		{  
			return _port;  
		}  
		
		public function get connected():Boolean
		{  
			return this._socket.connected;  
		}  
		
		public function connect():void
		{  
			this._socket.connect(host, port);  
		}  
		
		public function close():void
		{  
			this._socket.close();  
		}  
		
		public function send(params:Object=null):void
		{  
			if(!this.connected || params == null){  
				return;  
			}  
			var bytes:ByteArray = new ByteArray();  
			bytes.writeObject(params);  
			bytes.compress();  
			this._socket.writeBytes(bytes);  
			this._socket.flush();  
			this.dispatchEvent(new CBaseSocketEvent(CBaseSocketEvent.SENDING, params));             
		}  
		
		private function received():void
		{                
			var bytes:ByteArray = new ByteArray();  
			while (this._socket.bytesAvailable > 0) {  
				this._socket.readBytes(bytes, 0, this._socket.bytesAvailable);  
			}  
			try{                  
				bytes.uncompress();  
				this.dispatchEvent(new CBaseSocketEvent(CBaseSocketEvent.RECEIVED, bytes.readObject()));  
			}catch (error:Error) {  
				this.dispatchEvent(new CBaseSocketEvent(CBaseSocketEvent.DECODE_ERROR));  
			}  
		}  
		
		private function handler(event:Event):void
		{  
			switch(event.type) {  
				case Event.CLOSE:  
					this.dispatchEvent(new CBaseSocketEvent(CBaseSocketEvent.CLOSE));  
					break;  
				case Event.CONNECT:                   
				case IOErrorEvent.IO_ERROR:  
				case SecurityErrorEvent.SECURITY_ERROR:  
					this.dispatchEvent(new CBaseSocketEvent(event.type));  
					break;  
				case ProgressEvent.SOCKET_DATA:  
					this.received();  
					break;  
			}  
		}  
	} 
}