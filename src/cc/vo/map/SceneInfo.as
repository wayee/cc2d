package cc.vo.map
{
	public class SceneInfo
	{
		public static const TILE_WIDTH:Number = 24;				// 块(格子)尺寸 24*24
		public static const TILE_HEIGHT:Number = 24;
		
		public var width:Number = 1024;							// 场景的可视尺寸
		public var height:Number = 600;
		
		public function SceneInfo(p_width:Number, p_height:Number) {
			this.width = p_width;
			this.height = p_height;
		}
	}
} 
