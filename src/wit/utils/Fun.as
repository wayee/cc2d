package wit.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.LocalConnection;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	
	import wit.manager.DelegateManager;
	import wit.handler.HandlerThread;
	import wit.log.Log4J;
	import wit.manager.HandlerManager;
	import wit.timer.TimerHelper;

	/**
	 * 工具集合
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class Fun
	{
		/**
		 * 释放节点 disp的所有孩子或位图资源
		 * @param disp 目标节点, 可以是 doc, 或 bitmap
		 * @param disposeBitmap 是否释放位图
		 * @param recursive 是否递归
		 */
        public static function clearChildren(disp:DisplayObject, disposeBitmap:Boolean=false, recursive:Boolean=true):void
		{
            var num:int;
            if (disp == null) {
                return;
            }
            if (disp is DisplayObjectContainer) {
                num = (disp as DisplayObjectContainer).numChildren;
                while (num-- > 0) {
                    if (recursive){		// 递归调用
                        clearChildren((disp as DisplayObjectContainer).getChildAt(num), disposeBitmap, recursive);
                    }
                    if (!(disp is Loader)){ // 删除孩子
                        (disp as DisplayObjectContainer).removeChildAt(num);
                    }
                }
            } else { // 释放位图
                if (disposeBitmap && (disp is Bitmap) && (disp as Bitmap).bitmapData) {
                    (disp as Bitmap).bitmapData.dispose();
                }
            }
        }
		
		/**
		 * 删除对象 parentDisp[ childDisp ]
		 * @param disposeBitmap 是否释放位图
		 * @param recursive 是否递归
		 */
        public static function clearChildrenByName(parentDisp:DisplayObject, childDisp:String, disposeBitmap:Boolean=false, recursive:Boolean=true):void
		{
            if (!parentDisp){
                return;
            }
            var container:DisplayObjectContainer = (parentDisp as DisplayObjectContainer);
            var child:DisplayObject = container.getChildByName(childDisp);
            if (child != null) {
                container.removeChild(child);
                clearChildren(child, disposeBitmap, recursive);
            }
        }
		
		/**
		 * childDisp父亲是否parentDisp 
		 * @param parentDisp
		 * @param childDisp
		 * @return bool
		 * 
		 */
        public static function isParentChild(parentDisp:DisplayObjectContainer, childDisp:DisplayObject):Boolean
		{
            if (childDisp == null || parentDisp == null || childDisp.parent == null) {
                return false;
            }
            if (childDisp.parent == parentDisp) {
                return true;
            }
            return isParentChild(parentDisp, childDisp.parent);
        }
		
		/**
		 * 显示对象是否可见 
		 * @param disp
		 * @return bool
		 */
        public static function isVisible(disp:DisplayObject):Boolean
		{
            if (disp == null || disp.visible == false) {
                return false;
            }
            if (disp is Stage) {
                return true;
            }
			
            return isVisible(disp.parent);
        }
		
		/**
		 * 强制执行一次垃圾回收 
		 * 手动产生异常，使用Flash Player执行回收
		 */
        public static function doGC():void
		{
            try {
                new LocalConnection().connect("foo");
                new LocalConnection().connect("foo");
            } catch (error:Error) {
				Log4J.Info("Forcing Garbage Collection" /*+ error.toString()*/);
            }
        }
		
		/**
		 * 绘制图像副本
		 */
		public static function getCopy(target:DisplayObject, rect:Rectangle=null):Bitmap
		{
			if (rect == null) {
				rect = new Rectangle(0, 0, target.width, target.height);
			}
			var srcBmd:BitmapData = null;
			if (target is Bitmap) {
				srcBmd = (target as Bitmap).bitmapData.clone();
			} else {
				srcBmd = new BitmapData(rect.width, rect.height, true, 0x00FFFFFF);
				srcBmd.draw(target);
			}
			var copy:Bitmap = new Bitmap(srcBmd);
			
			return copy;
		}
		
		/**
		 * 播放影片并执行回调
		 *  
		 * @param mc 需要播放的影片
		 * @param onPlayFinish 回调函数，需要提供2个参数 onPlayFinish(mc, object)
		 * @param playFrame 需要从哪一帧开始播放
		 * @param endFrame 需要在哪一帧结束播放
		 */
		public static function playMovie(mc:MovieClip, onPlayFinish:Function=null, playFrame:String='', endFrame:String='',date:Object = null):void
		{
			_playMovie(mc, onPlayFinish, playFrame, endFrame,false,date);
		}
		
		/**
		 * 播放一次然后清除并执行回调
		 *  
		 * @param mc 需要播放的影片
		 * @param onPlayFinish 回调函数，需要提供2个参数 onPlayFinish(mc, object)
		 * @param playFrame 需要从哪一帧开始播放
		 * @param endFrame 需要在哪一帧结束播放
		 */
		public static function playMovieOnce(mc:MovieClip, onPlayFinish:Function=null, playFrame:String='', endFrame:String='', removeMc:Boolean=true):void
		{
			_playMovie(mc, onPlayFinish, playFrame, endFrame, removeMc);
		}
		
		private static function _playMovie(mc:MovieClip, onPlayFinish:Function=null, playFrame:String='', endFrame:String='', removeMc:Boolean=false,date:Object = null):void
		{
			if (mc != null && mc is MovieClip) {
				if (playFrame != '') {
					mc.gotoAndPlay(playFrame);
				} else {
					mc.gotoAndPlay(mc.currentFrame+1);
				}
				mc.addEventListener(Event.ENTER_FRAME, DelegateManager.createListener(onEnterFrame, mc, onPlayFinish,date), false, 0, true);
				
				function onEnterFrame(event:Event, mc:MovieClip, onPlayFinish:Function=null,date:Object = null):void
				{
					var b:Boolean = false;
					if (endFrame != '') {
						b = mc.currentFrameLabel == endFrame;
					} else {
						b = mc.totalFrames == mc.currentFrame;
					}
					if (b) {
						mc.removeEventListener(Event.ENTER_FRAME, DelegateManager.getFunction(onEnterFrame));
						mc.stop();
						
						if (removeMc) { // 自动删除
							if (mc && mc.parent) mc.parent.removeChild(mc);
						}
						if (onPlayFinish != null) onPlayFinish(mc, date);
						onPlayFinish = null;
					}
				};
			}
		}
		
		/**
		 * 测试影片是否已经播放到某帧 并执行回调
		 * 
		 * @param mc 影片
		 * @param onPlayFinish 回调函数，需要提供2个参数 onPlayFinish(mc, object)
		 * @param targetFrame 目标帧
		 * @param stopMovie 是否主动停止播放
		 */
		public static function testPlayToFrame(mc:MovieClip, onPlayFinish:Function, targetFrame:String, stopMovie:Boolean=false):void
		{
			if (mc != null && mc is MovieClip) {
				
				mc.addEventListener(Event.ENTER_FRAME, DelegateManager.createListener(onEnterFrame, mc, onPlayFinish), false, 0, true);
				
				function onEnterFrame(event:Event, mc:MovieClip, onPlayFinish:Function=null):void
				{
					if (mc.currentFrameLabel == targetFrame) {
						mc.removeEventListener(Event.ENTER_FRAME, DelegateManager.getFunction(onEnterFrame));
						
						if (stopMovie) mc.stop();
						
						if (onPlayFinish != null) onPlayFinish(mc, {'status':targetFrame});
						onPlayFinish = null;
					}
				};
			}
		}
		
		/**
		 * 全屏切换 
		 * @param stage 舞台
		 */
		public static function toggleFullScreen(stage:Stage=null):void
		{
			if (stage == null) {
				return;
			}
			switch(stage.displayState) {
				case "normal":
					stage.displayState = "fullScreen";    
					break;
				case "fullScreen":
				default:
					stage.displayState = "normal";    
					break;
			}
		}
		
		/**
		 * 批量设置属性 
		 * @param elements Vector 显示对象列表
		 * @param property 属性名称
		 * @param value 属性值
		 */
		public static function setProperties(elements:Vector.<DisplayObject>, property:String, value:Object):void
		{
			var len:int = elements.length;
			
			for (var i:int=0; i<len; i++) {
				setPropery(elements[i], property, value);
			}
		}
		
		/**
		 * 单个对象设置属性 
		 * @param element 显示对象
		 * @param property 属性名称
		 * @param value 属性值
		 */
		public static function setPropery(element:DisplayObject, property:String, value:Object):void
		{
			if (element && property && element.hasOwnProperty(property)) {
				element[property] = value; 
			}
		}
		
		/**
		 * 频率控制
		 * 	功能:
		 * 		防止某个操作过于频繁, 如刷新, 防止玩家快速连续点击刷新按钮. 因此, 需要控制该操作的使用频率
		 * 
		 * 	使用方法:
		 * 		在操作前, 调用 FrequencyControl.check(opid:Object) 来判断是否可以操作
		 * 		调用 reset(opid) 清空上次时间记录
		 * 
		 * @param opid		表示操作的唯一id
		 * @param interval	间隔时间(毫秒), 必须 >= 0, 否则使用默认值
		 * @param setTime	更新 上次操作时间 为 当前的时间
		 * @return			返回是否允许运行, 如果为false, 则表示操作太频繁了
		 */
		private static var _frequencyDict:Dictionary = new Dictionary;		// 每个 opid 对应的上次操作时间
		public static function checkFrequency(op:Object, interval:int=-1, setTime:Boolean=true):Boolean
		{
			if ( interval < 0 ) interval = 1000;			// 默认操作间隔(毫秒)
			
			var prev:int = int( _frequencyDict[op] );
			var cur:int = getTimer();
			if ((cur - prev) < interval) return false;		// 禁止频繁操作
			
			if (setTime) _frequencyDict[op] = cur;
			return true;
		}
		
		/**
		 * 清空频率控制时间， 如果未指定 op, 则清空全部
		 * @param op 操作标识
		 */
		public static function clearFrequencyDict(op:Object=null):void
		{
			if (op == null) {
				for (var op:Object in _frequencyDict) {
					_frequencyDict[op] = null;
					delete _frequencyDict[op];
				}
			} else {
				_frequencyDict[op] = null;
				delete _frequencyDict[op];
			}
		}
		
		/**
		 * 水平翻转
		 * @param dsp
		 * 
		 */
		public static function flipH(disp:DisplayObject):void
		{
			var mc:Matrix = disp.transform.matrix;
			mc.a = -1;
			mc.tx = disp.width + disp.x;
			disp.transform.matrix = mc;
		}
		
		/**
		 * 垂直翻转
		 * @param dsp
		 * 
		 */
		public static function flipV(disp:DisplayObject):void
		{
			var mc:Matrix = disp.transform.matrix;
			mc.d = -1;
			mc.ty = disp.height + disp.y;
			disp.transform.matrix = mc;
		}
		
		/**
		 * 向右旋转90度
		 * @param bmpData
		 * @return 
		 * 
		 */
		public static function rotateRight(bmpData:BitmapData):BitmapData
		{
			var mc:Matrix = new Matrix();
			mc.rotate(Math.PI/2);
			mc.translate(bmpData.height,0);
			var bmpData:BitmapData = new BitmapData(bmpData.height, bmpData.width,true,0);
			bmpData.draw(bmpData,mc);
			return bmpData;
		}
		
		/**
		 * 向左旋转90度
		 * @param bmpData
		 * @return 
		 * 
		 */
		public static function rotateLeft(bmpData:BitmapData):BitmapData
		{
			var mc:Matrix = new Matrix();
			mc.rotate(-Math.PI/2);
			mc.translate(0,bmpData.width);
			var bmpData:BitmapData = new BitmapData(bmpData.height, bmpData.width,true,0);
			bmpData.draw(bmpData,mc);
			return bmpData;
		}
		
		/**
		 * 设置行间距 
		 * @param str 文本
		 * @param size 行间距大小
		 * @return 设置行间距后的html文本
		 * 
		 */
		public static function htmlLeading(str:String, size:int):String
		{
			str = '<textformat leading="'+size+'">' + str + '</textformat>';
			return str;
		}
		
		/**
		 * 设置字间距 
		 * @param str 文本
		 * @param size 字间距大小
		 * @return 设置字间距后的html文本
		 * 
		 */
		public static function htmlLetterspacing(str:String, size:int):String
		{
			str = '<font letterspacing="'+size+'">' + str + '</font>';
			return str;
		}
		
		private static var isShake:Boolean = false;  
		public static function shakeDisplayObject(dis:DisplayObject, times:uint = 2, offset:uint = 4, speed:uint = 32):void
		{  
			if (isShake) {  
				return;  
			}  
			isShake = true;  
			var point:Point = new Point(dis.x, dis.y); 
			var offsetXYArray:Array = [0,0];  
			var num:int = 0;  
			var u:int = setInterval(function():void {  
				offsetXYArray[num%2] = (num++)%4 < 2 ? 0 : offset;  
				if(num > (times*4 + 1)){  
					clearInterval(u);  
					num = 0;  
					isShake = false;  
				}  
				dis.x = offsetXYArray[0]/2 + point.x;  
				dis.y = offsetXYArray[1] + point.y;  
			}, speed);  
		} 
		
		/**
		 * 打字机动画 
		 * 
		 * @param text 文本内容
		 * @param tf TextField对象
		 * @param delay 每个字符出现的时间间隔
		 * 
		 */
		private static var writerHandler:HandlerThread = new HandlerThread;
		public static function playWriter(text:String, tf:TextField, delay:uint=50):void
		{
			var str:String = text;
			var len:int = text.length;
			var index:int = 0;
			
			var appendText:Function = function():void
			{
				tf.appendText(str.charAt(index));
				index = index + 1; 
				
				if (index < len) {
					HandlerManager.push(appendText, null, delay, true, true, writerHandler);
				}
			};
			
			HandlerManager.push(appendText, null, delay, true, true, writerHandler);
		}
		public static function stopPlayWriter(text:String, tf:TextField):void
		{
			HandlerManager.removeHandlerThread(writerHandler);
			if (text && tf) {
				tf.text = text;
			}
		}
		
		private static var _coolDownList:HashMap;
		/**
		 * 冷却 
		 * @param name 操作名称
		 * @param delay 毫秒
		 * @return bool
		 * 
		 */
		public static function coolDown(name:String, delay:int=200):Boolean
		{
			if (_coolDownList == null) _coolDownList = new HashMap;
			// 是否可以请求
			if (_coolDownList.containsKey(name)) {
				var oldTime:Number = _coolDownList.get(name);
				var now:Number = TimerHelper.getMilliSecTime();
				
				if ((now-oldTime) < delay) {
					trace("now:"+now+" oldTime:"+oldTime, " interval:", now-oldTime, " delay:"+delay);
					return false;
				}
			}
			_coolDownList.put(name, TimerHelper.getMilliSecTime());
			return true;
		}
		
		public static function get isBrower():Boolean
		{
			return ExternalInterface.available;
		}
    }
}