package wit.draw
{	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	/**
	 * 发光效果
	 * @author Alex.li
	 */
	public class GlowTween
	{
		private var _target:InteractiveObject;
		private var _color:uint;
		private var _toggle:Boolean;
		private var _blur:Number;
		
		public function GlowTween(target:InteractiveObject, color:uint = 0xFFFFFF)
		{
			_target = target;
			_color = color;
			_toggle = true;
			_blur = 2;
			target.addEventListener(MouseEvent.ROLL_OVER, startGlowHandler);
			target.addEventListener(MouseEvent.ROLL_OUT, stopGlowHandler);	
		}
		
		public function remove():void
		{
			_target.removeEventListener(MouseEvent.ROLL_OVER, startGlowHandler);
			_target.removeEventListener(MouseEvent.ROLL_OUT, stopGlowHandler);	
			_target.removeEventListener(Event.ENTER_FRAME, blinkHandler);
			_target.filters = null;
			_target = null;
		}		
		
		private function startGlowHandler(evt:MouseEvent):void
		{
			_target.addEventListener(Event.ENTER_FRAME, blinkHandler, false, 0, true);				
		}
		
		private function stopGlowHandler(evt:MouseEvent):void
		{
			_target.removeEventListener(Event.ENTER_FRAME, blinkHandler);			
			_target.filters = null;
		}
		
		private function blinkHandler(evt:Event):void
		{
			if (_blur >= 20) _toggle = false;
			else if (_blur <= 2) _toggle = true;
			_toggle ? _blur++ : _blur--;			
			var glow:GlowFilter = new GlowFilter(_color, 1, _blur, _blur, 2, 2);
			_target.filters = [glow];	
		}
	}	
}