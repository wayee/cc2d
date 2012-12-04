package cc.graphics.layers
{
	import flash.display.Sprite;
	import wit.utils.Fun;
	import cc.CCScene;

	/**
	 * 小地图层
	 *  <li> 显示小地图
	 * 	<li> mouseEnabled = false;
	 * 	<li> mouseChildren = false;
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class SceneSmallMapLayer extends Sprite
	{
        private var _scene:CCScene;

        public function SceneSmallMapLayer(scene:CCScene)
		{
            this._scene = scene;
            mouseEnabled = false;
            mouseChildren = false;
        }
        
		/**
		 * 释放资源 
		 */
		public function dispose():void
		{
            Fun.clearChildren(this, false, false);
        }
    }
}