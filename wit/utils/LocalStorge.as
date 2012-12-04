package wit.utils
{
	import flash.net.SharedObject;

	/**
	 * 写本地文件
	 * 
	 * <li> var obj:SharedObject = new LocalStorge;
	 * <li>写数据到本地： obj.data.time = '2012-6-25'; obj.flush();
	 * <li>获取数据：textField.text = obj.data.time;
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class LocalStorge
	{
		private var _storge:SharedObject;
		
		public function LocalStorge(name:String)
		{
			_storge = SharedObject.getLocal(name);
		}
		
		public function get storge():SharedObject
		{
			return _storge;
		}
		
		public function get data():Object
		{
			return _storge.data;
		}
		
		public function flush():void
		{
			_storge.flush();
		}
		
		public function clear():void
		{
			_storge.clear();
		}
		
		public function hasKey(key:String):Boolean
		{
			if (_storge.data.hasOwnProperty(key))
				return true;
			return false;
		}
	}
}