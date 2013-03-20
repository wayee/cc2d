package cc
{
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import cc.tools.SceneCache;

    public class CCRender
	{
        public static var nowTime:int;				// 当前时间点

        private var scene:CCScene;
        private var isRendering:Boolean = false;	// 是否绘制标志, 如果在加载中, 可以不绘制

        public function CCRender(p_scene:CCScene) {
            scene = p_scene;
        }
		
        public function StartRender(p_renderNow:Boolean=false):void {
            if (p_renderNow) {
                render();
            }
			
            if ( !isRendering ) {
                scene.addEventListener(Event.ENTER_FRAME, render);
                isRendering = true;
            }
        }
		
        public function StopRender():void {
            if (isRendering) {
                scene.removeEventListener(Event.ENTER_FRAME, render);
                isRendering = false;
            }
        }
		
        private function render(e:Event=null):void {
            nowTime = getTimer();
            var charList:Array = scene.sceneCharacters;
            
            var sceneChar:CCCharacter;
			for each (sceneChar in charList) {
                sceneChar.runWalk();				// 人物移动
            }
			
            scene.sceneCamera.Run();				// 相机跟随 
            scene.sceneMapLayer.Run();				// 地图跟随
            scene.sceneAvatarLayer.Run();			// 绘制人物
			scene.sceneHeadLayer.Run();				// 绘制血条、昵称和称号等文本, 更新 Y 值
			
			// 自定义资源回收处理
            SceneCache.CheckUninstall();
        }
    }
}