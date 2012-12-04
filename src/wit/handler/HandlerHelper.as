package wit.handler
{
	/**
	 * 函数/方法执行帮助函数
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class HandlerHelper
	{
        public function HandlerHelper()
		{
            throw (new Error('This is a static class.'));
        }
		
		/**
		 * handler.apply(null, args)
		 */
        public static function execute(handler:Function, args:Array=null):void
		{
            if (handler == null) {
                return;
            }
			handler.apply(null, args);
        }
    }
}