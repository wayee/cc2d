package cc.utils
{
	/**
	 * 全局配置信息: 路径, fps
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class CCG
	{
		public static const INIT_SCREEN_WIDTH:int 		= 1024;
		public static const INIT_SCREEN_HEIGHT:int 		= 760;
		public static const FRAME_RATE:int				= 24;
		
		public static var frameRate:int = 24;						// 当前 fps
		public static var stepTime:Number = (1000 / frameRate);		// 每帧时间长度(毫秒)
		
		public static var resourcePath:String = "";					// 资源的路径
		public static var mapConfig:String = "scene/c";				// 地图配置路径
		public static var mapPath:String = "scene";					// 地图路径
		public static var mapSmallPath:String = "scene/s";			// 小地图路径
		public static var avatarPath:String = "avatar";				// 角色
		public static var heroPath:String = "hero";					// 英雄
		public static var heroEffectPath:String = "heroeffect";		// 英雄动作特效
		public static var weaponPath:String = "weapon";				// 武器
		public static var npcPath:String = "npc";					// NPC
		public static var effectPath:String = "effect";				// 特效
		public static var sharePath:String = "share";				// 共享
		public static var bufferPath:String = "buffer";				// buffer
		
		public static var versionNpc:String = '';
		public static var versionMapConifg:String = '';
		public static var versionHero:String = '';
		public static var versionShare:String = '';
		public static var versionBuffer:String = '';
		public static var versionWeapon:String = '';
		public static var versionEffect:String = '';
		public static var versionHeroEffect:String = '';
		public static var versionScene:String = '';
		public static var versionSceneSmall:String = '';
		
		
		private static function getResourcePath(id:String, ext:String, version:String):String
		{
			return resourcePath + '/' + id + '.' + ext + getVerStr(version);
		}
		
		private static function getVerStr(ver:String):String
		{
			return ver == '' ? '' : '?' + ver;
		}
		
		/**
		 * 获取地图路径 
		 * @param id 地图名称
		 * @param ext 扩展名
		 * @return 完整路径
		 */
		public static function getMapConfigPath(id:String, ext:String='json'):String
		{
			return getResourcePath(mapConfig + '/' + id, ext, versionMapConifg);
		}
		
		/**
		 * 获取地图路径
		 */
		public static function getMapPath(id:String, ext:String='jpg'):String
		{
			return getResourcePath(mapPath + '/' + id, ext, versionScene);
		}
		
		/**
		 * 获取小地图路径
		 */
		public static function getSmallMapPath(id:String, ext:String='jpg'):String
		{
			return getResourcePath(mapSmallPath + '/' + id, ext, versionSceneSmall);
		}
		
		/**
		 * 英雄资源 
		 */
		public static function getHeroPath(id:String, ext:String = 'swf'):String
		{
			return getResourcePath(heroPath + '/' + heroPath + id, ext, versionHero);
		}
		
		/**
		 * 英雄动作特效资源 
		 */
		public static function getHeroEffectPath(id:String, ext:String = 'swf'):String
		{
			return getResourcePath(heroEffectPath + '/' + heroEffectPath + id, ext, versionHeroEffect);
		}
		
		/**
		 * 武器 
		 */
		public static function getWeaponPath(id:String, ext:String = 'swf'):String
		{
			return getResourcePath(weaponPath + '/' + weaponPath + id, ext, versionWeapon);
		}
		
		/**
		 * NPC资源 
		 */
		public static function getNpcPath(id:String, ext:String = 'swf'):String
		{
			return getResourcePath(npcPath + '/' + npcPath + id, ext, versionNpc);
		}
		
		/**
		 * 法术特效 
		 */
		public static function getEffectPath(id:String, ext:String = 'swf'):String
		{
			return getResourcePath(effectPath + '/' + effectPath + id, ext, versionEffect);
		}
		
		/**
		 * 共享资源 
		 */
		public static function getSharePath(id:String, ext:String = 'swf'):String
		{
			return getResourcePath(sharePath + '/' + id, ext, versionShare);
		}
		
		/**
		 * 获取 buffer 效果
		 */
		public static function getBufferEffect(id:String, ext:String = 'swf'):String
		{
			return getResourcePath(bufferPath + '/' + id, ext, versionBuffer);
		}
		
		/**
		 * 获取 光环
		 */
		public static function getLightRingPath(id:String, ext:String = 'swf'):String
		{
			return getResourcePath(sharePath + '/' + id, ext, versionShare);
		}
	}
}