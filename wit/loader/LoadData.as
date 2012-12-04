package wit.loader
{
	/**
	 * 加载信息
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class LoadData 
	{
        private var _url:String;
        private var _name:String;
        private var _key:String;
        private var _priority:int;
        private var _target:String;
        private var _onComplete:Function;
        private var _onUpdate:Function;
        private var _onError:Function;
        private var _decode:Function;
        public var userData:Object;

		/**
		 * 加载信息
		 * @param url url
		 * @param onComplete onComplete
		 * @param onUpdate onUpdate
		 * @param onError onError
		 * @param name name
		 * @param key key
		 * @param target 
		 * @param priority
		 * @param decode decode
		 */
        public function LoadData(url:String, onComplete:Function=null, onUpdate:Function=null, 
								 onError:Function=null, name:String="", key:String="", 
								 target:String="same", priority:int=0, decode:Function=null)
		{
            _url = url;
            _name = name;
            _key = key;
            _priority = priority;
            _target = target;
            _onComplete = onComplete;
            _onUpdate = onUpdate;
            _onError = onError;
            _decode = decode;
        }
		
        public function get url():String
		{
            return _url;
        }
		
        public function get name():String
		{
            return _name;
        }
		
        public function get key():String
		{
            return _key;
        }
        public function get priority():int
		{
            return _priority;
        }
		
        public function get target():String
		{
            return _target;
        }
		
        public function get onComplete():Function
		{
            return _onComplete;
        }
		
        public function get onUpdate():Function
		{
            return _onUpdate;
        }
		
        public function get onError():Function
		{
            return _onError;
        }
		
        public function get decode():Function
		{
            return _decode;
        }
		
		public function toString():String
		{
			return 'url: '+url+' name: '+name+' key: '+key;
		}
    }
}