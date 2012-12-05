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
		private var storge:SharedObject;
		
		public function LocalStorge(name:String) {
			storge = SharedObject.getLocal(name);
		}
		
		public function get Storge():SharedObject {
			return storge;
		}
		
		public function get Data():Object {
			return storge.data;
		}
		
		public function Flush():void {
			storge.flush();
		}
		
		public function Clear():void {
			storge.clear();
		}
		
		public function HasKey(key:String):Boolean {
			if (storge.data.hasOwnProperty(key))
				return true;
			return false;
		}
	}
}