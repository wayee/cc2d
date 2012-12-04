package wit.manager
{
	import wit.cache.Cache;
	import wit.log.Log4J;

	/**
	 * 缓存管理器
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class CacheManager
	{
		private static var _cacheArr:Array = [];
		
		public function CacheManager()
		{
			throw new Error("This is a static class.");
		}
		
		/**
		 * 是否存在缓存 
		 */
		public static function hasCache(cache:Cache):Boolean
		{
			return _cacheArr.indexOf(cache) != -1;
		}
		
		/**
		 * 是否存在缓存 
		 */
		public static function hasNamedCache(name:String):Boolean
		{
			var cache:Cache;
			for each (cache in _cacheArr) {
				if (cache.name == name){
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 获取缓存 
		 */
		public static function getCache(name:String):Cache
		{
			var cache:Cache;
			for each (cache in _cacheArr) {
				if (cache.name == name){
					return cache;
				}
			}
			return null;
		}
		
		/**
		 * 创建缓存 
		 */
		public static function creatNewCache(name:String="", len:int=2147483647):Cache
		{
			var cache:Cache = _cacheArr[_cacheArr.length] = new Cache(name, len);
			Log4J.Info(("CacheManager.creatNewCache::_cacheArr.length:" + getCachesNum()));
			return cache;
		}
		
		/**
		 * 删除缓存 
		 */		
		public static function deleteCache(rmCache:Cache):void{
			var cache:Cache;
			for each (cache in _cacheArr) {
				if (cache == rmCache){
					_cacheArr.splice(_cacheArr.indexOf(rmCache), 1);
					Log4J.Info(("CacheManager.deleteCache::_cacheArr.length:" + getCachesNum()));
					cache.dispose();
					break;
				}
			}
		}
		
		/**
		 * 根据名称删除缓存 
		 */
		public static function deleteCacheByName(name:String):void{
			var cache:Cache;
			for each (cache in _cacheArr) {
				if (cache.name == name){
					_cacheArr.splice(_cacheArr.indexOf(cache), 1);
					Log4J.Info(("CacheManager.deleteCacheByName::_cacheArr.length:" + getCachesNum()));
					cache.dispose();
					break;
				}
			}
		}
		
		/**
		 * 清除所有缓存内容 
		 */
		public static function deleteAllCaches():void
		{
			var cache:Cache;
			for each (cache in _cacheArr) {
				cache.dispose();
			}
			_cacheArr = [];
			Log4J.Info("CacheManager.deleteAllCaches::_cacheArr.length:0");
		}
		
		/**
		 * 缓存对象总数 
		 */		
		public static function getCachesNum():int
		{
			return _cacheArr.length;
		}
	}
}