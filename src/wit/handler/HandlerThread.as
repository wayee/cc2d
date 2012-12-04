package wit.handler
{
	import wit.manager.TimerManager;

	/**
	 * 模拟线程类
	 * 	功能
	 *    添加 HandlerData 作为执行的单元
	 * 	    支持延时
	 * 	    每个 HandlerData 按照 队列/堆栈 的方式依次执行
	 * 
	 * 	HandlerDAta
	 *    线程结构
	 * 
	 * 	HandlerHelper 
	 *    线程调用时的辅助函数, 调用 apply
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class HandlerThread
	{
		private var _handlerDataArr:Array;				// [HandlerData]
		private var _handlerDataReadyArr:Array;			// [HandlerData]
		private var _isRunning:Boolean;			// 是否在运行中
		private var _canRun:Boolean;			// 是否可运行
		private var _isQueue:Boolean;			// 队列方式, 或堆栈方式
		private var _next:HandlerData;
		
		/**
		 * @param isQueue 队列方式, 否则为堆栈方式
		 */
		public function HandlerThread(dataArr:Array=null, isQueue:Boolean=true)
		{
			this._handlerDataArr = dataArr || [];
			this._handlerDataReadyArr = [];
			this._isQueue = isQueue;
			this._isRunning = false;
			this._canRun = true;
			this._next = null;
		}
		public function get isRunning():Boolean
		{
			return this._isRunning;
		}
		public function getHandlersNum():int
		{
			return this._handlerDataArr.length;
		}
		
		/**
		 * 添加一个 handler, 并支持立即运行
		 * @param fun 执行函数
		 * @param params 参数表
		 * @param delay 等待时间(毫秒)
		 * @param doNext 是否执行下一个
		 * @param runNow 是否马上执行
		 */
		public function push(fun:Function, params:Array=null, delay:Number=0, 
							 doNext:Boolean=true, runNow:Boolean=true):HandlerData
		{
			var handlerData:HandlerData = new HandlerData(fun, params, delay, doNext);
			this._handlerDataArr.push(handlerData);
			if ( this._canRun && runNow && !this._isRunning ) {
				this.executeNext();
			}
			return handlerData;
		}
		
		public function removeAllHandlers():void
		{
			this._handlerDataArr.length = 0;
			this._handlerDataReadyArr.length = 0;
			this._isRunning = false;
		}
		
		/**
		 * 根据  fun 来删除 handler
		 */
		public function removeHandler(handler:Function):void
		{
			var handlerData:HandlerData;
			if (handler == null) {
				return;
			}
			
			var len:int = this._handlerDataArr.length;			// 从 handlerData 中删除				
			while (len-- > 0) {
				handlerData = this._handlerDataArr[len];
				if (handlerData.handler == handler) {
					this._handlerDataArr.splice(len, 1);		// 从 len 开始删除1个
				}
			}
			len = this._handlerDataReadyArr.length;				// 从 handerDAtaReady 中删除
			while (len-- > 0) {
				handlerData = this._handlerDataReadyArr[len];
				if (handlerData.handler == handler) {
					this._handlerDataReadyArr.splice(len, 1);
				}
			}
			if ( this._handlerDataArr.length == 0 && this._handlerDataReadyArr.length == 0 ) {
				this._isRunning = false;		// 自动停止
			}
		}
		
		/**
		 * 检查函数 fn 是否在 handle 数组中
		 */
		public function hasHandler(handler:Function):Boolean
		{
			var handlerData:HandlerData;
			for each (handlerData in this._handlerDataArr) {
				if (handlerData.handler == handler) {
					return (true);
				}
			}
			for each (handlerData in this._handlerDataReadyArr) {
				if (handlerData.handler == handler) {
					return (true);
				}
			}
			return (false);
		}
		
		/**
		 * 强制开始
		 */
		public function strongStart():void
		{
			this._canRun = true;
			this._isRunning = false;
			this.executeNext();
		}
		
		/**
		 * 开始运行, 如果非运行中, 则 executeNext
		 */
		public function start():void
		{
			this._canRun = true;
			if (!this._isRunning) {
				this.executeNext();
			}
		}
		
		public function stop():void
		{
			this._canRun = false;
		}
		
		/**
		 * 私人领地，请退出到200公里外
		 */
		
		private function setNotRunning():void
		{
			this._isRunning = false;
		}
		
		private function executeNext():void
		{
			if ( !this._canRun ) {
				this._isRunning = false;
				return;
			}
			
			if (this._handlerDataArr.length == 0){
				this._isRunning = false;
				return;
			}
			
			this._isRunning = true;
			this._next = ((this._isQueue) ? this._handlerDataArr.shift() : this._handlerDataArr.pop() as HandlerData);
			if (this._next) {
				
				// 有延时
				if (this._next.delay > 0) {
					// 设置定时器结束后的执行函数
					var newHandler:Function = function ():void {
//						trace(Name+'[HandlerThread.executeNext] 222 len:', _handlerDataArr.length, _handlerDataReadyArr.length);
						if (removeReadyHD(_next)) {
							HandlerHelper.execute(_next.handler, _next.parameters);
//							trace(Name+'[HandlerThread.executeNext] 333 len:', _handlerDataArr.length, _handlerDataReadyArr.length);
						}
						if (_next.doNext) {
							executeNext();
						} else {
							setNotRunning();
						}
					}
					this.addReadyHD(this._next);
					TimerManager.createOneOffTimer(this._next.delay, 1, newHandler, null, null, null, true);
//					trace(Name+'[HandlerThread.executeNext] 111 len:', this._handlerDataArr.length, _handlerDataReadyArr.length);
				} 
				// 无延时, 立即执行
				else {
					HandlerHelper.execute(this._next.handler, this._next.parameters);
					if (this._next.doNext){
						this.executeNext();
					} else {
						this.setNotRunning();
					}
				}
			} else {
//				trace(Name+'[HandlerThread.executeNext] this.next is null or false');
				this.executeNext();
			}
		}
		
		/**
		 * 添加到预备队列
		 */
		private function addReadyHD(value:HandlerData):void
		{
			if (this._handlerDataReadyArr.indexOf(value) != -1) {
				return;
			}
			this._handlerDataReadyArr.push(value);
		}
		
		/**
		 * 从预备队列删除
		 */
		private function removeReadyHD(value:HandlerData):Boolean
		{
			var index:int = this._handlerDataReadyArr.indexOf(value);
			if (index != -1) {
				this._handlerDataReadyArr.splice(index, 1);
				return true;
			}
			return false;
		}
	}
}