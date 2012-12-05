package cc.vo.map
{
	import cc.CCNode;
	
	import flash.display.DisplayObjectContainer;

	public class MapZone extends CCNode
	{
		public function MapZone(p_maplayer:DisplayObjectContainer) {
			EnableContainer(p_maplayer);
		}
	}
} 
