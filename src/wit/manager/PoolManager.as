package wit.manager
{
	import wit.pool.Pool;
	import wit.utils.HashMap;

	/**
	 * 对象池管理器
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class PoolManager
	{
		static private var _poolList:HashMap = new HashMap;	// [Pool, ...]
		
		public function PoolManager()
		{
			throw new Error("PoolManager class is static class only"); 
		}
		
		/**
		 * 创建一个对象池 
		 * @param name 对象池名称
		 * @param maxSize 对象池大小
		 * @return pool
		 */
		public static function createPool(name:String, maxSize:int):Pool
		{
			var pool:Pool;
			if (hasPool(name)) {
				pool = getPool(name);
				pool.resize(maxSize);
			} else {
				pool = new Pool(name, maxSize);
				_poolList.put(name, pool);
			}
			return pool;
		}
		
		/**
		 * 获取对象池 
		 * @param name
		 * @return pool
		 */
		public static function getPool(name:String):Pool
		{
			if (_poolList.containsKey(name)) {
				return _poolList.get(name);
			}
			return null;
		}
		
		/**
		 * 是否存在对象池 
		 */
		public static function hasPool(name:String):Boolean
		{
			return _poolList.containsKey(name);
		}
		
		/**
		 * 删除对象池 
		 */		
		public static function removePool(name:String):void
		{
			if (hasPool(name)) {
				var pool:Pool = getPool(name);
				pool.removeAll();
				_poolList.remove(name);
			}
		}
		
		/**
		 * 删除所有对象池 
		 */
		public static function removeAll():void
		{
			_poolList.eachValue(function(value:Pool):void
			{
				value.removeAll();
			});
			_poolList.clear();
		}
	}
}