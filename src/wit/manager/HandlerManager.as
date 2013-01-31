package wit.manager
{
	import wit.handler.HandlerHelper;
	import wit.handler.HandlerPool;
	import wit.handler.HandlerThread;
	import wit.log.Log4J;

	/**
	 * 线程管理器
	 * <li>线程函数: 一个函数及其参数
	 * <li>线程: 一系列线程函数依次执行
	 * 		
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class HandlerManager
	{
        private static var _defaultHandlerThread:HandlerThread = new HandlerThread(new Array(), true);		// 默认线程, 可添加默认线程函数
        private static var _handlerThreadArr:Array = [_defaultHandlerThread];		// 线程池

        public function HandlerManager()
		{
            throw new Error('This is a static class.');
        }
		
		/**
		 * 线程个数
		 */
        public static function getHandlerThreadsNum():int
		{
            return _handlerThreadArr.length;
        }
		
		/**
		 * 线程函数个数. 每个线程由多个线程函数构成(依次执行)
		 */
        public static function getHandlersNum():int
		{
            var thread:HandlerThread;
            var _local1:Number = 0;
            for each (thread in _handlerThreadArr) {
                _local1 = (_local1 + thread.getHandlersNum());
            }
            return (_local1);
        }
		
		/**
		 * 建立一个新线程
		 * @param handleArr 线程函数数组
		 * @param isQueue 使用队列方式, 否则为堆栈方式
		 */
        public static function creatNewHandlerThread(handleArr:Array=null, isQueue:Boolean=true):HandlerThread
		{
            var ht:HandlerThread = _handlerThreadArr[_handlerThreadArr.length] = new HandlerThread(handleArr, isQueue);
            try {
                Log4J.Info("HandlerManager.creatNewHandlerThread::_handlerThreadArr.length:" + getHandlerThreadsNum());
            } catch(e:Error) {
            }
            return ht;
        }
		
		/**
		 * 添加线程函数
		 * @param fn 线程函数
		 * @param params 参数数组
		 * @param delay 等待时间(毫秒)
		 * @param targetHandler  目标线程, 如果为空, 则添加到默认线程中运行
		 */
        public static function push(fn:Function, params:Array=null, delay:Number=0, 
									doNext:Boolean=true, runNow:Boolean=true, targetHandler:HandlerThread=null):HandlerThread
		{
            var handler:HandlerThread;
            if (targetHandler != null){
                handler = targetHandler;
                if (!hasHandlerThread(handler)) {
                    _handlerThreadArr.push(handler);
                    Log4J.Info("HandlerManager.push::_handlerThreadArr.length:" + getHandlerThreadsNum());
                }
            } else {
                handler = _defaultHandlerThread;
            }
            handler.push(fn, params, delay, doNext, runNow);
            return handler;
        }
		
		/**
		 * 执行一个函数
		 * fn.apply(null, params)
		 */
        public static function execute(fn:Function, params:Array=null):void
		{
            return HandlerHelper.execute(fn, params);
        }
		
		/**
		 * 从对象池中获取 HandlerThread，执行完后并 recycle 
		 */
		public static function executeThread(callback:Function, args:Array, delay:Number):void	// delay: 等待时间(毫秒)
		{
			var thread:HandlerThread = HandlerPool.getThread();
			var completeHandler:Function = function():void
			{
				HandlerPool.recycleThread(thread);
				if (callback != null)
					callback.apply(null, args);
			};
			
			push(completeHandler, null, delay, true, true, thread);
		}
		
		/**
		 * 获取默认的线程 
		 * @return HandlerThread
		 */
        public static function getDefaultHandlerThread():HandlerThread
		{
            return _defaultHandlerThread;
        }
		
		/**
		 * 删除所有的线程 
		 */
        public static function removeAllHandlerThreads():void
		{
            removeAllHandlers();
            _handlerThreadArr = [];
            Log4J.Info("HandlerManager.removeAllHandlerThreads::_handlerThreadArr.length:0");
        }
		
		/**
		 * 删除所有线程函数 
		 */
        public static function removeAllHandlers():void
		{
            var handler:HandlerThread;
            for each (handler in _handlerThreadArr) {
				handler.removeAllHandlers();
            }
        }
		
		/**
		 * 删除线程
		 * @param handler
		 */
        public static function removeHandlerThread(handler:HandlerThread):void
		{
            var thread:HandlerThread;
            if (!handler){
                return;
            }
            for each (thread in _handlerThreadArr) {
                if (thread == handler){
                    thread.removeAllHandlers();
                    _handlerThreadArr.splice(_handlerThreadArr.indexOf(thread), 1);
                    Log4J.Info("HandlerManager.removeHandlerThread::_handlerThreadArr.length:" + getHandlerThreadsNum());
                    break;
                }
            }
        }
		
		/**
		 * 删除线程函数 
		 * @param fn
		 */
        public static function removeHandler(fn:Function):void
		{
            var thread:HandlerThread;
            if (fn == null){
                return;
            }
            for each (thread in _handlerThreadArr) {
                thread.removeHandler(fn);
            }
        }
		
		/**
		 * 存在线程？
		 * @param thread 线程
		 * @return bool
		 */
        public static function hasHandlerThread(thread:HandlerThread):Boolean
		{
            return _handlerThreadArr.indexOf(thread) != -1;
        }
		
		/**
		 * 存在线程函数？ 
		 * @param fn 函数
		 * @return bool 
		 */
        public static function hasHandler(fn:Function):Boolean
		{
            var thread:HandlerThread;
            for each (thread in _handlerThreadArr) {
                if (thread.hasHandler(fn)) {
                    return true;
                }
            }
            return false;
        }
    }
}