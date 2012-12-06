package cc.graphics.layers
{
	import cc.CCScene;
	
	import flash.display.Sprite;
	
	import wit.utils.Fun;

    public class SceneSmallMapLayer extends Sprite
	{
        private var scene:CCScene;

        public function SceneSmallMapLayer(p_scene:CCScene) {
            scene = p_scene;
            mouseEnabled = false;
            mouseChildren = false;
        }
        
		public function Dispose():void {
            Fun.clearChildren(this, false, false);
        }
    }
}