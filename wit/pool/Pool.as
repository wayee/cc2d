package wit.pool
{
	import wit.manager.RslLoaderManager;

	/**
	 * 对象池
	 * <li>  用于分配对象
	 * <li>	  释放的对象被保存起来
	 * <li>	  要新建的时候, 从缓存里提取
	 * <li>	  避免了 new 的频繁调用
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 */
	public class Pool
	{
		private var _name:String;
		private var _maxSize:int;
		private var _objectList:Array;		// [IPoolObject, ...] 可以使用vector优化
		
		public function Pool(name:String='', maxSize:int=10000)
		{
			_name = name;
			_maxSize = maxSize;
			_objectList = [];
		}
		
		/**
		 * 创建对象
		 * @param objClass
		 * @param args 对象构造函数的参数
		 * @return objClass的实例
		 */
		public function createObj(objClass:Class, ...args):IPoolObject
		{
			var obj:IPoolObject;
			
			if (_objectList.length <= 0) {
				obj = RslLoaderManager.getInstanceByClass(objClass, args) as IPoolObject;		// 新建对象
			} else {
				obj = _objectList.shift();
				obj.reset(args);
			}
			
			return obj;
		}
		
		/**
		 * 回收对象 
		 * @param obj
		 */
		public function disposeObj(obj:IPoolObject):void
		{
			if (obj == null) return;
			
			obj.dispose();
			if (_objectList.indexOf(obj) == -1) {
				_objectList.push(obj);
				resize(_maxSize);
			}
		}
		
		/**
		 * 重新分配对象池大小
		 * @param maxSize 最大数量值
		 */
		public function resize(maxSize:int):void
		{
			if (maxSize < 0) {
				return;
			}
			_maxSize = maxSize;
			while (_objectList.length > _maxSize) {
				_objectList.shift();
			}
		}
		
		/**
		 * 删除一个池中对象 
		 * @param obj
		 */
		public function removeObj(obj:IPoolObject):void
		{
			obj.dispose();
			var index:int = _objectList.indexOf(obj);
			if (index != -1) {
				_objectList.splice(index, 1);
			}
		}
		
		/**
		 * 删除池中所有对象 
		 */
		public function removeAll():void
		{
			var obj:IPoolObject;
			for each (obj in _objectList) {
				obj.dispose();
			}
			_objectList = [];
		}
	}
}