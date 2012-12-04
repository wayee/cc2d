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
		public function MapTile(tx:int, ty:int, PisSolid:Boolean=false, PisIsland:Boolean=false, PisMask:Boolean=false, PisTransport:Boolean=false)
		{
			this.TileY = ty;
			this.TileX = tx;
			this.isSolid = PisSolid;
			this.isIsland = PisIsland;
			this.isMask = PisMask;
			this.isTransport = PisTransport;
		}
	}
}