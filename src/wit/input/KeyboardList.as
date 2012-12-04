package wit.input
{
	import flash.events.KeyboardEvent;

	/**
	 * KeyboardList Interface
	 * 
	 * @author Cristobal Dabed
	 * @version 0.1
	 */
	internal interface KeyboardList
	{
		function onKeyUp(event:KeyboardEvent):void;
		function onKeyDown(event:KeyboardEvent):void;
		function removeAll():void;
		function isEmpty():Boolean;
	}
}