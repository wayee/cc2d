package cc.vo.map
{
	import cc.CCNode;

	/**
	 * 地图块，继承BaseElement
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class MapTile extends CCNode
	{
		public var isSolid:Boolean;
		public var isIsland:Boolean;
		public var isMask:Boolean;
		public var isTransport:Boolean;
		
		/**
		 * @param tx,ty 块坐标
		 * @param isSolid isSolid 障碍
		 * @param isIsland isIsland 通过
		 * @param isMask isMask 遮罩（遮挡表示）
		 * @param isTransport isTransport 传送点
		 */
		public function MapTile(tx:int, ty:int, p_isSolid:Boolean=false, p_isIsland:Boolean=false, 
								p_isMask:Boolean=false, p_isTransport:Boolean=false) {
			this.TileY = ty;
			this.TileX = tx;
			this.isSolid = p_isSolid;
			this.isIsland = p_isIsland;
			this.isMask = p_isMask;
			this.isTransport = p_isTransport;
		}
	}
}