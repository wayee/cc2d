package wit.manager
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import wit.drag.DragData;
	import wit.drag.DragType;
	import wit.handler.HandlerHelper;
	import wit.log.Log4J;
	import wit.utils.Fun;

	/**
	 * 拖拽管理器
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class DragManager
	{
        private static var _dragArr:Array = [];
        private static var TEvent:Class = MouseEvent;
        private static var _stage:Stage;

        public function DragManager()
		{
            throw new Error('This is a static class.');
        }
        
		/**
		 * 添加拖拽
		 * @param dragData DragData
		 */
		public static function addDrag(dragData:DragData):void
		{
            var tmpData:DragData;
            var pos:Point;
            if (!dragData) {
                return;
            }
            if (!dragData.isValid()) {
                return;
            }
            if (dragData.touchRect) {
                pos = dragData.dobj.globalToLocal(dragData.dobj.parent.localToGlobal(dragData.guiderStartPoint));
                if (!dragData.touchRect.containsPoint(pos)) {
                    return;
                }
            }
            for each (tmpData in _dragArr) {
                if (tmpData.equal(dragData)) {
                    return;
                }
                if (tmpData.guiderID == dragData.guiderID) {
                    removeDrag(tmpData);
                    break;
                }
            }
            if (dragData.face != dragData.dobj) {
                dragData.dobj.parent.addChild(dragData.face);
                if (dragData.type == DragType.DROP) {
                    dragData.dobj.visible = false;
                }
            }
            dragData.dobj.mouseEnabled = false;
            _dragArr[_dragArr.length] = dragData;
            Log4J.add(("DragManager::addDrag()::_dragArr.length:" + _dragArr.length));
            if (_dragArr.length == 1) {
                _stage = dragData.stage;
                EventManager.addEvent(Event.ENTER_FRAME, update, _stage);
                EventManager.addEvent(TEvent.MOUSE_UP, mouseUpHandle, _stage, false, 0, true);
            }
        }
		
		/**
		 * 根据guiderID删除一个拖拽 
		 * @param guiderID
		 * @return drag dragData
		 */
        public static function removeDragByGuiderID(guiderID:int):DragData
		{
            var tmpData:DragData;
            for each (tmpData in _dragArr) {
                if (tmpData.guiderID == guiderID) {
                    removeDrag(tmpData);
                    return tmpData;
                }
            }
            return null;
        }
		
		/**
		 * 根据drag data删除一个拖拽 
		 * @param data DragData
		 */
        public static function removeDrag(data:DragData):void
		{
            if (!data){
                return;
            }
            if (data.type == DragType.DROP){
                doTween(data);
            }
            data.face.alpha = data.dobjStartAlpha;
            var index:int = _dragArr.indexOf(data);
            if (index != -1) {
                _dragArr.splice(index, 1);
                Log4J.add(("DragManager::removeDrag()::_dragArr.length:" + _dragArr.length));
            }
        }
		
		/**
		 * 删除所有的拖拽 
		 */
        public static function removeAllDrags():void
		{
            var tmpData:DragData;
            for each (tmpData in _dragArr) {
                if (tmpData.type == DragType.DROP) {
                    doTween(tmpData);
                }
                tmpData.face.alpha = tmpData.dobjStartAlpha;
            }
            _dragArr = [];
            Log4J.add("DragManager::removeAllDrags()::_dragArr.length:0");
        }
		
        private static function update(event:Event):void
		{
            var pos:Point;
            var tmpData:DragData;
            for each (tmpData in _dragArr) {
                if (Fun.isParentChild(tmpData.stage, tmpData.dobj)) {
                    if (tmpData.guiderID == -1) {
                        pos = tmpData.dobj.parent.globalToLocal(new Point(tmpData.stage.mouseX, tmpData.stage.mouseY));
                    }
                    if (pos) {
                        if (Point.distance(pos, tmpData.guiderStartPoint) > tmpData.criticalDis){
                            tmpData.canMove = true;
                        }
                        if (tmpData.canMove) {
                            setPos(tmpData.face, pos, tmpData);
                            tmpData.face.alpha = tmpData.alpha;
                        }
                    }
                } else {
                    removeDrag(tmpData);
                }
            }
            if (_dragArr.length == 0) {
                EventManager.removeEvent(Event.ENTER_FRAME, update, _stage);
                EventManager.removeEvent(TEvent.MOUSE_UP, mouseUpHandle, _stage, false);
            }
        }
		
		/**
		 * 设置位置 
		 * @param disp
		 * @param pos
		 * @param data
		 */
        private static function setPos(disp:DisplayObject, pos:Point, data:DragData):void
		{
            if (!disp || !data) {
                return;
            }
			var posX:Number = data.dobjStartPoint.x + (pos.x - data.guiderStartPoint.x);
			var posY:Number = data.dobjStartPoint.y + (pos.y - data.guiderStartPoint.y);
            if (data.xyRect) {
                if (posX < data.xyRect.x) {
                    posX = data.xyRect.x;
                }
                if (posX > (data.xyRect.x + data.xyRect.width)) {
                    posX = (data.xyRect.x + data.xyRect.width);
                }
                if (posY < data.xyRect.y) {
                    posY = data.xyRect.y;
                }
                if (posY > (data.xyRect.y + data.xyRect.height)) {
                    posY = (data.xyRect.y + data.xyRect.height);
                }
            }
            disp.x = posX;
            disp.y = posY;
        }
		
		/**
		 * 鼠标事件处理 
		 * @param event MouseEvent
		 */
        private static function mouseUpHandle(event:MouseEvent=null):void
		{
            var dropToTarget:* = null;
            var arr:* = null;
            var iObj:* = null;
            var item:* = null;
            var e:MouseEvent = event;
            var eID:* = (e is MouseEvent) ? -1 : /*e.ID*/ 0;
            var dragData:DragData = DragManager.removeDragByGuiderID(eID);
            if (!dragData) {
                return;
            }
            var stageXY:Point = new Point(e.stageX, e.stageY);
            if (dragData.type == DragType.DRAG) {
                if (dragData.face != dragData.dobj && dragData.face.parent) {
                    dragData.face.parent.removeChild(dragData.face);
                }
                setPos(dragData.dobj, dragData.dobj.parent.globalToLocal(stageXY), dragData);
                dragData.dobj.mouseEnabled = true;
            } else {
                if (dragData.type == DragType.DROP) {
                    arr = dragData.stage.getObjectsUnderPoint(stageXY);
                    for each (item in arr) {
                        iObj = (item as InteractiveObject);
                        if (iObj && iObj.mouseEnabled) {
                            dropToTarget = iObj;
                            break;
                        }
                    }
                    if (dropToTarget && dropToTarget.hasOwnProperty("dropIn")) {
                        try {
                            (dropToTarget as Object).dropIn(dragData.data);
//                            TweenMax.killTweensOf(dragData.face, true);
                        } catch(e:Error) {
                        }
                    }
                }
            }
            if (dragData.onComplete != null) {
                HandlerHelper.execute(dragData.onComplete, dragData.onCompleteParameters);
            }
        }
		
        private static function doTween(dragData:DragData, duration:Number=0.2):void
		{
            if (!dragData) {
                return;
            }
            if (!dragData.isValid()) {
                return;
            }
            if (dragData.type != DragType.DROP) {
                return;
            }
            try {
//                TweenMax.to(dragData.face, duration, {
//                    x:dragData.dobjStartPoint.x,
//                    y:dragData.dobjStartPoint.y,
//                    onComplete:tweenComplete,
//                    onCompleteParams:[dragData]
//                });
            } catch(e:Error) {
                dragData.face.x = dragData.dobjStartPoint.x;
                dragData.face.y = dragData.dobjStartPoint.y;
                tweenComplete(dragData);
            }
        }
		
        private static function tweenComplete(dragData:DragData):void
		{
            if (!dragData) {
                return;
            }
            if (!dragData.isValid()) {
                return;
            }
            if (dragData.type != DragType.DROP) {
                return;
            }
            if ( dragData.face != dragData.dobj && dragData.face.parent ) {
                dragData.face.parent.removeChild(dragData.face);
            }
            dragData.dobj.x = dragData.dobjStartPoint.x;
            dragData.dobj.y = dragData.dobjStartPoint.y;
            dragData.dobj.alpha = dragData.dobjStartAlpha;
            dragData.dobj.mouseEnabled = true;
            dragData.dobj.visible = true;
        }
    }
}