package wit.objects
{
	import flash.display.Sprite;

	public final class SpritePool
	{ 
		private static var MAX_VALUE:uint; 
		private static var GROWTH_VALUE:uint; 
		private static var counter:uint; 
		private static var pool:Vector.<Sprite>; 
		private static var currentSprite:Sprite; 
		
		public static function initialize( maxPoolSize:uint, growthValue:uint ):void 
		{ 
			MAX_VALUE = maxPoolSize; 
			GROWTH_VALUE = growthValue; 
			counter = maxPoolSize; 
			
			var i:uint = maxPoolSize;
			
			pool = new Vector.<Sprite>(MAX_VALUE); 
			while( --i > -1 ) 
				pool[i] = new Sprite(); 
		} 
		
		public static function getSprite():Sprite 
		{ 
			if ( counter > 0 ) 
				return currentSprite = pool[--counter]; 
			
			var i:uint = GROWTH_VALUE; 
			while( --i > -1 ) 
				pool.unshift ( new Sprite() ); 
			
			counter = GROWTH_VALUE; 
			return getSprite(); 
		}
		
		public static function disposeSprite(disposedSprite:Sprite):void 
		{ 
			pool[counter++] = disposedSprite; 
		}
		
		public static function dispose():void
		{
			while ( --counter > -1 ) {
				pool[counter]  = null;
				delete pool[counter];
			}
			currentSprite = null;
		}
	} 
}