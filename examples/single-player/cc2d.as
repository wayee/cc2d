package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import wit.log.SWFProfiler;
	
	[SWF(width="1200", height="650", backgroundColor="0x000000", frameRate="30")]
	public class cc2d extends Sprite
	{
		private var app:GameApp;
		
		public function cc2d() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event=null):void {
			SWFProfiler.init(stage, this);
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.stageFocusRect = false;
//			stage.showDefaultContextMenu = false;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			app = new GameApp;
			app.Startup();
			addChild(app);
		}
	}
}