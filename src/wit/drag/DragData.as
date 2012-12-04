package wit.drag
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * 拖拽数据
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class DragData 
	{
		private var _canMove:Boolean;
		private var _dobj:InteractiveObject;
		private var _type:int;
		private var _showMode:int;
		private var _guiderID:Number;
		private var _criticalDis:Number;
		private var _xyRect:Rectangle;
		private var _touchRect:Rectangle;
		private var _alpha:Number;
		private var _data:Object;
		private var _stage:Stage;
		private var _face:DisplayObject;
		private var _guiderStartPoint:Point;
		private var _dobjStartPoint:Point;
		private var _dobjStartAlpha:Number;
		private var _onComplete:Function;
		private var _onCompleteParameters:Array;
		
		public function DragData(dobj:InteractiveObject, type:int=1, showMode:int=1, 
								 guiderID:int=-1, criticalDis:Number=2, xyRect:Rectangle=null, 
								 touchRect:Rectangle=null, alpha:Number=1, onComplete:Function=null, 
								 completeParameters:Array=null, data:Object=null)
		{
			super();
			
			var _local12:Sprite;
			var _local13:Rectangle;
			var _local14:BitmapData;
			var _local15:Bitmap;
			var _local16:Shape;
			_canMove = false;
			_dobj = dobj;
			_type = type;
			_showMode = showMode;
			_guiderID = guiderID;
			_criticalDis = criticalDis;
			_xyRect = xyRect;
			_touchRect = touchRect;
			_alpha = alpha;
			_onComplete = onComplete;
			_onCompleteParameters = completeParameters;
			_data = data;
			if (_dobj) {
				_stage = dobj.stage;
				_dobjStartPoint = new Point(_dobj.x, _dobj.y);
				_dobjStartAlpha = _dobj.alpha;
				if (_dobj.parent){
					switch (_showMode){
						case DragShowMode.SELF:
							_face = _dobj;
							break;
						case DragShowMode.BITMAP:
							_local14 = new BitmapData(_dobj.width, _dobj.height, true, 0);
							_local14.draw(_dobj, null, null, null, null, true);
							_local15 = new Bitmap(_local14, "auto", true);
							_local12 = new Sprite();
							_local12.addChild(_local15);
							_local12.mouseEnabled = false;
							_local13 = dobj.getBounds(dobj.parent);
							_local15.x = (_local13.x - _dobjStartPoint.x);
							_local15.y = (_local13.y - _dobjStartPoint.y);
							_local12.x = _dobjStartPoint.x;
							_local12.y = _dobjStartPoint.y;
							_face = _local12;
							break;
						case DragShowMode.FRAME:
						default:
							_local12 = new Sprite();
							_local16 = new Shape();
							_local16.graphics.clear();
							_local16.graphics.lineStyle(1, 0, 1);
							_local16.graphics.beginFill(0, 0);
							_local16.graphics.drawRect(0, 0, _dobj.width, _dobj.height);
							_local16.graphics.endFill();
							_local12.addChild(_local16);
							_local12.mouseEnabled = false;
							_local13 = dobj.getBounds(dobj.parent);
							_local16.x = (_local13.x - _dobjStartPoint.x);
							_local16.y = (_local13.y - _dobjStartPoint.y);
							_local12.x = _dobjStartPoint.x;
							_local12.y = _dobjStartPoint.y;
							_face = _local12;
					}
				}
				if (_stage) {
					_guiderStartPoint = _dobj.parent.globalToLocal(new Point(_stage.mouseX, _stage.mouseY));
				}
			}
		}
		
		public function isValid():Boolean
		{
			return (dobj != null && dobj.parent != null && !isNaN(_type) && !isNaN(_showMode) 
				&& !isNaN(_guiderID) && _guiderStartPoint != null && !isNaN(_criticalDis) 
				&& _dobjStartPoint != null && !isNaN(_dobjStartAlpha) && !isNaN(_alpha) 
				&& _stage != null);
		}
		
		public function equal(data:DragData):Boolean
		{
			return guiderID == data.guiderID && dobj == data.dobj;
		}
		
		public function get type():int
		{
			return _type;
		}
		
		public function get dobj():InteractiveObject
		{
			return _dobj;
		}
		
		public function get guiderID():int
		{
			return _guiderID;
		}
		
		public function get guiderStartPoint():Point
		{
			return _guiderStartPoint;
		}
		
		public function get dobjStartPoint():Point
		{
			return _dobjStartPoint;
		}
		
		public function get dobjStartAlpha():Number
		{
			return _dobjStartAlpha;
		}
		
		public function get criticalDis():Number
		{
			return _criticalDis;
		}
		
		public function get xyRect():Rectangle
		{
			return _xyRect;
		}
		
		public function get touchRect():Rectangle
		{
			return _touchRect;
		}
		
		public function get alpha():Number
		{
			return _alpha;
		}
		
		public function get onComplete():Function
		{
			return _onComplete;
		}
		
		public function get onCompleteParameters():Array
		{
			return _onCompleteParameters;
		}
		
		public function get data():Object
		{
			return _data;
		}
		
		public function get face():DisplayObject
		{
			return _face;
		}
		
		public function get canMove():Boolean
		{
			return _canMove;
		}
		
		public function get stage():Stage
		{
			return _stage;
		}
		
		public function set canMove(b:Boolean):void
		{
			_canMove = b;
		}
	}
}