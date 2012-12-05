package cc.tools
{
	import wit.manager.PoolManager;
	import wit.pool.Pool;

    public class ScenePool
	{
        public static var sceneCharacterPool:Pool = PoolManager.createPool("sceneCharacterPool", 100);
        public static var avatarPool:Pool = PoolManager.createPool("avatarPool", 100);
        public static var avatarPartPool:Pool = PoolManager.createPool("avatarPartPool", 100);
        public static var attackFacePool:Pool = PoolManager.createPool("attackFacePool", 200);
        public static var headFacePool:Pool = PoolManager.createPool("headFacePool", 200);
    }
}