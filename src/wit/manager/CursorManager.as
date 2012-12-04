package wit.manager
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	
	import wit.handler.HandlerHelper;

	/**
	 * 鼠标指针管理器
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class CursorManager
	{
        private static var _stage:Stage;
        private static var _face:DisplayObject;
        private static var _data:Object;
        private static var _cursorPositionUV:Point;
        private static var _onClick:Function;
        private static var _onClickParameters:Array;
        private static var _onInvalidClick:Function;
        private static var _onInvalidClickParameters:Array;

        public function CursorManager()
		{
            throw new Error('This is a static class.');
        }
		
        public static function init(stage:Stage):void
		{
            _stage = stage;
        }
		
		/**
		 * 显示指针 
		 * @param disp 指针对象
		 * @param data 数据
		 * @param cursorPositionUV 位置偏移
		 * @param onClick
		 * @param onClickParameters
		 * @param onInvalidClick
		 * @param onInvalidClickParameters
		 */
        public static function showCursor(disp:DisplayObject=null, data:Object=null, 
										  cursorPositionUV:Point=null, onClick:Function=null, 
										  onClickParameters:Array=null, onInvalidClick:Function=null, onInvalidClickParameters:Array=null):void
		{
            if (_stage == null) {
                throw new Error('doesn\'t init stage');
            }
            var tmpDisp:DisplayObject = _face;
            _face = disp;
            _data = data;
            _cursorPositionUV = cursorPositionUV;
            _onClick = onClick;
            _onClickParameters = onClickParameters;
            _onInvalidClick = onInvalidClick;
            _onInvalidClickParameters = onInvalidClickParameters;
            if (tmpDisp != _face) {
                if (tmpDisp != null){
                    if (tmpDisp.parent == _stage) {
                        _stage.removeChild(tmpDisp);
                    }
                }
                if (_face != null) {
                    Mouse.hide();
                    _stage.addChild(disp);
                    if (tmpDisp == null) {
                        _stage.addEventListener(Event.ADDED, onAdded);
                        _stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
                        _stage.addEventListener(MouseEvent.CLICK, mouseClickHandle, true);
                    }
                } else {
                    Mouse.show();
                    if (tmpDisp != null) {
                        _stage.removeEventListener(Event.ADDED, onAdded);
                        _stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                        _stage.removeEventListener(MouseEvent.CLICK, mouseClickHandle, true);
                    }
                }
            }
        }
		
		/**
		 * 清除自定义鼠标指针 
		 */
        public static function clear():void
		{
            showCursor(null, null, null);
        }
		
        public static function get data():Object
		{
            return _data;
        }
		
        private static function onAdded(event:Event):void
		{
            if (_face.parent == _stage) {
                _stage.setChildIndex(_face, _stage.numChildren - 1);
            }
        }
		
        private static function onEnterFrame(event:Event):void
		{
            var rect:Rectangle = _face.getBounds(_face);
            if (!_cursorPositionUV) {
                _face.x = _stage.mouseX - rect.x;
                _face.y = _stage.mouseY - rect.y;
            } else {
                _face.x = (_stage.mouseX - rect.x) - (rect.width * _cursorPositionUV.x);
                _face.y = (_stage.mouseY - rect.y) - (rect.height * _cursorPositionUV.y);
            }
        }
		
		/**
		 * 单击处理 
		 */
        private static function mouseClickHandle(event:MouseEvent):void
		{
            var dropToTarget:Object = null;
            var iObj:InteractiveObject = null;
            var item:DisplayObject = null;
            var e:MouseEvent = event;
            var stageXY:Point = new Point(e.stageX, e.stageY);
            var arr:Array = _stage.getObjectsUnderPoint(stageXY);
            for each (item in arr) {
                iObj = item as InteractiveObject;
                if (iObj && iObj.mouseEnabled) {
                    dropToTarget = iObj;
                    break;
                }
            }
			
            if (dropToTarget && dropToTarget.hasOwnProperty("dropIn")) {
                try {
                    (dropToTarget as Object).dropIn(_data);
                } catch(e:Error) {
                }
                HandlerHelper.execute(_onClick, _onClickParameters);
            } else {
                HandlerHelper.execute(_onInvalidClick, _onInvalidClickParameters);
            }
        }
    }
}