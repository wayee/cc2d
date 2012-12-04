package wit.loader
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;

	/**
	 * 加载器
	 * <li>可控制应用程序域, target 参数控制
	 * <li>可控制解压缩, decode 参数控制
	 * <p>对于压缩文件, 先用 UrlLoader 二进制加载, 然后解压, 然后用 Loader 加载
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class RslLoader extends EventDispatcher
	{
		public static const TARGET_CHILD:String = "child";
		public static const TARGET_SAME:String = "same";
		public static const TARGET_NEW:String = "new";
		
		public var loader:Loader;
		public var userData:Object;
		private var _urlLoader:URLLoader;
		private var _url:String;
		private var _target:String;
		private var _decode:Function;
		private var _context:LoaderContext;
		
		public function RslLoader()
		{
			loader = new Loader();
		}
		
		/**
		 * 加载 URL
		 * @param url URL地址
		 * @param target 记载到那个应用程序域
		 * @param decode 解压函数
		 */
		public function load(url:String, target:String="same", decode:Function=null):void
		{
			_url = url;
			_target = target;
			_decode = decode;
			_context = new LoaderContext();
			if (Security.sandboxType == Security.REMOTE) {
				_context.securityDomain = SecurityDomain.currentDomain;
			}
			
			switch (target) {
				// 应用程序域的子域
				case RslLoader.TARGET_CHILD:
					_context.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
					break;
				// 应用程序域
				case RslLoader.TARGET_SAME:
					_context.applicationDomain = ApplicationDomain.currentDomain;
					break;
				// 系统域
				case RslLoader.TARGET_NEW:
					_context.applicationDomain = new ApplicationDomain();
					break;
			}
			
			var req:URLRequest = new URLRequest(url);
			req.method = URLRequestMethod.POST;
			if (decode == null) {
				initLoadEvent();
				loader.load(req, _context);
			} else { // 需要加密，则加载二进制
				_urlLoader = _urlLoader || new URLLoader();
				_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				initUrlLoadEvent();
				_urlLoader.load(req);
			}
		}
		
		/**
		 * URLLoader 添加事件监听 
		 */
		private function initUrlLoadEvent():void
		{
			if (_urlLoader) {
				_urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
				_urlLoader.addEventListener(Event.COMPLETE, onUrlComplete);
				_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
				_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			}
		}
		
		/**
		 * URLLoader 删除事件监听 
		 */
		private function removeUrlLoadEvent():void
		{
			if (_urlLoader) {
				_urlLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				_urlLoader.removeEventListener(Event.COMPLETE, onUrlComplete);
				_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			}
		}
		
		/**
		 * Loader 添加事件监听 
		 */
		private function initLoadEvent():void
		{
			if (loader) {
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			}
		}
		
		/**
		 * Loader 删除事件监听 
		 */
		private function removeLoadEvent():void
		{
			if (loader) {
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			}
		}
		
		/**
		 * ULRLoader 加载完成 
		 * @param event
		 */
		private function onUrlComplete(event:Event):void
		{
			var byteArray:ByteArray = event.currentTarget.data;
			if (_decode != null) {
				byteArray = _decode(byteArray);			// 解压
			}
			byteArray.position = 0;
			loader = loader || new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_context.securityDomain = null;
			loader.loadBytes(byteArray, _context);
		}
		
		/**
		 * Loader 加载完成 
		 * @param event
		 */
		private function onComplete(event:Event):void
		{
			removeUrlLoadEvent();
			removeLoadEvent();
			dispatchEvent(event);
		}
		
		private function onProgress(event:ProgressEvent):void
		{
			dispatchEvent(event);
		}
		
		private function onError(event:Event):void
		{
			removeUrlLoadEvent();
			removeLoadEvent();
			dispatchEvent(event);
		}
	}
}