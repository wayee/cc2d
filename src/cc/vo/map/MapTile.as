package cc.vo.map
{
	import cc.CCNode;

	public class MapTile extends CCNode
	{
		public var isSolid:Boolean;
		public var isIsland:Boolean;
		public var isMask:Boolean;
		public var isTransport:Boolean;
		
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