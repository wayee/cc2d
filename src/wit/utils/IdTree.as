package wit.utils
{
	/**
	 * 对各种 id 的管理, 从 id 映射到名字, 每个id可以包含多个子类id
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class idtree
	{
		private var m_map:Object;
		
		/**
		 * map 中元素格式: [ main_id:int, desc:String, ...sub_id]
		 * @param map
		 * 
		 */
		public function idtree(...map)
		{
			m_map = new Object;
			for each (var arr:Array in map) {
				var e:Entity = new Entity(arr);
				m_map[e.id] = e;
			}
		}
		
		/**
		 * 根据小类id查找大类id, 如果失败, 则返回 def
		 * @param subId
		 * @param def
		 * @return 
		 * 
		 */
		public function getMainIdFromSubId(subId:int, def:int=0):int
		{
			for each (var e:Entity in m_map) {
				if (e.sub_id && e.sub_id.indexOf(subId) >= 0) return e.id;
			}
			return def;
		}
		
		/**
		 * 根据大类id查找名字
		 * @param mainId
		 * @return 
		 * 
		 */
		public function getNameByMainId(mainId:int):String
		{
			var e:Entity = m_map[ mainId ];
			return (e? e.desc: null);
		}
		
		/**
		 * 根据小类id查找名字
		 * @param subId
		 * @return 
		 * 
		 */
		public function getNameBySubId(subId:int):String
		{
			var mainId:int = this.getMainIdFromSubId(subId);
			return getNameByMainId( mainId );
		}
	}
}

class Entity
{
	public var id:int;
	public var desc:String;
	public var sub_id:Array;
	
	public function Entity(arr:Array)
	{
		id = arr[0];
		desc = arr[1];
		
		if (arr.length > 2) {
			sub_id = new Array;
			for (var i:int=2; i<arr.length; i++) {
				sub_id.push( int( arr[i] ) );
			}
		}
	}
}