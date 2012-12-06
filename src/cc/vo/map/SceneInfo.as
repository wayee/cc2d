package cc.vo.map
{
	public class SceneInfo
	{
		public static const TILE_WIDTH:Number = 24;			// 块尺寸 
		public static const TILE_HEIGHT:Number = 24;
		public static const ZONE_WIDTH:Number = 240;		// 族尺寸, 240x240, 1族=10*10=100个块
		public static const ZONE_HEIGHT:Number = 240;
		public static const ZONE_SCALE:Number = 10;			// 1个zone = 10个tile
		
		public var width:Number = 1000;						// 场景的可视尺寸
		public var height:Number = 580;
		
		public function SceneInfo(p_width:Number, p_height:Number) {
			this.width = p_width;
			this.height = p_height;
		}
	}
} 