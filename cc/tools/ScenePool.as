package cc.tools
{
	import wit.manager.PoolManager;
	import wit.pool.Pool;

	/**
	 * 场景对象分配池
	 * 	<li> 指定最大数量(100或200)个的空闲对象, 重新分配时, 从该对象中获取, 避免频繁  new/delete
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class ScenePool
	{
        public static var sceneCharacterPool:Pool = PoolManager.createPool("sceneCharacterPool", 100);
        public static var avatarPool:Pool = PoolManager.createPool("avatarPool", 100);
        public static var avatarPartPool:Pool = PoolManager.createPool("avatarPartPool", 100);
        public static var attackFacePool:Pool = PoolManager.createPool("attackFacePool", 200);
        public static var headFacePool:Pool = PoolManager.createPool("headFacePool", 200);
    }
}