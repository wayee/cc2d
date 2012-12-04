package cc.graphics.tagger
{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import cc.CCRender;
	import cc.tools.ScenePool;
	import wit.pool.IPoolObject;
	import wit.utils.Fun;

	/**
	 * 昵称/称号/图标/血条/对话文字
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class HeadFace extends Sprite implements IPoolObject
	{
		public static const HEADFACE_SPACE:int = 5;
        public static const DEFAULT_HEADFACE_Y:int = -100;
        private static const BAR_WIDTH:int = 60;
        private static const BAR_HEIGHT:int = 3;
        private static const LEFT_ICO_SPACE:int = 2;
        private static const TOP_ICO_SPACE:int = 2;
        private static const BOTTOM_BAR_SPACE:int = 2;

		// 昵称
        private var _nickName:String;
        private var _nickNameColor:uint;
        private var _showNickName:Boolean = true;
		// 自定义称号
        private var _customTitle:String;
        private var _showCustomTitle:Boolean = true;
		// 左侧图标
        private var _leftIco:DisplayObject;
        private var _showLeftIco:Boolean = true;
		// 上面图标
        private var _topIco:DisplayObject;
		
		private var _topMc:MovieClip;
        private var _showTopIco:Boolean = true;
		// 条
        private var _barNow:int;
        private var _barTotal:int;
        private var _showBar:Boolean = true;
		// 对话文字 
        private var _talkText:String;
        private var _talkTextColor:int;
        private var _talkTime:int = 0;
        private var _talkTimeDelay:int = 8000;
        private var _showTalkText:Boolean = true;
        private var _mainBitmap:Bitmap;
        private var _barShape:Shape;
        private var _barBackShape:Shape;
        private var _talkBitmap:Bitmap;

        public function HeadFace(nickName:String="", nickNameColor:uint=0xFFFFFF, customTitle:String="", 
								 leftIcon:DisplayObject=null, topIcon:DisplayObject=null)
		{
            reset([nickName, nickNameColor, customTitle, leftIcon, topIcon]);
        }
		
		public function get topMc():MovieClip
		{
			return _topMc;
		}

		public function set topMc(value:MovieClip):void
		{
			_topMc = value;
		}

		public function set topIco(value:DisplayObject):void
		{
			_topIco = value;
		}

		/**
		 * 创建一个headface
		 * @param nickName 昵称
		 * @param nickNameColor 昵称文字颜色
		 * @param customTitle 称号
		 * @param leftIcon 左边图标
		 * @param topIcon 顶部图标
		 * @return HeadFace
		 */
        public static function createHeadFace(nickName:String="", nickNameColor:uint=0xFFFFFF, 
											  customTitle:String="", leftIcon:DisplayObject=null, 
											  topIcon:DisplayObject=null):HeadFace
		{
            return ScenePool.headFacePool.createObj(HeadFace, nickName, nickNameColor, customTitle, leftIcon, topIcon) as HeadFace;
        }
		
		/**
		 * 回收对象到对象池 
		 * @param hf
		 */
        public static function recycleHeadFace(hf:HeadFace):void
		{
            ScenePool.headFacePool.disposeObj(hf);
        }

		/**
		 * 获取昵称
		 */
        public function get nickName():String
		{
            return _nickName;
        }
		
		/**
		 * 获取昵称文字颜色 
		 */
        public function get nickNameColor():uint
		{
            return _nickNameColor;
        }
		
		/**
		 * 获取称号 
		 */
        public function get customTitle():String
		{
            return _customTitle;
        }
		
		/**
		 * 获取左边的图标 
		 */
        public function get leftIco():DisplayObject
		{
            return _leftIco;
        }
		
		/**
		 * 获取顶部的图标 
		 */
        public function get topIco():DisplayObject
		{
            return _topIco;
        }
		
		/**
		 * 血条当前值 
		 */
        public function get barNow():int
		{
            return _barNow;
        }
		
		/**
		 * 血条总数 
		 */
        public function get barTotal():int
		{
            return _barTotal;
        }
		
		/**
		 * 对话文字 
		 */
        public function get talkText():String
		{
            return _talkText;
        }
		
		/**
		 * 对话文字颜色 
		 */
        public function get talkTextColor():int
		{
            return _talkTextColor;
        }
		
		/**
		 * 释放资源 
		 */
        public function dispose():void
		{
            Fun.clearChildren(this, true);
            _nickName = "";
            _nickNameColor = 0xFFFFFF;
            _customTitle = "";
            _leftIco = null;
            _topIco = null;
			_topMc = null;
            _barNow = 0;
            _barTotal = 0;
            _showNickName = true;
            _showCustomTitle = true;
            _showLeftIco = true;
            _showTopIco = true;
            _showBar = true;
            _showTalkText = true;
            _mainBitmap = null;
            _barShape = null;
            _barBackShape = null;
            _talkBitmap = null;
            visible = true;
        }
		
		/**
		 * 重置
		 * @param arr [nickName, nickNameColor, customTitle, leftIcon, topIcon]
		 */
        public function reset(arr:Array):void
		{
            _nickName = arr[0];
            _nickNameColor = arr[1];
            _customTitle = arr[2];
            _leftIco = arr[3];
            _topIco = arr[4];
			_topMc = arr[5];
            drawMain();
        }
		
        public function setHeadFaceNickNameVisible(b:Boolean):void
		{
            _showNickName = b;
            drawMain();
        }
		
        public function setHeadFaceCustomTitleVisible(b:Boolean):void
		{
            _showCustomTitle = b;
            drawMain();
        }
		
        public function setHeadFaceLeftIcoVisible(b:Boolean):void
		{
            _showLeftIco = b;
            drawMain();
        }
		
        public function setHeadFaceTopIcoVisible(b:Boolean):void
		{
            _showTopIco = b;
            drawMain();
        }
		
        public function setHeadFaceBarVisible(b:Boolean):void
		{
            _showBar = b;
            if (_barBackShape != null){
                _barBackShape.visible = _showBar;
            }
            if (_barShape != null){
                _barShape.visible = _showBar;
            }
            drawMain();
        }
		
        public function setHeadFaceTalkTextVisible(b:Boolean):void
		{
            _showTalkText = b;
            drawTalk();
        }
		
        public function setHeadFaceNickName(name:String="", nickNameColor:uint=0xFFFFFF):void
		{
            reset([name, nickNameColor, _customTitle, _leftIco, _topIco,_topMc]);
        }
		
        public function setHeadFaceCustomTitleHtmlText(title:String=""):void
		{
            reset([_nickName, _nickNameColor, title, _leftIco, _topIco,_topMc]);
        }
		
        public function setHeadFaceLeftIco(disp:DisplayObject=null):void
		{
            reset([_nickName, _nickNameColor, _customTitle, disp, _topIco,_topMc]);
        }
		
        public function setHeadFaceTopIco(disp:DisplayObject=null):void
		{
            reset([_nickName, _nickNameColor, _customTitle, _leftIco, disp]);
        }
		
		public function setHeadFaceTopMc(disp:MovieClip=null):void
		{
			reset([_nickName, _nickNameColor, _customTitle, _leftIco, _topIco , disp]);
		}
		
		
		
        public function setHeadFaceBar(barNow:int, barTotal:int):void
		{
            if (barNow < 0){
                barNow = 0;
            }
            if (barTotal < 0){
                barTotal = 0;
            }
            if (barTotal == 0){
                return;
            }
            _barNow = barNow;
            barNow > barTotal ? _barTotal = barNow : _barTotal = barTotal;
            if (_barBackShape == null || _barShape == null) {
                if (_barBackShape == null){
                    _barBackShape = new Shape();
                    _barBackShape.graphics.beginFill(0, 0.4);
                    _barBackShape.graphics.drawRoundRect(0, 0, BAR_WIDTH, BAR_HEIGHT, (BAR_HEIGHT / 2), (BAR_HEIGHT / 2));
                    _barBackShape.graphics.endFill();
                    _barBackShape.y = -(BAR_HEIGHT);
                    addChild(_barBackShape);
                    _barBackShape.visible = _showBar;
                }
                if (_barShape == null){
                    _barShape = new Shape();
                    _barShape.graphics.beginFill(0xFF0000, 1);
                    _barShape.graphics.drawRoundRect(0, 0, BAR_WIDTH, BAR_HEIGHT, (BAR_HEIGHT / 2), (BAR_HEIGHT / 2));
                    _barShape.graphics.endFill();
                    _barShape.y = -(BAR_HEIGHT);
                    addChild(_barShape);
                    _barShape.visible = _showBar;
                }
                resize();
            }
            TweenLite.to(_barShape, 0.5, {scaleX:(_barNow / _barTotal)});
        }
		
        public function setHeadFaceTalkText(talkText:String="", talkTextColor:uint=0xFFFFFF, talkTimeDelay:int=8000):void
		{
            _talkText = talkText;
            _talkTextColor = talkTextColor;
            _talkTime = CCRender.nowTime;
            _talkTimeDelay = talkTimeDelay;
            drawTalk();
        }
		
		/**
		 * 说话时间检测, 过期则隐藏
		 */
        public function checkTalkTime():void
		{
            if (_talkText != "" && (CCRender.nowTime - _talkTime) > _talkTimeDelay) {
                setHeadFaceTalkText("");
            }
        }
		
        private function drawMain():void
		{
            var nickTF:TextField;
            var titleTF:TextField;
            var leftIconRect:Rectangle;
            var topIconRect:Rectangle;
            var containerRect:Rectangle;
            var matrix:Matrix;
            var container:Sprite = new Sprite();
            if (_showNickName && _nickName != "" && _nickName != null) {
                nickTF = new TextField();
                nickTF.autoSize = TextFormatAlign.CENTER;
                nickTF.multiline = true;
                nickTF.mouseEnabled = false;
                nickTF.defaultTextFormat = new TextFormat("宋体", 12, _nickNameColor, null, null, null, null, null, TextFormatAlign.CENTER);
                nickTF.width = 0;
                nickTF.x = 0;
                nickTF.filters = [new GlowFilter(0x300B00, 1, 3, 3, 15, BitmapFilterQuality.LOW)];
                nickTF.htmlText = _nickName;
            }
            if (_showCustomTitle && _customTitle != "") {
                titleTF = new TextField();
                titleTF.autoSize = TextFormatAlign.CENTER;
                titleTF.multiline = true;
                titleTF.mouseEnabled = false;
                titleTF.defaultTextFormat = new TextFormat("宋体", 12, 0xFFFF00, null, null, null, null, null, TextFormatAlign.CENTER, 0, 0, 0, 5);
                titleTF.width = 0;
                titleTF.x = 0;
                titleTF.filters = [new GlowFilter(0x300B00, 1, 3, 3, 15, BitmapFilterQuality.LOW)];
                titleTF.htmlText = _customTitle;
            }
            if (nickTF != null){
                container.addChild(nickTF);
            }
            if (titleTF != null){
                container.addChild(titleTF);
            }
            if (_showLeftIco && _leftIco != null) {
                container.addChild(_leftIco);
            }
            if (_showTopIco && _topIco != null) {
                container.addChild(_topIco);
            }
			if (_topMc != null) {
				this.addChild(_topMc);
			}
            var containerWidth:Number = 0;
            var containerHeight:Number = 0;
            if (nickTF != null && titleTF != null) {
                containerWidth = Math.max(nickTF.width, titleTF.width);
                containerHeight = (nickTF.height + titleTF.height);
            } else {
                if (nickTF != null) {
                    containerWidth = nickTF.width;
                    containerHeight = nickTF.height;
                } else {
                    if (titleTF != null) {
                        containerWidth = titleTF.width;
                        containerHeight = titleTF.height;
                    }
                }
            }
            if (nickTF != null) {
                nickTF.x = ((containerWidth - nickTF.width) / 2);
                nickTF.y = -(nickTF.height);
            }
            if (titleTF != null) {
                titleTF.x = ((containerWidth - titleTF.width) / 2);
                if (nickTF != null){
                    titleTF.y = (nickTF.y - titleTF.height);
                } else {
                    titleTF.y = -(titleTF.height);
                }
            }
            if (_showLeftIco && _leftIco != null) {
                leftIconRect = _leftIco.getBounds(_leftIco);
                _leftIco.x = ((-(leftIconRect.x) - leftIconRect.width) - 2);
                _leftIco.y = ((-(leftIconRect.y) - ((containerHeight - leftIconRect.height) / 2)) - leftIconRect.height);
            }
            if (_showTopIco && _topIco != null) {
                topIconRect = _topIco.getBounds(_topIco);
                _topIco.x = ((containerWidth - topIconRect.width) / 2);
                if (_showLeftIco && _leftIco != null && leftIconRect.height > containerHeight) {
                    _topIco.y = (((-(topIconRect.x) - ((leftIconRect.height / 2) + (containerHeight / 2))) - TOP_ICO_SPACE) - topIconRect.height);
                } else {
                    _topIco.y = (((-(topIconRect.y) - containerHeight) - TOP_ICO_SPACE) - topIconRect.height);
                }
             }
			if (_topMc != null) {
				topIconRect = _topMc.getBounds(_topMc);
				_topMc.x = ((containerWidth - topIconRect.width) / 2);
				if (_showLeftIco && _leftIco != null && leftIconRect.height > containerHeight) {
					_topMc.y = (((-(topIconRect.x) - ((leftIconRect.height / 2) + (containerHeight / 2))) - TOP_ICO_SPACE) - topIconRect.height);
				} else {
					_topMc.y = (((-(topIconRect.y) - containerHeight) - TOP_ICO_SPACE) - topIconRect.height);
				}
				if(_topIco && _topIco.visible)
					_topMc.y-=_topIco.height;
			}
            if (container.numChildren > 0) {
                if (_mainBitmap == null) {
                    _mainBitmap = new Bitmap();
                    addChild(_mainBitmap);
                }
                _mainBitmap.bitmapData = new BitmapData(container.width, container.height, true, 0);
                containerRect = container.getBounds(container);
                matrix = new Matrix();
                matrix.tx = -(containerRect.x);
                matrix.ty = -(containerRect.y);
                _mainBitmap.bitmapData.draw(container, matrix);
            } else {
                if (_mainBitmap) {
                    _mainBitmap.bitmapData.dispose();
                    if (_mainBitmap.parent) {
                        _mainBitmap.parent.removeChild(_mainBitmap);
                    }
                    _mainBitmap = null;
                }
            }
            resize();
        }
		
        private function drawTalk():void
		{
            var _tf:TextField;
            var rect:Rectangle;
            var matrix:Matrix;
            var sp:Sprite = new Sprite();
            if (_showTalkText && _talkText != "") {
                _tf = new TextField();
                _tf.autoSize = TextFormatAlign.LEFT;
                _tf.multiline = true;
                _tf.mouseEnabled = false;
                _tf.defaultTextFormat = new TextFormat("宋体", 12, _talkTextColor, null, null, null, null, null, TextFormatAlign.CENTER);
                _tf.width = 0;
                _tf.x = 0;
                _tf.filters = [new GlowFilter(0x300B00, 1, 3, 3, 15, BitmapFilterQuality.LOW)];
                _tf.text = _talkText;
            }
            if (_tf != null) {
                sp.addChild(_tf);
                sp.graphics.beginFill(0, 0.3);
                sp.graphics.drawRect(-2, -2, (sp.width + 4), (sp.height + 4));
                sp.graphics.endFill();
            }
            if (sp.numChildren > 0) {
                if (_talkBitmap == null){
                    _talkBitmap = new Bitmap();
                    addChild(_talkBitmap);
                }
                _talkBitmap.bitmapData = new BitmapData(sp.width, sp.height, true, 0);
                rect = sp.getBounds(sp);
                matrix = new Matrix();
                matrix.tx = -(rect.x);
                matrix.ty = -(rect.y);
                _talkBitmap.bitmapData.draw(sp, matrix);
            } else {
                if (_talkBitmap){
                    _talkBitmap.bitmapData.dispose();
                    if (_talkBitmap.parent){
                        _talkBitmap.parent.removeChild(_talkBitmap);
                    }
                    _talkBitmap = null;
                }
            }
            resize();
        }
		
		public function get mainBitmap():Bitmap
		{
			return _mainBitmap;
		}
		
        private function resize():void
		{
            var _local4:Number;
            var _local5:Number;
            var _local1:Boolean;
            var _local2:Boolean;
            var _local3:Boolean;
            if (_showBar && _barBackShape != null && _barShape != null) {
                _local1 = true;
                _barBackShape.x = (_barShape.x = (-(BAR_WIDTH) / 2));
                _barBackShape.y = (_barShape.y = -(BAR_HEIGHT));
            }
            if (_mainBitmap != null) {
                _local2 = true;
                if (_showTopIco && _topIco != null && _topIco.width == _mainBitmap.width) {
                    _mainBitmap.x = (-(_mainBitmap.width) / 2);
                } else {
                    _local4 = _showLeftIco && _leftIco != null ? (_leftIco.width + LEFT_ICO_SPACE) : 0;
                    _local5 = (_mainBitmap.width - _local4);
                    _mainBitmap.x = (-(_local4) - (_local5 / 2));
                }
                if (_showBar&& _barBackShape != null && _barShape != null) {
                    _mainBitmap.y = ((-(BAR_HEIGHT) - BOTTOM_BAR_SPACE) - _mainBitmap.height);
                } else {
                    _mainBitmap.y = -(_mainBitmap.height);
                }
            }
            if (_talkBitmap != null) {
                _local3 = true;
                _talkBitmap.x = (-(_talkBitmap.width) / 2);
                if (_local2) {
                    _talkBitmap.y = ((_mainBitmap.y - BOTTOM_BAR_SPACE) - _talkBitmap.height);
                } else {
                    if (_local1) {
                        _talkBitmap.y = ((_barBackShape.y - BOTTOM_BAR_SPACE) - _talkBitmap.height);
                    } else {
                        _talkBitmap.y = -(_talkBitmap.height);
                    }
                }
            }
        }
    }
}