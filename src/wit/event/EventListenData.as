package wit.event
{
	import flash.events.EventDispatcher;

	/**
	 * 时间监听数据
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class EventListenData
	{
        private var _type:String;
        private var _listener:Function;
        private var _dispatcher:EventDispatcher;
        private var _useCapture:Boolean;
        private var _priority:int;
        private var _useWeakReference:Boolean;

        public function EventListenData(type:String, listener:Function, dispatcher:EventDispatcher=null, 
										useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false)
		{
            this._type = type;
            this._listener = listener;
            this._dispatcher = dispatcher;
            this._useCapture = useCapture;
            this._priority = priority;
            this._useWeakReference = useWeakReference;
        }
		
        public function get type():String
		{
            return _type;
        }
		
        public function get listener():Function
		{
            return _listener;
        }
		
        public function get dispatcher():EventDispatcher
		{
            return _dispatcher;
        }
		
        public function get useCapture():Boolean
		{
            return _useCapture;
        }
		
        public function get priority():int
		{
            return _priority;
        }
		
        public function get useWeakReference():Boolean
		{
            return _useWeakReference;
        }
		
        public function equals(type:String, listener:Function, dispatcher:EventDispatcher=null,
							   useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):Boolean
		{
            return _type == type && _listener == listener && _dispatcher == dispatcher && 
				_useCapture == useCapture && _priority == priority && _useWeakReference == useWeakReference;
        }
    }
}