package wit.manager
{
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.system.ApplicationDomain;
	
	import wit.loader.LoadData;
	import wit.loader.RslLoader;
	import wit.log.Log4a;

	/**
	 * RSL 加载器管理
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class RslLoaderManager
	{
		private static var rslLoaderArr:Array = [];	// [RslLoader, ...]
		
		public function RslLoaderManager()
		{
			throw new Error("This is a static class.");
		}
		
		/**
		 * 反射获取类对象 
		 * @param className string 类名
		 * @param loaderInfo
		 */
		public static function getClass(className:String, loaderInfo:LoaderInfo=null):Class
		{
			if (className == null || className == "") {
				return null;
			}
			if (loaderInfo == null && ApplicationDomain.currentDomain.hasDefinition(className)) {
				return ApplicationDomain.currentDomain.getDefinition(className) as Class;
			}
			if (loaderInfo && loaderInfo.applicationDomain.hasDefinition(className)) {
				return loaderInfo.applicationDomain.getDefinition(className) as Class;
			}
			Log4a.Debug("RslLoaderManager.getClass: 类“" + className + "”不存在");
			return null;
		}
		
		/**
		 * 反射获取类的实例 
		 * @param className string 类名
		 * @param args
		 */
		public static function getInstance(className:String, ...args):Object
		{
			var cls:Class = getClass(className);
			var instance:Object = getInstanceByClass(cls, args);
			return instance;
		}
		
		/**
		 * 建立一个对象（注意：请不要使用构造函数参数超过15个的类，那是火星人才会这样做）
		 * @param cls 对象类
		 * @param arr 参数数组
		 */
		public static function getInstanceByClass(cls:Class, arr:Array):Object
		{
			var instance:Object;
			if (cls == null) {
				return null;
			}
			var num:int = (arr) ? arr.length : 0;
			switch (num){
				case 0:
					instance = new (cls)();
					break;
				case 1:
					instance = new cls(arr[0]);
					break;
				case 2:
					instance = new cls(arr[0], arr[1]);
					break;
				case 3:
					instance = new cls(arr[0], arr[1], arr[2]);
					break;
				case 4:
					instance = new cls(arr[0], arr[1], arr[2], arr[3]);
					break;
				case 5:
					instance = new cls(arr[0], arr[1], arr[2], arr[3], arr[4]);
					break;
				case 6:
					instance = new cls(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5]);
					break;
				case 7:
					instance = new cls(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6]);
					break;
				case 8:
					instance = new cls(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6], arr[7]);
					break;
				case 9:
					instance = new cls(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6], arr[7], arr[8]);
					break;
				case 10:
					instance = new cls(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6], arr[7], arr[8], arr[9]);
					break;
				case 11:
					instance = new cls(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6], arr[7], arr[8], arr[9], arr[10]);
					break;
				case 12:
					instance = new cls(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6], arr[7], arr[8], arr[9], arr[10], arr[11]);
					break;
				case 13:
					instance = new cls(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6], arr[7], arr[8], arr[9], arr[10], arr[11], arr[12]);
					break;
				case 14:
					instance = new cls(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6], arr[7], arr[8], arr[9], arr[10], arr[11], arr[12], arr[13]);
					break;
				case 15:
					instance = new cls(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6], arr[7], arr[8], arr[9], arr[10], arr[11], arr[12], arr[13], arr[14]);
					break;
			}
			return instance;
		}
		
		/**
		 * 普通加载 
		 * @param loadDataArr [LoadData, ...]
		 * @param callback Function
		 */
		public static function load(loadDataArr:Array, callback:Function=null):void
		{
			if (!loadDataArr || loadDataArr.length == 0) {
				if (callback != null) {
					callback();
				}
				return;
			}
			loadNext(null, loadDataArr, callback);
		}
		
		/**
		 * 简单加载 
		 * @param callback callback(loadData, event);
		 * @param args [url1, url2, ...]
		 */
		public static function lazyLoad(callback:Function=null, ...args):void
		{
//			if ( Rsl.hasLoadedSwf(String(args)) ) {
//				if (callback != null) callback(args);
//				return ;
//			}
			// 没提供url参数，直接执行回调函数，然后退出
			if (!args || args.length == 0) {
				if (callback != null) {
					callback();
				}
				return;
			}
			// (item:*, index:int, array:Array)
			var loadList:Array = args.map(function(url:*, index:int, arr:Array):LoadData
			{
				return new LoadData(String(url), null, null, null, "", "", RslLoader.TARGET_SAME, 0);
			});
			
			load(loadList, callback);
		}
		
		/**
		 * 加载下一个资源 
		 * @param loader
		 * @param loadDataArr array [Loaddata, ...]
		 * @param callback Function
		 */
		private static function loadNext(loader:RslLoader, loadDataArr:Array, callback:Function):void
		{
			var index:int;
			if (loadDataArr.length == 0) {
				if (loader) {
					index = rslLoaderArr.indexOf(loader);
					if (index != -1){
						rslLoaderArr.splice(index, 1);	// 删除当前RslLoader
					}
				}
				return;
			}
			
			var loadData:LoadData = loadDataArr.shift() as LoadData;
			if (loadData) {
				if (!loader) {
					loader = new RslLoader();
					rslLoaderArr[rslLoaderArr.length] = loader;
				}
				loadData.userData = {loadInfo:loader.loader.contentLoaderInfo};
				
				initLoadEvent(loader);
				
				// 当前下载完需要loadNext，做为参数， see simpleLoaderHandler
				loader.userData = [loadDataArr, callback, loadData]; 
				
				loader.load(loadData.url, loadData.target, loadData.decode);
				
			} else {
				loadNext(loader, loadDataArr, callback);
			}
		}
		
		/**
		 * 添加事件监听 
		 */
		private static function initLoadEvent(loader:RslLoader):void
		{
			if (!loader) {
				return;
			}
			loader.addEventListener(Event.COMPLETE, simpleLoaderHandler);
			loader.addEventListener(ProgressEvent.PROGRESS, simpleLoaderHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, simpleLoaderHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, simpleLoaderHandler);
		}
		
		/**
		 * 清除事件监听 
		 */
		private static function removeLoadEvent(loader:RslLoader):void
		{
			if (!loader) {
				return;
			}
			loader.removeEventListener(Event.COMPLETE, simpleLoaderHandler);
			loader.removeEventListener(ProgressEvent.PROGRESS, simpleLoaderHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, simpleLoaderHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, simpleLoaderHandler);
		}
		
		/**
		 * 事件处理 
		 */
		private static function simpleLoaderHandler(event:Event):void
		{
			// loader.userData = [loadDataArr, callback, loadData]
			var loader:RslLoader = event.target as RslLoader;
			var loadDataArr:Array = (loader.userData as Array)[0] as Array;
			var callback:Function = (loader.userData as Array)[1] as Function;
			var loadData:LoadData = (loader.userData as Array)[2] as LoadData;
			if (event.type == null) {
				return;
			}
			
			switch (event.type) {
				case Event.COMPLETE:
					if (callback != null) {
						callback(loadData, event);
					}
					removeLoadEvent(loader);
					loadNext(loader, loadDataArr, callback);
					break;
				case ProgressEvent.PROGRESS:
					if (loadData.onUpdate != null) {
						loadData.onUpdate(loadData, event);
					}
					break;
				case IOErrorEvent.IO_ERROR:
				case SecurityErrorEvent.SECURITY_ERROR:
					Log4a.Fatal("RslLoaderManager: 加载" + loadData.url + "失败");
					if (loadData.onError != null) {
						loadData.onError(loadData, event);
					}
					removeLoadEvent(loader);
					loadNext(loader, loadDataArr, callback);
					break;
			}
		}
	}
}