package cc
{
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import cc.tools.SceneCache;

    public class CCRender
	{
        public static var nowTime:int;				// 当前时间点

        private var _scene:CCScene;
        private var isRendering:Boolean = false;	// 是否绘制标志, 如果在加载中, 可以不绘制

        public function CCRender(scene:CCScene) {
            _scene = scene;
        }
		
        public function startRender(renderNow:Boolean=false):void {
            if (renderNow) {
                render();
            }
			
            if ( !isRendering ) {
                _scene.addEventListener(Event.ENTER_FRAME, render);
                isRendering = true;
            }
        }
		
        public function stopRender():void {
            if (isRendering) {
                _scene.removeEventListener(Event.ENTER_FRAME, render);
                isRendering = false;
            }
        }
		
        private function render(e:Event=null):void {
            nowTime = getTimer();
            var charList:Array = _scene.sceneCharacters;
            
            var sceneChar:CCCharacter;
			for each (sceneChar in charList) {
                sceneChar.runWalk();				// 人物移动
            }
			
            _scene.sceneCamera.run();				// 相机跟随 
            _scene.sceneMapLayer.run();				// 地图跟随
            _scene.sceneAvatarLayer.run();			// 绘制人物
			_scene.sceneHeadLayer.run();			// 绘制血条、昵称和称号等文本, 更新 Y 值
			
			// 自定义资源回收处理
            SceneCache.checkUninstall();
        }
    }
}