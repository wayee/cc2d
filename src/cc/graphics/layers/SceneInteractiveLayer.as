package cc.graphics.layers
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import wit.draw.DrawHelper;
	import wit.draw.StyleData;
	import wit.log.Log4J;
	import cc.events.CCEvent;
	import cc.events.CCEventActionInteractive;
	import cc.CCScene;
	import cc.CCCharacter;
	import cc.vo.map.MapTile;
	import wit.manager.EventManager;
	
	/**
	 * 场景交互层
	 * <li>对场景内的对象, 发送鼠标消息通知
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class SceneInteractiveLayer extends Sprite
	{

        private static const DOUBLE_CLICK_TIME:int = 500;
        private static const DOUBLE_CLICK_DIS:Number = 100;

        private var _scene:CCScene;
        private var _fristMouseDownTime:int = -1;
        private var _fristMouseDownPos:Point = null;

        public function SceneInteractiveLayer(scene:CCScene) {
            _scene = scene;
            doubleClickEnabled = false;
        }
		
		/**
		 * 绘制遮罩接收鼠标消息, 同地图一样尺寸
		 */
        public function InitRange():void {
            DrawHelper.drawRect(this, new Point(0, 0), new Point(_scene.mapConfig.width, _scene.mapConfig.height), 
				new StyleData(0, 0, 0, 0, 0), true);
        }
		
        public function EnableInteractiveHandle():void {
            addEventListener(MouseEvent.MOUSE_DOWN, mouseHandle);
            addEventListener(MouseEvent.MOUSE_MOVE, mouseHandle);
            addEventListener(MouseEvent.MOUSE_OUT, mouseHandle);
			if (stage) stage.addEventListener(MouseEvent.MOUSE_UP, mouseHandle);
        }
		
        public function DisableInteractiveHandle():void {
            removeEventListener(MouseEvent.MOUSE_DOWN, mouseHandle);
            removeEventListener(MouseEvent.MOUSE_MOVE, mouseHandle);
            removeEventListener(MouseEvent.MOUSE_OUT, mouseHandle);
			if (stage) stage.removeEventListener(MouseEvent.MOUSE_UP, mouseHandle);
        }
		
        private function mouseHandle(event:MouseEvent):void {
            var sceneCharList:Array;
            var sceneEvent:CCEvent;
            var sceneChar:CCCharacter;
            var mapTile:MapTile;
            var curTime:int;
            var mousePos:Point = new Point(mouseX, mouseY);
			
            switch (event.type) {
                case MouseEvent.MOUSE_MOVE:
                    sceneCharList = _scene.GetSceneObjectsUnderPoint(mousePos);		// 获得当前位置所有对象
                    mapTile = sceneCharList[0];	// 获得第一个对象
					
                    if (mapTile != null){
                        if (sceneCharList.length > 1) {
                            sceneChar = getHitSceneCharacter(sceneCharList[1], mousePos);
                        } else { // NPC HeadFace
							sceneCharList = _scene.GetSceneObjectsUnderPointEx(mousePos);
							sceneChar = sceneCharList[1][0] as CCCharacter;
						}
                        sceneEvent = new CCEvent(CCEvent.INTERACTIVE, CCEventActionInteractive.MOUSE_MOVE, [event, sceneChar, mapTile]);
						EventManager.dispatchEvent(sceneEvent, CCScene.eventCenter);
                    }
                    break;
                case MouseEvent.MOUSE_DOWN:
                    sceneCharList = _scene.GetSceneObjectsUnderPoint(mousePos); // [MapTile, [CCCharacter, ...]]
                    mapTile = sceneCharList[0];
                    if (mapTile != null){
                        if (sceneCharList.length > 1){
                            sceneChar = getHitSceneCharacter(sceneCharList[1], mousePos);
                        }else { // NPC HeadFace
							sceneCharList = _scene.GetSceneObjectsUnderPointEx(mousePos);
							sceneChar = sceneCharList[1][0] as CCCharacter;
						}
                        curTime = getTimer();
						
						// x*x + y*y
//						var posXX:Number = (_fristMouseDownPos.x - mousePos.x) * (_fristMouseDownPos.x - mousePos.x) + (_fristMouseDownPos.y - mousePos.y) * (_fristMouseDownPos.y - mousePos.y);
						
                        if (_fristMouseDownTime == -1 || (curTime - _fristMouseDownTime) > DOUBLE_CLICK_TIME || 
							_fristMouseDownPos == null || ((_fristMouseDownPos.x - mousePos.x) * (_fristMouseDownPos.x - mousePos.x) + (_fristMouseDownPos.y - mousePos.y) * (_fristMouseDownPos.y - mousePos.y)) > DOUBLE_CLICK_DIS * DOUBLE_CLICK_DIS) {
                            
							_fristMouseDownTime = curTime;
                            _fristMouseDownPos = mousePos;
                            sceneEvent = new CCEvent(CCEvent.INTERACTIVE, CCEventActionInteractive.MOUSE_DOWN, [event, sceneChar, mapTile, mousePos]);
							EventManager.dispatchEvent(sceneEvent, CCScene.eventCenter);
                        } else {
                            _fristMouseDownTime = -1;
                            _fristMouseDownPos = null;
                            sceneEvent = new CCEvent(CCEvent.INTERACTIVE, CCEventActionInteractive.DOUBLE_CLICK, [event, sceneChar, mapTile]);
							EventManager.dispatchEvent(sceneEvent, CCScene.eventCenter);
                        }
                    }
                    break;
                case MouseEvent.MOUSE_UP:
//					ZLog.add('SceneInteractive: MouseEvent.MOUSE_UP');
                    sceneEvent = new CCEvent(CCEvent.INTERACTIVE, CCEventActionInteractive.MOUSE_UP, [event, null, null]);
					EventManager.dispatchEvent(sceneEvent, CCScene.eventCenter);
                    break;
                case MouseEvent.MOUSE_OUT:
//					ZLog.add('SceneInteractive: MouseEvent.MOUSE_OUT');
                    sceneEvent = new CCEvent(CCEvent.INTERACTIVE, CCEventActionInteractive.MOUSE_OUT, [event, null, null]);
					EventManager.dispatchEvent(sceneEvent, CCScene.eventCenter);
                    break;
            }
        }
		
		/**
		 * 鼠标命中测试
		 * @param charList 多个对象列表 [CCCharacter, ...]
		 * @param mousePos 鼠标点击位置
		 * @return 返回被点击的对象
		 */	
        private function getHitSceneCharacter(charList:Array, mousePos:Point):CCCharacter {
            var sceneChar:CCCharacter;
            for each (sceneChar in charList) {
                if (sceneChar.hitPoint(mousePos)) {
                    return sceneChar;
                }
            }
            return null;
        }
    }
}