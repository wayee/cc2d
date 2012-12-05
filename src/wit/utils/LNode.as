package wit.utils
{
	/**
	 * 双向链表
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class LNode
	{
		private var id:String;
		private var data:Object;
		private var pre:LNode;
		private var next:LNode;
		
		public function LNode(value:Object, id:String=null) {
			data = value;
			id = id;
			next = null;
			pre = null;
		}
		
		public function get Pre():LNode {
			return pre;
		}
		
		public function set Pre(node:LNode):void {
			pre = node;
		}
		
		public function get Next():LNode {
			return next;
		}
		
		public function set Next(node:LNode):void {
			next = node;
		}
		
		public function get Data():Object {
			return data;
		}
		
		public function set Data(value:Object):void {
			data = value;
		}
		
		public function get Id():String {
			return id;
		}
	}
}