package cc.vo.map
{
	/**
	 * 场景配置信息
	 * <li> 块的尺寸 TILE_WIDTH, TILE_HEIGHT
	 * <li> 场景的可视尺寸 width, height
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class SceneInfo
	{
		// 普通场景格子尺寸
		public static const TILE_WIDTH:Number = 24;			// 块尺寸 24*24
		public static const TILE_HEIGHT:Number = 24;
		
		public var width:Number = 1024;	// 场景尺寸
		public var height:Number = 600;
		
		public function SceneInfo(Pwidth:Number, Pheight:Number)
		{
			this.width = Pwidth;
			this.height = Pheight;
		}
	}
} 
