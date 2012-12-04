package cc.vo.map
{
	import flash.display.DisplayObjectContainer;
	
	import cc.CCNode;

	/**
	 * 地图族
	 * <br>zone.showContainer (ShowContainer)被添加到自己的孩子中
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class MapZone extends CCNode
	{
		public function MapZone(p_maplayer:DisplayObjectContainer) {
			EnableContainer(p_maplayer);
		}
	}
} 
