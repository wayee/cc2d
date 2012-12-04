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
		private var _id:String;
		private var _data:Object;
		private var _pre:LNode;
		private var _next:LNode;
		
		public function LNode(value:Object, id:String=null)
		{
			_data = value;
			_id = id;
			_next = null;
			_pre = null;
		}
		
		public function get pre():LNode
		{
			return _pre;
		}
		public function set pre(node:LNode):void
		{
			_pre = node;
		}
		
		public function get next():LNode
		{
			return _next;
		}
		public function set next(node:LNode):void
		{
			_next = node;
		}
		
		public function get data():Object
		{
			return _data;
		}
		public function set data(value:Object):void
		{
			_data = value;
		}
		
		public function get id():String
		{
			return _id;
		}
	}
}