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
		
		public static var versionNpc:String = '';
		public static var versionMapConifg:String = '';
		public static var versionHero:String = '';
		public static var versionShare:String = '';
		public static var versionWeapon:String = '';
		public static var versionEffect:String = '';
		public static var versionHeroEffect:String = '';
		public static var versionScene:String = '';
		public static var versionSceneSmall:String = '';
		
		private static function getResourcePath(id:String, ext:String, version:String):String {
			return resourcePath + '/' + id + '.' + ext + getVerStr(version);
		}
		
		private static function getVerStr(ver:String):String {
			return ver == '' ? '' : '?' + ver;
		}
		
		public static function GetMapConfigPath(id:String, ext:String='json'):String {
			return getResourcePath(mapConfig + '/' + id, ext, versionMapConifg);
		}
		
		public static function GetMapPath(id:String, ext:String='jpg'):String {
			return getResourcePath(mapPath + '/' + id, ext, versionScene);
		}
		
		public static function GetSmallMapPath(id:String, ext:String='jpg'):String {
			return getResourcePath(mapSmallPath + '/' + id, ext, versionSceneSmall);
		}
		
		public static function GetHeroPath(id:String, ext:String = 'swf'):String {
			return getResourcePath(heroPath + '/' + heroPath + id, ext, versionHero);
		}
		
		public static function GetHeroEffectPath(id:String, ext:String = 'swf'):String {
			return getResourcePath(heroEffectPath + '/' + heroEffectPath + id, ext, versionHeroEffect);
		}
		
		public static function GetWeaponPath(id:String, ext:String = 'swf'):String {
			return getResourcePath(weaponPath + '/' + weaponPath + id, ext, versionWeapon);
		}
		
		public static function GetNpcPath(id:String, ext:String = 'swf'):String {
			return getResourcePath(npcPath + '/' + npcPath + id, ext, versionNpc);
		}
		
		public static function GetEffectPath(id:String, ext:String = 'swf'):String {
			return getResourcePath(effectPath + '/' + effectPath + id, ext, versionEffect);
		}
		
		public static function GetSharePath(id:String, ext:String = 'swf'):String {
			return getResourcePath(sharePath + '/' + id, ext, versionShare);
		}
	}
}