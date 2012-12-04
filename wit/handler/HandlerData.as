package wit.handler
{
	/**
	 * 任务数据
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class HandlerData 
	{
        private var _handler:Function;
        private var _parameters:Array;
        private var _delay:Number;
        private var _doNext:Boolean;			// 执行之后, 是否继续下一个任务？

		/**
		 * 任务 
		 * @param handler 需要被执行的方法
		 * @param args 方法参数表
		 * @param delay 延迟时间(秒)
		 * @param donext 是否有后续任务
		 * 
		 */
        public function HandlerData(handler:Function, args:Array=null, delay:Number=0, donext:Boolean=true)
		{
            this._handler = handler;
            this._parameters = args;
            this._delay = delay;
            this._doNext = donext;
        }
		
        public function get handler():Function
		{
            return this._handler;
        }
		
        public function get parameters():Array
		{
            return this._parameters;
        }
		
        public function get delay():Number
		{
            return this._delay;
        }
		
        public function get doNext():Boolean
		{
            return this._doNext;
        }
    }
}