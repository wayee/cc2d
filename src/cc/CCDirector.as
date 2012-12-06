package cc
{
	import cc.utils.CCG;
	import cc.tools.SceneCache;

	public class CCDirector
	{
		public static var IsReady:Boolean = false;
		
		public static function Init(resourcePath:String, frameRate:int=24):void {
			CCG.resourcePath = resourcePath;
			CCG.frameRate = frameRate;
			CCG.stepTime = (1000 / frameRate);
			IsReady = true;	// 引擎已经准备好，see Scene构造函数
		}
		
		public static function InitTransport(value:Array):void {
			if (value == null) {
				return;
			}
			var obj:Object = {};
			var tps:Array;
			for each (tps in value) {
				obj[tps[0] + '_' + tps[1] + '_' + tps[2]] = 1;	// [ mapId_x_y ] = 可通行标志
			}
			
			SceneCache.Transports = obj;
		}
	}
}