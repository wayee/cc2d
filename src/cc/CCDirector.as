package cc
{
	import cc.utils.CCG;
	import cc.tools.SceneCache;

	/**
	 * RPG引擎
	 * 初始化、设置路径和帧速率等
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class CCDirector
	{
		public static var engineReady:Boolean = false;
		
		/**
		 * 初始化引擎
		 * @param resourcePath 资源路径
		 * @param frameRate 帧速率
		 */
		public static function Init(resourcePath:String, frameRate:int=24):void
		{
			CCG.resourcePath = resourcePath;
			CCG.frameRate = frameRate;
			CCG.stepTime = (1000 / frameRate);
			engineReady = true;	// 引擎已经准备好，see Scene构造函数
		}
		
		/**
		 * 设置传送点
		 * @param value [ [mapid, x, y], ... ]
		 */
		public static function InitTransport(value:Array):void
		{
			if (value == null) {
				return;
			}
			var obj:Object = {};
			var tps:Array;
			for each (tps in value) {
				// [ mapId_x_y ] = 可通行标志
				obj[tps[0] + '_' + tps[1] + '_' + tps[2]] = 1;
			}
			
			SceneCache.transports = obj;
		}
	}
}