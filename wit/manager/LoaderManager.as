package wit.manager
{
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	
	import wit.loader.LoadData;
	
	/**
	 * 一个BulkLoader加载器的封装和管理 
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class LoaderManager
	{
        private static var _defaultLoader:BulkLoader = new BulkLoader("default");

        public function LoaderManager()
		{
            throw new Error('This is a static class.');
        }
		
		/**
		 * 创建一个加载器 
		 * @param name 加载器的名称
		 * @param completeHandler
		 * @param progressHandler
		 * @param errorHandler
		 * @param numConnections
		 * @param logLevel
		 * @return BulkLoader
		 */
        public static function creatNewLoader(name:String, completeHandler:Function=null, 
											  progressHandler:Function=null, errorHandler:Function=null, 
											  numConnections:int=7, logLevel:int=4):BulkLoader
		{
            var bLoader:BulkLoader = new BulkLoader(name, numConnections, logLevel);
            if (completeHandler != null){
                bLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
            }
			
            if (progressHandler != null) {
                bLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
            }
			
            if (errorHandler != null) {
                bLoader.addEventListener(BulkLoader.ERROR, errorHandler);
                bLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            }
			
            addLoaderEventListeners(bLoader);
			
            return bLoader;
        }
		
		/**
		 * 默认加载器 
		 */		
        public static function getDefaultLoader():BulkLoader
		{
            return _defaultLoader;
        }
		
		/**
		 * 普通加载 
		 * @param loadDataArr [LoadData, ...]
		 * @param bLoader BulkLoader
		 * @param oneByone 是否下载完一个接着下载另一个
		 * @return BulkLoader
		 * 
		 */
        public static function load(loadDataArr:Array, bLoader:BulkLoader=null, oneByone:Boolean=false):BulkLoader
		{
            var loadData:LoadData;
            bLoader = bLoader || _defaultLoader;
            addLoaderEventListeners(bLoader);
            if (!loadDataArr || loadDataArr.length == 0) {
                return bLoader;
            }
			
			// 一个一个下载
            if (oneByone){
                loadNext(bLoader, loadDataArr);
            } else {
                for each (loadData in loadDataArr) {
                    loadNext(bLoader, [loadData]);
                }
            }
            if (!(bLoader.itemsTotal == 0) && !(bLoader.isRunning)) {
                bLoader.start();
            }
            return bLoader;
        }
		
		/**
		 * 简单加载 
		 * @param completeHandler
		 * @param bLoader BulkLoader
		 * @param oneByone 是否下载完一个接着下载另一个
		 * @param args [url, ...]
		 * @return BulkLoader
		 */
        public static function lazyLoad(completeHandler:Function=null, bLoader:BulkLoader=null, 
										oneByone:Boolean=false, ...args):BulkLoader
		{
            var arr:Array = args;
			bLoader = bLoader || _defaultLoader;
            if (!arr || arr.length == 0) {
                return bLoader;
            }
			// (item:*, index:int, array:Array)
            var loadList:Array = arr.map(function(url:String, index:int, array:Array):LoadData {
                return new LoadData(String(url), completeHandler);
            });
			
            return load(loadList, bLoader, oneByone);
        }
		
		/**
		 * 加载下一个 
		 * @param bLoader
		 * @param oneByOneLoadDataArr [LoadData, ...]
		 */
        private static function loadNext(bLoader:BulkLoader, oneByOneLoadDataArr:Array):void
		{
            var ld:LoadData = null;
            if (!bLoader || !oneByOneLoadDataArr || oneByOneLoadDataArr.length == 0) {
                return;
            }
			
            ld = oneByOneLoadDataArr.shift();
            if (ld == null) {
                return;
            }
            var loadItem:LoadingItem = bLoader.add(ld.url, {id:ld.key});
            
			loadItem.addEventListener(Event.COMPLETE, function (event:Event):void {
                if (ld.onComplete != null){
                    ld.onComplete(event);
                }
                loadNext(bLoader, oneByOneLoadDataArr);
            });
			
            loadItem.addEventListener(ErrorEvent.ERROR, function (event:ErrorEvent):void {
                if (ld.onError != null){
                    ld.onError(event);
                }
                loadNext(bLoader, oneByOneLoadDataArr);
            });
			
            if (ld.onUpdate != null) {
                loadItem.addEventListener(ProgressEvent.PROGRESS, ld.onUpdate);
            }
            bLoader.loadNow(loadItem);
            changeItemPriority(bLoader, loadItem, ld.priority);
        }
		
		/**
		 * 修改加载器的优先级 
		 */
        private static function changeItemPriority(bLoader:BulkLoader, loadItem:LoadingItem, priority:int):Boolean
		{
            if (!bLoader){
                return (false);
            }
            var loadingItem:LoadingItem = bLoader.get(loadItem);
            if (!loadingItem){
                return (false);
            }
            loadingItem._priority = priority;
            bLoader.sortItemsByPriority();
			
            return true;
        }
		
		/**
		 * 给加载器添加事件监听 
		 * @param bLoader
		 */
        private static function addLoaderEventListeners(bLoader:BulkLoader):void
		{
            if (!bLoader) {
                return;
            }
			
            bLoader.addEventListener(BulkLoader.COMPLETE, loaderHandle, false, -(int.MAX_VALUE));
            bLoader.addEventListener(BulkLoader.PROGRESS, loaderHandle, false, -(int.MAX_VALUE));
            bLoader.addEventListener(BulkLoader.ERROR, loaderHandle, false, -(int.MAX_VALUE));
            bLoader.addEventListener(IOErrorEvent.IO_ERROR, loaderHandle, false, -(int.MAX_VALUE));
        }
		
		/**
		 * 事件处理
		 */
        private static function loaderHandle(event:Event):void
		{
            if (event == null || event.type == null){
                return;
            }
			
            switch (event.type) {
                case BulkLoader.COMPLETE:
                    BulkLoader(event.target).removeAll();
                    break;
                case BulkLoader.PROGRESS:
                    break;
                case BulkLoader.ERROR:
                    BulkLoader(event.target).removeFailedItems();
                    break;
                case IOErrorEvent.IO_ERROR:
                    break;
            }
        }
    }
}