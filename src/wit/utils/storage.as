package wit.utils
{
	import flash.net.SharedObject;

	/**
	 * 写本地文件
	 * 
	 * <li> var obj:SharedObject = new storage;
	 * <li>写数据到本地： obj.data.time = '2012-6-25'; obj.flush();
	 * <li>获取数据：textField.text = obj.data.time;
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class storage
	{
		private var storage:SharedObject;
		
		public function storage(name:String) {
			storage = SharedObject.getLocal(name);
		}
		
		public function get Storge():SharedObject {
			return storage;
		}
		
		public function get Data():Object {
			return storage.data;
		}
		
		public function Flush():void {
			storage.flush();
		}
		
		public function Clear():void {
			storage.clear();
		}
		
		public function HasKey(key:String):Boolean {
			if (storage.data.hasOwnProperty(key))
				return true;
			return false;
		}
	}
}