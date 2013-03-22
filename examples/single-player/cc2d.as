package
{
	import com.demonsters.debugger.MonsterDebugger;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import wit.log.SWFProfiler;
	
	[SWF(width="1440", height="900", backgroundColor="0x000000", frameRate="24")]
	public class cc2d extends Sprite
	{
		private var app:GameApp;
		
		public function cc2d() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event=null):void {
			SWFProfiler.init(stage, this);
			
			MonsterDebugger.initialize(this);
			MonsterDebugger.trace(this, "Hello World!");
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.stageFocusRect = false;
//			stage.showDefaultContextMenu = false;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
//			var loaderApp:LoaderApp = new LoaderApp;
//			addChild(loaderApp);
			
			app = new GameApp;
			addChild(app);
			app.Startup();
			
			if (this.stage) {
				this.stage.addEventListener(Event.RESIZE, __onResize);
			}
		}
		
		private function __onResize(event:Event):void
		{
			if (this.stage) {
				var w:Number = this.stage.stageWidth;
				var h:Number = this.stage.stageHeight;
				if (app) app.ResizeStage(w, h);
			}
		}
	}
}