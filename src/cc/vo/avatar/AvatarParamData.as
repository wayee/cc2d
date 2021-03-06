﻿package cc.vo.avatar
{
	import cc.CCCharacter;
	import cc.define.AvatarPartID;
	import cc.define.AvatarPartType;
	import cc.graphics.avatar.CCAvatarPart;
	
	import wit.handler.HandlerThread;

    public class AvatarParamData
	{
        private var id:String;							// ID, AvatarPartID, AvatarPartID.xxx
		
        public var sourcePath:String;					// 保存该资源的 URL 源路径
        public var avatarPartType:String;				// 角色部件类型 see AvatarPartID.xxx
        public var depth:int = 0;						// 深度, AvatarPartType.getDefaultDepth
        public var status:String = "stand";
        public var angle:int = -1;
        public var rotation:int = -1;
        public var clearSameType:Boolean = false;		// 唯一，清空其它相同类型
        public var useType:int = 0;						// 1:setBornAvatarParamData, 2:setBornMountAvatarParamData|setBornOnMountAvatarParamData
		
		// new properties
		public var offsetX:Number = 0;
		public var offsetY:Number = 0;
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;
		public var playCallBack:AvatarPlayCallBack = null;

        public function AvatarParamData(path:String="", partType:String="body", 
										_depth:int=0, useType:int=0) {
            avatarPartType = AvatarPartType.BODY;
            sourcePath = path;
            avatarPartType = partType;
            depth = _depth;
            useType = useType;
            depth = (depth != 0) ? depth : AvatarPartType.GetDefaultDepth(avatarPartType);
        }
		
		/**
		 * 必须非空, 且非  AvatarPartID 中枚举的内容
		 */
        public function get Id():String {
            return id;
        }
		
        public function set Id(p_id:String):void {
            if ( !AvatarPartID.IsValidID(p_id) ) {
                throw new Error("换装ID非法（原因：该ID为引擎换装ID关键字）");
            }
            id = p_id;
        }
		
		/**
		 * 设置 ID, 不检测有效性
		 */
        public function set Id_noCheckValid(p_id:String):void {
            id = p_id;
        }
		
		/**
		 * 从源代码中获取文件名部分, 作为类名
		 */
        public function get className():String {
            if (sourcePath != null && sourcePath != "") {
                return sourcePath.replace(/^(.*\/)*([a-zA-Z_\d]+)\..+$/, "$2");
            }
            return "";
        }
		
		/**
		 * 扩展  callback 函数
		 * 
		 * @param new_onPlayBeforeStart 播放开始之前
		 * @param new_onPlayStart 播放开始
		 * @param new_onPlayUpdate 播放循环
		 * @param new_onPlayComplete 播放结束
		 * @param new_onAdd 添加
		 * @param new_onRemove 删除
		 * @param clearOld 清除旧的
		 * 
		 */
        public function extendCallBack(new_onPlayBeforeStart:Function=null, new_onPlayStart:Function=null, 
									   new_onPlayUpdate:Function=null, new_onPlayComplete:Function=null, 
									   new_onAdd:Function=null, new_onRemove:Function=null, 
									   clearOld:Boolean=false):void {
            var onPlayBeforeStart_old:Function = null;
            var onPlayStart_old:Function = null;
            var onPlayUpdate_old:Function = null;
            var onPlayComplete_old:Function = null;
            var onAdd_old:Function = null;
            var onRemove_old:Function = null;
            playCallBack = playCallBack || new AvatarPlayCallBack;
			
			// 清除老函数, 直接添加
            if (clearOld) {
                playCallBack.onPlayBeforeStart = new_onPlayBeforeStart;
                playCallBack.onPlayStart = new_onPlayStart;
                playCallBack.onPlayUpdate = new_onPlayUpdate;
                playCallBack.onPlayComplete = new_onPlayComplete;
                playCallBack.onAdd = new_onAdd;
                playCallBack.onRemove = new_onRemove;
            } else {
				// 添加  new_onPlayBeforeStart
                if (new_onPlayBeforeStart != null) {
                    if (playCallBack.onPlayBeforeStart == null) {
                        playCallBack.onPlayBeforeStart = new_onPlayBeforeStart;
                    } else {
                        onPlayBeforeStart_old = playCallBack.onPlayBeforeStart;
                        playCallBack.onPlayBeforeStart = function(sceneChar:CCCharacter=null, part:CCAvatarPart=null):void {
                            onPlayBeforeStart_old(sceneChar, part);		// 合并2个，这样不会造成闭包容量太大？
                            new_onPlayBeforeStart(sceneChar, part);
                        };
                    }
                }
                if (new_onPlayStart != null) {
                    if (playCallBack.onPlayStart == null) {
                        playCallBack.onPlayStart = new_onPlayStart;
                    } else {
                        onPlayStart_old = playCallBack.onPlayStart;
                        playCallBack.onPlayStart = function (sceneChar:CCCharacter=null, part:CCAvatarPart=null):void{
                            onPlayStart_old(sceneChar, part);
                            new_onPlayStart(sceneChar, part);
                        }
                    }
                }
                if (new_onPlayUpdate != null) {
                    if (playCallBack.onPlayUpdate == null) {
                        playCallBack.onPlayUpdate = new_onPlayUpdate;
                    } else {
                        onPlayUpdate_old = playCallBack.onPlayUpdate;
                        playCallBack.onPlayUpdate = function (sceneChar:CCCharacter=null, part:CCAvatarPart=null):void{
                            onPlayUpdate_old(sceneChar, part);
                            new_onPlayUpdate(sceneChar, part);
                        }
                    }
                }
                if (new_onPlayComplete != null) {
                    if (playCallBack.onPlayComplete == null) {
                        playCallBack.onPlayComplete = new_onPlayComplete;
                    } else {
                        onPlayComplete_old = playCallBack.onPlayComplete;
                        playCallBack.onPlayComplete = function (sceneChar:CCCharacter=null, part:CCAvatarPart=null):void{
                            onPlayComplete_old(sceneChar, part);
                            new_onPlayComplete(sceneChar, part);
                        }
                    }
                }
                if (new_onAdd != null) {
                    if (playCallBack.onAdd == null) {
                        playCallBack.onAdd = new_onAdd;
                    } else {
                        onAdd_old = playCallBack.onAdd;
                        playCallBack.onAdd = function (sceneChar:CCCharacter=null, part:CCAvatarPart=null):void{
                            onAdd_old(sceneChar, part);
                            new_onAdd(sceneChar, part);
                        }
                    }
                }
                if (new_onRemove != null) {
                    if (playCallBack.onRemove == null) {
                        playCallBack.onRemove = new_onRemove;
                    } else {
                        onRemove_old = playCallBack.onRemove;
                        playCallBack.onRemove = function (sceneChar:CCCharacter=null, part:CCAvatarPart=null):void{
                            onRemove_old(sceneChar, part);
                            new_onRemove(sceneChar, part);
                        }
                    }
                }
            }
        }
		
		/**
		 * 执行线程
		 * @param sceneChar, part 线程参数
		 * @param (execPlayBeforeStart - execOnRemove) 标志
		 * @param (delayOnPlayBeforeStart - delayOnRemove) 延时
		 */
        public function executeCallBack(sceneChar:CCCharacter=null, part:CCAvatarPart=null, 
										execPlayBeforeStart:Boolean=true, execPlayStart:Boolean=true, 
										execPlayUpdate:Boolean=true, execPlayComplete:Boolean=true, 
										execOnAdd:Boolean=true, execOnRemove:Boolean=true, 
										delayOnPlayBeforeStart:int=0, delayOnPlayStart:int=0, delayOnPlayUpdate:int=0, 
										delayPlayComplete:int=0, delayOnAdd:int=0, delayOnRemove:int=0):void {
            if (playCallBack == null) {
                return;
            }
            var handler:HandlerThread = new HandlerThread();
            if (execPlayBeforeStart && playCallBack.onPlayBeforeStart != null) {
                handler.push(playCallBack.onPlayBeforeStart, [sceneChar, part], delayOnPlayBeforeStart);
            }
            if (execPlayStart && playCallBack.onPlayStart != null) {
                handler.push(playCallBack.onPlayStart, [sceneChar, part], delayOnPlayStart);
            }
            if (execPlayUpdate && playCallBack.onPlayUpdate != null) {
                handler.push(playCallBack.onPlayUpdate, [sceneChar, part], delayOnPlayUpdate);
            }
            if (execPlayComplete && playCallBack.onPlayComplete != null) {
                handler.push(playCallBack.onPlayComplete, [sceneChar, part], delayPlayComplete);
            }
            if (execOnAdd && playCallBack.onAdd != null) {
                handler.push(playCallBack.onAdd, [sceneChar, part], delayOnAdd);
            }
            if (execOnRemove && playCallBack.onRemove != null) {
                handler.push(playCallBack.onRemove, [sceneChar, part], delayOnRemove);
            }
        }
		
        public function clone():AvatarParamData {
            var data:AvatarParamData = new AvatarParamData(sourcePath, avatarPartType, depth, useType);
            data.Id_noCheckValid = Id;
            data.status = status;
            data.angle = angle;
            data.rotation = rotation;
            data.clearSameType = clearSameType;
			data.offsetX = offsetX;
			data.offsetY = offsetY;
			data.scaleX = scaleX;
			data.scaleY = scaleY;
            if (playCallBack != null) {
				data.playCallBack = this.playCallBack.clone();
            }
            return data;
        }
    }
}