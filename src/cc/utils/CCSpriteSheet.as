package cc.utils
{
	import cc.tools.SceneCache;
	import cc.vo.avatar.AvatarImgData;
	import cc.vo.avatar.AvatarPartStatus;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Sprite Sheet动画
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class CCSpriteSheet extends Sprite
	{
		public static const ZERO_POINT:Point = new Point();
		public static const MOUSE_ON_GLOWFILTER:GlowFilter = new GlowFilter(0xFFFFFF, 0.7, 7, 7, 4, 1);
		
		private var _bitmap:Bitmap;
		private var _apsRes:Object;
		private var _currentAvatarPartStatus:AvatarPartStatus;
		private var _sourcePoint:Point = null;
		
		private var _isPlaying:Boolean;
		private var _currentFrame:int; // 首帧为1开始
		private var _currentStatus:String; // 当前状态，如stand, walk etc.
		private var _interval:int;	// 每帧间隔
		private var _index:int; // 当前计数
		private var _preWidth:Number;
		private var _preHeight:Number;
		private var _currentLogicAngle:int;
		private var _data:Object;
		public var index:int;
		
		/**
		 * Sprite Sheet动画 
		 * @param status 当前状态， 如stand, walk etc
		 * @param aps 动画配置数据
		 * 
		 */
		public function CCSpriteSheet(status:String, aps:Object, angle:int=0)
		{
			_bitmap = new Bitmap;
			addChild(_bitmap);
			
			_index = 0;
			_apsRes = aps;
			_currentAvatarPartStatus = aps[status];
			_currentStatus = status;
			_currentLogicAngle = angle;
			
			_sourcePoint = new Point;
			
//			_bitmap.x = -(_currentAvatarPartStatus.tx);
//			_bitmap.y = -(_currentAvatarPartStatus.ty);
			
			addEventListener(Event.ADDED_TO_STAGE, __addToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, __onRemovedFromStage);
		}
		
		public function play():void
		{
			_isPlaying = true;
			__updateStatus();
		}
		
		public function stop():void
		{
			_isPlaying = false;
			__updateStatus();
		}
		
		public function run():void
		{
			var source_x:int;
			var source_y:int;
			
			_currentFrame++;
			if (_currentFrame >= _currentAvatarPartStatus.frame) {
				_currentFrame = 0;
			}
			
			// 角度转换: 0, 4567, 左右镜像
			if (_currentLogicAngle == 0 || _currentLogicAngle >= 4) {
				source_x = _currentFrame;
				if (_currentLogicAngle == 0 || _currentLogicAngle == 4) {
					source_y = _currentLogicAngle;		// 0/4
				} else {
					if (_currentLogicAngle == 7) {
						source_y = 1;						// 7
					} else {
						if (_currentLogicAngle == 6) {
							source_y = 2;					// 6
						} else {
							if (_currentLogicAngle == 5) {
								source_y = 3;				// 5
							}
						}
					}
				}
			} else {
				source_x = ((_currentAvatarPartStatus.frame - _currentFrame) - 1);
				source_y = (_currentLogicAngle - 1);
			}
			
			// 只有一个角度，只取一行
			if (_currentAvatarPartStatus.only1Angle == 1) {
				source_y = 0;
			}
			
			// 计算源像素位置
			_sourcePoint.x = (source_x * _currentAvatarPartStatus.width);		// 像素坐标
			_sourcePoint.y = (source_y * _currentAvatarPartStatus.height);
			
			var rect:Rectangle = new Rectangle(_sourcePoint.x, _sourcePoint.y, _currentAvatarPartStatus.width, _currentAvatarPartStatus.height);
			var tmpBmd:BitmapData = new BitmapData(_currentAvatarPartStatus.width, _currentAvatarPartStatus.height);
			tmpBmd.copyPixels(sourceBitmapData, rect, ZERO_POINT);
			
			_bitmap.bitmapData = tmpBmd;
			
			if (_currentLogicAngle == 0 || _currentLogicAngle >= 4) {
				_bitmap.x = -(_currentAvatarPartStatus.tx);
			} else {
				_bitmap.x = _currentAvatarPartStatus.tx - _currentAvatarPartStatus.width;
			}
			_bitmap.y = -(_currentAvatarPartStatus.ty);
		}
		
		/**
		 * 应用滤镜 
		 */
		public function applyFilter():void
		{
			_bitmap.filters = [MOUSE_ON_GLOWFILTER];
		}
		public function removeFilter():void
		{
			_bitmap.filters = [];
		}
		
		/**
		 * 是否平滑处理 
		 * @return 
		 * 
		 */
		public function get smoothing():Boolean
		{
			return _bitmap.smoothing;
		}
		
		public function set smoothing(value:Boolean):void
		{
			_bitmap.smoothing = value;
		}
		
		public function get currentFrame():int
		{
			return _currentFrame;
		}
		
		public function get totalFrames():int
		{
			return _currentAvatarPartStatus.frame;
		}
		
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		private function __updateStatus():void
		{
			if (_isPlaying && totalFrames != 0 && stage != null) {
				addEventListener(Event.ENTER_FRAME, __onEnterFrame);
			}
		}
		
		private function __onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, __onEnterFrame);
		}

		private function __onEnterFrame(event:Event):void
		{
			_index++;
			if (_index >= _interval) {
				_index = 0;
				run();
			} 
		}
		
		/**
		 * 对象加入舞台 
		 * @param event
		 * 
		 */
		private function __addToStage(event:Event):void
		{
			_preWidth = _currentAvatarPartStatus.width;
			_preHeight = _currentAvatarPartStatus.height;
			
			_parseBitmapData();
			__updateStatus();
		}
		
		private var _sourceBitmapDataObj:AvatarImgData;
		private function _parseBitmapData():void
		{
			_interval = _currentAvatarPartStatus.delay/CCG.frameRate;
			if (_currentAvatarPartStatus && _currentAvatarPartStatus.classNamePrefix) {
				var resName:String = _currentAvatarPartStatus.classNamePrefix + this._currentStatus;
				_sourceBitmapDataObj = SceneCache.installAvatarImg(resName, _currentAvatarPartStatus.only1Angle==1);
			}
		}
		
		/**
		 * 获取当前位图数据
		 */
		private function get sourceBitmapData():BitmapData
		{
			var bitmapData:BitmapData;
			if (_sourceBitmapDataObj != null) {
				if (_currentLogicAngle == 0 || _currentLogicAngle >= 4) {
					bitmapData = _sourceBitmapDataObj.dir07654;		// 正像
				} else {
					bitmapData = _sourceBitmapDataObj.dir123;			// 镜像
				}
			}
			return bitmapData || new BitmapData(1, 1, true, 0);
		}
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		public function playTo(status:String=null, logicAngle:int=-1):void
		{
			if (status != null){
				this._currentStatus = status;
			}
			if (logicAngle != -1) {
				this._currentLogicAngle = logicAngle;
			}
			_currentAvatarPartStatus = _apsRes[status];
			_currentFrame = 0;
			_parseBitmapData();
		}
		
		public function setAngle(angle:int):void
		{
			_currentLogicAngle = angle;
			_currentFrame = 0;
			_parseBitmapData();
		}
		
		public function setStatus(status:String):void
		{
			_currentStatus = status;
			_currentAvatarPartStatus = _apsRes[status];
			_currentFrame = 0;
			_parseBitmapData();
		}
		
		public function dispose():void
		{
			stop();
			
			_currentAvatarPartStatus = null;
			if (contains(_bitmap)) removeChild(_bitmap);
		}
		
		public function get preWidth():Number
		{
			return _preWidth;
		}
		public function get preHeight():Number
		{
			return _preHeight;
		}
		
		public function getBitmap():Bitmap
		{
			return _bitmap;
		}

		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}

	}
}