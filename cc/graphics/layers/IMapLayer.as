package cc.graphics.layers
{
	/**
	 * 地图层接口
	 * <li> 单地图加载方式
	 * <li> 分块地图加载方式
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public interface IMapLayer
	{
		function initMap():void;
		function run():void;
		function dispose():void;
	}
}