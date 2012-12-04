package wit.net
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * Http 连接类
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class CJSONHttp implements IConnection
	{
		public function CJSONHttp(host:String, method:String='', port:int=80)
		{
			_host = host;
			_port = port;
			_method = method ? method : URLRequestMethod.POST;
			
			_urlVars = new URLVariables;
			_loader = new URLLoader;
		}
		
		public function request(obj:Object, compress:Boolean = true):void
		{
			var param:CRequestParam = obj as CRequestParam;
			var host:String = _host;
			if (_host.substr(_host.length-1) == '/') {
				host = _host.substr(0, _host.length-1);
			}
			host = _host.indexOf('http://') == -1 ? 'http://' + host : host;
			host = _port==80 ? host : host + ':' + _port;
			host += '/';
			
			var urlRequest:URLRequest = new URLRequest(host + param.url);
			_urlVars.req_str = JSON.encode(param);
			
			if (compress) {
				// TODO: 压缩
			}
			
			urlRequest.data = _urlVars;
			
			_loader.dataFormat = URLLoaderDataFormat.TEXT;
//			_loader.dataFormat = URLLoaderDataFormat.BINARY;
//			_loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_loader.addEventListener(Event.COMPLETE, onComplete);
			
			_loader.load(urlRequest);
		}
		
		private function onComplete(event:Event):void
		{
			var jsonData:Object = JSON.decode( URLLoader(event.target).data );
			_onResponse(jsonData);
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			trace( "Load failed: IO error: " + event.text );
		}
		private function onHttpStatus(event:HTTPStatusEvent):void
		{
			trace( "Load failed: HTTP Status = " + event.status );
		}
		private function onSecurityError(event:SecurityErrorEvent):void
		{
			trace( "Load failed: Security Error: " + event.text );
		}

		public function set onResponse(value:Function):void
		{
			_onResponse = value;
		}

		public function set onConnect(value:Function):void
		{
			_onConnect = value;
		}
		
		private var _loader:URLLoader;
		private var _host:String;
		private var _port:int;
		private var _method:String;
		private var _urlVars:URLVariables;
		private var _onConnect:Function;
		private var _onResponse:Function;

	}
}