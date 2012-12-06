package cc.graphics.layers
{
	import cc.CCCharacter;
	import cc.CCRender;
	import cc.CCScene;
	import cc.graphics.tagger.HeadFace;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import wit.utils.Fun;
	
	public class SceneHeadLayer extends Sprite
	{
		private var _scene:CCScene;
		
		public function SceneHeadLayer(scene:CCScene)
		{
			_scene = scene;
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		public function Dispose():void {
			Fun.clearChildren(this, false, false);
		}
		
		public function Run():void {
			var sceneChar:CCCharacter;
			var mouseRect:Rectangle;
			var ypos:Number;
			var nowTime:int = CCRender.nowTime;
			var renderCharList:Array = _scene.renderCharacters;
			
			// 遍历每个可渲染对象
			for each (sceneChar in renderCharList) {
				if (sceneChar.headFace != null) {
					mouseRect = sceneChar.mouseRect || sceneChar.oldMouseRect;
					ypos = mouseRect!=null ? ((mouseRect.y - sceneChar.PixelY) - HeadFace.HEADFACE_SPACE) : HeadFace.DEFAULT_HEADFACE_Y;
					if (sceneChar.headFace.y != ypos) {
						sceneChar.headFace.y = ypos;		// 更新 Y 值
					}
					sceneChar.headFace.checkTalkTime();		// 检查说话过期时间
				}
			}
		}
	}
}