package cc.graphics.avatar
{
	import cc.CCRender;
	import cc.define.AvatarPartType;
	import cc.define.CharStatusType;
	import cc.define.CharType;
	import cc.graphics.layers.SceneAvatarLayer;
	import cc.tools.SceneCache;
	import cc.tools.ScenePool;
	import cc.vo.avatar.AvatarImgData;
	import cc.vo.avatar.AvatarParamData;
	import cc.vo.avatar.AvatarPartStatus;
	import cc.vo.avatar.AvatarPlayCondition;
	
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import wit.draw.Bounds;
	import wit.pool.IPoolObject;
	import wit.utils.ZMath;

	/**
	 * 角色的部件
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class CCAvatarPart implements IPoolObject
	{
		private static const MOUSE_ON_GLOWFILTER:GlowFilter = new GlowFilter(0xFFFFFF, 0.7, 7, 7, 4, 1);
		private static const MOUSE_ON_GLOWFILTER_BY_RELIGION_NPC:GlowFilter = new GlowFilter(0x55e9ff , 0.7, 10, 10, 4, 1);
		
		public var usable:Boolean = false;
		public var avatarParamData:AvatarParamData;			// 原始数据, MODEL
		public var needRender:Boolean = false;
		public var cutRect:Rectangle = null;
		public var renderRectArr:Array = null;				// 重绘区
		public var id:String;
		public var avatar:CCAvatar;
		public var type:String;
		public var depth:int = 0;
		public var visible:Boolean = true;
		public var useType:int = 0;
		public var isBlank:Boolean = false;
		
		private var _oldData:Object = null;
		private var _sourcePoint:Point = null;
		private var _classNamePrefix:String;
		private var _avatarPartStatusRes:Object = null;
		
		// 回调函数
		private var _onPlayBeforeStart:Function;
		private var _onPlayStart:Function;
		private var _onPlayUpdate:Function;
		private var _onPlayComplete:Function;
		private var _onAdd:Function;
		private var _onRemove:Function;
		
		private var _sourceBitmapDataObj:AvatarImgData;
		private var _drawSourceBitmapData:BitmapData;
		private var _inMaskDrawSourceBitmapData:BitmapData;
		private var _currentStatus:String = "";
		private var _currentAvatarPartStatus:AvatarPartStatus;
		private var _currentFrame:int = -1;
		private var _currentLogicAngle:int = 0;
		private var _currentRotation:Number = 0;
		private var _lastTime:int = 0;
		private var _playCount:int = 0;
		private var _playBeforeStart:Boolean = false;
		private var _playStart:Boolean = false;
		private var _playComplete:Boolean = false;
		private var _playCondition:AvatarPlayCondition;
		private var _only1Frame:Boolean = false;
		private var _only1LogicAngle:Boolean = false;
		private var _autoRecycle:Boolean = false;
		private var _autoToStand:Boolean = false;
		private var _drawMouseOn:Boolean = true;
		private var _callBackAttack:Boolean = false;
		private var _enablePlay:Boolean = false;
		
		public function CCAvatarPart(partID:String, avatarPartType:String, depth:int=0, useType:int=0, avatarParamDataRes:Object=null, vars:Object=null)
		{
			reset([partID, avatarPartType, depth, useType, avatarParamDataRes, vars]);
		}
		
		/**
		 * 创建角色部件 
		 * @param partID
		 * @param avatarPartType
		 * @param depth
		 * @param useType
		 * @param avatarParamDataRes
		 * @param vars
		 * @return AvatarPart
		 * 
		 */
		// avatarParamData.id, avatarParamData.avatarPartType, avatarParamData.depth, avatarParamData.useType, avatarParamDataRes, avatarParamData.vars
		public static function createAvatarPart(partID:String, avatarPartType:String, depth:int=0, useType:int=0, avatarParamDataRes:Object=null, vars:Object=null):CCAvatarPart
		{
			return ScenePool.avatarPartPool.createObj(CCAvatarPart, partID, avatarPartType, depth, useType, avatarParamDataRes, vars) as CCAvatarPart;
		}
		
		/**
		 * 回收角色部件 
		 * @param part
		 * 
		 */
		public static function recycleAvatarPart(part:CCAvatarPart):void
		{
			ScenePool.avatarPartPool.disposeObj(part);
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
		
		/**
		 * 设置播放动作
		 */
		public function playTo(status:String=null, logicAngle:int=-1, rotation:int=-1, 
							   playCondition:AvatarPlayCondition=null):void
		{
			var resName:String;
			if (!avatar || !avatar.sceneCharacter) {
				return;
			}
			var change:Boolean;
			
			var tmpCurrentStatus:String = this._currentStatus;
			var tmpCurrentLogicAngel:int = this._currentLogicAngle;
			var tmpCurrentRotation:Number = this._currentRotation;
			var tmpClassNamePrefix:String = this._classNamePrefix;
			
			_only1Frame = false;			// 只有1帧
			_autoRecycle = false;
			_autoToStand = false;
			_drawMouseOn = true;
			_callBackAttack = false;
			_only1LogicAngle = false;
			
			// 设置 状态, 方向, 选装, 播放条件
			if (status != null && status != this._currentStatus) {
				this._currentStatus = status;
			}
			if (logicAngle != -1 && logicAngle != this._currentLogicAngle) {
				this._currentLogicAngle = logicAngle;
			}
			if (rotation != -1 && rotation != this._currentRotation) {
				this._currentRotation = rotation;
			}
			if (playCondition != null) {
				_playCondition = playCondition;
			} else {
				if (_playCondition == null) {
					_playCondition = new AvatarPlayCondition();
				}
			}
			
			// 如果是空白
			if (isBlank) {
				this._currentStatus = CharStatusType.STAND;
				this._currentLogicAngle = 0;
				this._only1LogicAngle = true;
			}
			
			// 如果是传送点
			if (avatar.sceneCharacter.type == CharType.TRANSPORT) {
				this._currentStatus = CharStatusType.STAND;
				this._currentLogicAngle = 0;
				this._only1LogicAngle = true;
			}
			
			// 如果是建筑
//			if (avatar.sceneCharacter.type == CharType.BUILDING) {
//				this._currentStatus = CharStatusType.STAND;
//				this._currentLogicAngle = 0;
//				this._only1LogicAngle = true;
//			}
			
			// 如果是法术
			if (type == AvatarPartType.MAGIC || type == AvatarPartType.MAGIC_PASS) {
				this._currentStatus = CharStatusType.STAND;
				this._currentLogicAngle = 0;
				this._only1LogicAngle = true;
			}
			
			// 如果是躯体, 战斗, 则需要回调战斗
			if (type == AvatarPartType.BODY && this._currentStatus == CharStatusType.ATTACK
			&& _currentStatus == CharStatusType.MAGIC_ATTACK) {
				_callBackAttack = true;
			}
			
			// 如果是死亡
			if (this._currentStatus == CharStatusType.DEATH) {
				this._currentLogicAngle = 0;
				this._only1LogicAngle = true;
			}
			
			// 如果是法术通道
			if (type == AvatarPartType.MAGIC_PASS) {
				_only1Frame = true;
			}
			
			// 如果是魔法/魔法通道
			if (type == AvatarPartType.MAGIC || type == AvatarPartType.MAGIC_PASS) {
				_autoRecycle = true;
				_drawMouseOn = false;
			}
			
			// 如果是躯体
			if (type == AvatarPartType.BODY) {
				_autoToStand = true;
			}
			
			// 如果资源xml中只定义了一个角度
			if (_avatarPartStatusRes != null && _avatarPartStatusRes[this._currentStatus] != null) {
				this._currentAvatarPartStatus = _avatarPartStatusRes[this._currentStatus];
				if (_currentAvatarPartStatus.only1Angle == 1) {
					_only1LogicAngle = true;
				}
			}
			
			// 属于该类型/状态, 则  playAtBegin=true
			var partTypePlayAtBegin:Array = [AvatarPartType.BODY, AvatarPartType.WEAPON];
			var statusTypePlayAtBegin:Array = [CharStatusType.ATTACK, CharStatusType.MAGIC_ATTACK, CharStatusType.INJURED, CharStatusType.DEATH];
			
			// 属于该类型/状态, 则  stayAtEnd=true
			var partTypeStayAtEnd:Array = [AvatarPartType.BODY, AvatarPartType.WEAPON];
			var statusTypeStayAtEnd:Array = [CharStatusType.DEATH];
			
			// 属于该类型/状态, 则  showEnd=true
			var partTypeShowEnd:Array = [AvatarPartType.BODY, AvatarPartType.WEAPON];
			var statusTypeShowEnd:Array = [CharStatusType.DEATH];
			
			// 如果自己属于  partTypePlayAtBegin/statusTypePlayAtBegin 中的类型和状态
			_playCondition.PlayAtBegin = 
					_playCondition.PlayAtBegin && partTypePlayAtBegin.indexOf(type) != -1	// 自己属于 partTypePlayAtBegin 中类型
					&& statusTypePlayAtBegin.indexOf(this._currentStatus) != -1	// _自己属于 statusTypePlayAtBegin 中的状态
					? true : false;
			
			_playCondition.StayAtEnd = 
					_playCondition.StayAtEnd && partTypeStayAtEnd.indexOf(type) != -1 
					&& statusTypeStayAtEnd.indexOf(this._currentStatus) != -1
					? true : false;
			
			_playCondition.ShowEnd = 
					_playCondition.ShowEnd && partTypeShowEnd.indexOf(type) != -1
					&& statusTypeShowEnd.indexOf(this._currentStatus) != -1 
					? true : false;
			
			// 如果状态变更
			if (tmpCurrentStatus != this._currentStatus) {
				if (_avatarPartStatusRes != null && _avatarPartStatusRes[this._currentStatus] != null) {
					this._currentAvatarPartStatus = _avatarPartStatusRes[this._currentStatus];
					this._classNamePrefix = this._currentAvatarPartStatus.classNamePrefix;
					
					change = true;
				}
			}
			
			// 如果角度变更
			if (tmpCurrentLogicAngel != this._currentLogicAngle) {
				change = true;
			}
			
			// 如果旋转了
			if (tmpCurrentRotation != this._currentRotation) {
				change = true;
			}
			
			if (change) {
				if (tmpCurrentStatus != this._currentStatus) {
					
					// 当前部件是否存在当前状态，例如角色特效没有走路的效果
					if (tmpCurrentStatus != null && tmpCurrentStatus != "") {
						resName = (tmpClassNamePrefix + tmpCurrentStatus);
						SceneCache.uninstallAvatarImg(resName);
					}
					if (this._currentStatus != null && this._currentStatus != "") {
						resName = (this._classNamePrefix + this._currentStatus);
						if (this._classNamePrefix) {
							_sourceBitmapDataObj = SceneCache.installAvatarImg(resName, this._only1LogicAngle);
						}
					}
					
					_lastTime = 0;
					_currentFrame = -1;
					_playCount = 0;
					_playBeforeStart = true;
					_playStart = true;
					_playComplete = false;
				}
				_enablePlay = true;
				needRender = true;
			}
			if (_playCondition.PlayAtBegin) {
				needRender = true;
				_lastTime = 0;
				_currentFrame = -1;
				_playCount = 0;
				_playBeforeStart = true;
				_playStart = true;
				_playComplete = false;
			}
			if (_playCondition.ShowEnd) {
				needRender = true;
				_playCount = 0;
				_playBeforeStart = false;
				_playStart = false;
				_playComplete = false;
			}
		}
		
		public function onAdd():void
		{
			if (_onAdd != null) {
				_onAdd(avatar!=null ? avatar.sceneCharacter : null, this);
			}
		}
		
		public function onRemove():void
		{
			if (_onRemove != null) {
				_onRemove(avatar!=null ? avatar.sceneCharacter : null, this);
			}
		}
		
		public function run(frame:int=-1):void
		{
			var time_1:int;
			var time_2:int;
			var bb:Boolean;
			var px:Number;
			var py:Number;
			var source_x:int;
			var source_y:int;
			var halfWidth:Number;
			var halfHeight:Number;
			var matrix:Matrix;
			var point1:Point;
			var point2:Point;
			var xMax:Number;
			var yMax:Number;
			if (!_enablePlay || !_currentAvatarPartStatus) {
				return;
			}
			renderRectArr.length = 0;
			
			// char.updateNow
			if (avatar.sceneCharacter.updateNow) {
				needRender = true;
			}
			// avatar.updateNow
			if (avatar.updateNow) {
				needRender = true;
			}
			// visible
			if (_oldData.visible != visible) {
				_oldData.visible = visible;
				needRender = true;
			}
			// _playComplete
			if (_playBeforeStart) {
				needRender = true;
			}
			
			// 设置当前帧
			if (frame >= 0) {
				_currentFrame = frame;			// 如果外部提供
				needRender = true;
			} else {
				if (_playCondition.ShowEnd) {	// 如果显示在末尾
					_currentFrame = (_currentAvatarPartStatus.frame - 1);
				} else {
					time_1 = CCRender.nowTime;	// 否则根据当前时间, 来播放帧
					time_2 = (time_1 - _lastTime);
					
					if (time_2 >= _currentAvatarPartStatus.delay) {		// 如果超过了播放时间, 则播放下一帧
						_currentFrame++;
						bb = false;
						
						if (_currentFrame >= _currentAvatarPartStatus.frame) {	// 检测循环
							_currentFrame = 0;
							if (_playCondition.StayAtEnd) {
								_currentFrame = (_currentAvatarPartStatus.frame - 1);	// 停留末尾
								bb = true;
							} else {
								// 循环播放完成
								if (_currentAvatarPartStatus.repeat != 0 && ++_playCount >= _currentAvatarPartStatus.repeat) {
									_currentFrame = (_currentAvatarPartStatus.frame - 1);
									_playComplete = true;
								}
							}
						}
						
						_lastTime = time_1;
						if (!bb && _currentAvatarPartStatus.frame > 1) {
							needRender = true;
						}
					}
				}
			}
			
			// 重绘部位
			if (needRender){
				if (!avatar || !avatar.sceneCharacter) {
					return;
				}
				if (_only1Frame) {
					_currentFrame = 0;
				}
				
				// 如果可见
				if (visible && avatar.visible && avatar.sceneCharacter.visible && avatar.sceneCharacter.inViewDistance())
				{
					// 计算 cutRect, 为当前部位的矩形范围
					
					px = Math.round(this.avatar.sceneCharacter.PixelX);
					py = Math.round(this.avatar.sceneCharacter.PixelY);
					
					cutRect.width = _currentAvatarPartStatus.width;
					cutRect.height = _currentAvatarPartStatus.height;
					// 角度转换: 0, 4567, 左右镜像
					if (_currentLogicAngle == 0 || _currentLogicAngle >= 4) {
						source_x = _currentFrame;
						if (_currentLogicAngle == 0 || _currentLogicAngle == 4) {
							source_y = _currentLogicAngle;		// 0/4
						} else {
							if (_currentLogicAngle == 7){
								source_y = 1;						// 7
							} else {
								if (_currentLogicAngle == 6){
									source_y = 2;					// 6
								} else {
									if (_currentLogicAngle == 5){
										source_y = 3;				// 5
									}
								}
							}
						}
						cutRect.x = (px - _currentAvatarPartStatus.tx);		// 左上角位置
					} else {
						source_x = ((_currentAvatarPartStatus.frame - _currentFrame) - 1);
						source_y = (_currentLogicAngle - 1);
						cutRect.x = ((px + _currentAvatarPartStatus.tx) - _currentAvatarPartStatus.width);	// 镜像位置
					}
					
					// 只有一个角度，只取一行
					if (_currentAvatarPartStatus.only1Angle == 1) {
						source_y = 0;
					}
					
					cutRect.y = (py - _currentAvatarPartStatus.ty);			// 上面位置
					
					// 计算源像素位置
					_sourcePoint.x = (source_x * _currentAvatarPartStatus.width);		// 像素坐标
					_sourcePoint.y = (source_y * _currentAvatarPartStatus.height);
					if (_currentRotation != 0) {
						// 更新  _currentRotation
						if (_oldData.oldDrawRotation != _currentRotation) {
							_oldData.oldDrawRotation = _currentRotation;
							halfWidth = (_currentAvatarPartStatus.width / 2);		// center x/y
							halfHeight = (_currentAvatarPartStatus.height / 2);
							matrix = new Matrix();
							matrix.tx = (matrix.tx - (_sourcePoint.x + halfWidth));	// 向左移动到 该子位图中心坐标
							matrix.ty = (matrix.ty - (_sourcePoint.y + halfHeight));
							matrix.rotate(((_currentRotation * Math.PI) / 180));		// 旋转弧度 
							matrix.tx = (matrix.tx + (_sourcePoint.x + halfWidth));	// 回到中心
							matrix.ty = (matrix.ty + (_sourcePoint.y + halfHeight));
							
							point1 = ZMath.getRotPoint(new Point(halfWidth, halfHeight), new Point(0, 0), _currentRotation);
							point2 = ZMath.getRotPoint(new Point(halfWidth, -halfHeight), new Point(0, 0), _currentRotation);
							xMax = (Math.max(Math.abs(point1.x), Math.abs(point2.x)) * 2);
							yMax = (Math.max(Math.abs(point1.y), Math.abs(point2.y)) * 2);
							_drawSourceBitmapData = new BitmapData(xMax, yMax, true, 0);
							_drawSourceBitmapData.draw(sourceBitmapData, matrix, null, null, new Rectangle(_sourcePoint.x, _sourcePoint.x, _currentAvatarPartStatus.width, _currentAvatarPartStatus.height));
						}
						cutRect.x = (px - (_drawSourceBitmapData.width / 2));
						cutRect.y = (py - (_drawSourceBitmapData.height / 2));
						cutRect.width = _drawSourceBitmapData.width;
						cutRect.height = _drawSourceBitmapData.height;
						_sourcePoint.x = 0;
						_sourcePoint.y = 0;
					} else {
						// 鼠标over，加上发光滤镜
						if (_drawMouseOn && avatar.sceneCharacter.isMouseOn) {
							_drawSourceBitmapData = new BitmapData(_currentAvatarPartStatus.width, _currentAvatarPartStatus.height, true, 0);
							_drawSourceBitmapData.copyPixels(sourceBitmapData, new Rectangle(_sourcePoint.x, _sourcePoint.y, _currentAvatarPartStatus.width, _currentAvatarPartStatus.height), new Point(0, 0), null, null, true);
							if(_currentAvatarPartStatus.classNamePrefix == "npc51." || _currentAvatarPartStatus.classNamePrefix == "npc52." || _currentAvatarPartStatus.classNamePrefix == "npc53."){
								_drawSourceBitmapData.applyFilter(_drawSourceBitmapData, new Rectangle(0, 0, _currentAvatarPartStatus.width, _currentAvatarPartStatus.height), new Point(), MOUSE_ON_GLOWFILTER_BY_RELIGION_NPC);
							}else{
								_drawSourceBitmapData.applyFilter(_drawSourceBitmapData, new Rectangle(0, 0, _currentAvatarPartStatus.width, _currentAvatarPartStatus.height), new Point(), MOUSE_ON_GLOWFILTER);
							}
							
							_sourcePoint.x = 0;
							_sourcePoint.y = 0;
							
							if (avatar.sceneCharacter.headFace && avatar.sceneCharacter.isMouseOn) {
								avatar.sceneCharacter.headFace.filters = [MOUSE_ON_GLOWFILTER];
							}
						} else {
							_drawSourceBitmapData = sourceBitmapData;
							if(avatar.sceneCharacter.headFace)
								avatar.sceneCharacter.headFace.filters = [];
						}
					}
					
					// 遮挡效果，掩码位图修改, 如果在掩码中, 则建立 _inMaskDrawSourceBitmapData 并 半透明度绘制
					if (avatar.sceneCharacter.isInMask) {
						_inMaskDrawSourceBitmapData = new BitmapData(cutRect.width, cutRect.height, true, 0);
						_inMaskDrawSourceBitmapData.copyPixels(_drawSourceBitmapData, new Rectangle(_sourcePoint.x, _sourcePoint.y, cutRect.width, cutRect.height), new Point(0, 0), null, null, true);
						_inMaskDrawSourceBitmapData.colorTransform(_inMaskDrawSourceBitmapData.rect, new ColorTransform(1, 1, 1, 0.5, 0, 0, 0, 0));
						_sourcePoint.x = 0;
						_sourcePoint.y = 0;
					} else {
						if (_inMaskDrawSourceBitmapData != null) {
							_inMaskDrawSourceBitmapData.dispose();
							_inMaskDrawSourceBitmapData = null;
						}
					}
				}
				// 否则, 不可见
				else {
					cutRect.setEmpty();
					_sourcePoint.x = 0;
					_sourcePoint.y = 0;
				}
				
				// 把  oldCutRect 和  cutRect 放入到 clearBoundsArr 中
				if (avatar.sceneCharacter.scene) {
					avatar.sceneCharacter.scene.sceneAvatarLayer.clearBoundsArr.push(Bounds.fromRectangle(_oldData.oldCutRect));
					avatar.sceneCharacter.scene.sceneAvatarLayer.clearBoundsArr.push(Bounds.fromRectangle(cutRect));
				}
				
				// 添加到  renderRectArr 中
				renderRectArr.push(cutRect);
				
				// 复制 oldCutRect
				_oldData.oldCutRect.x = cutRect.x;
				_oldData.oldCutRect.y = cutRect.y;
				_oldData.oldCutRect.width = cutRect.width;
				_oldData.oldCutRect.height = cutRect.height;
			}
			// 不需要重绘
			else {
				// 添加到  restingAvatarPartArr 中
				if (avatar.sceneCharacter.scene) {
					avatar.sceneCharacter.scene.sceneAvatarLayer.restingAvatarPartArr.push(this);
				}
			}
			
			// 鼠标覆盖
			if (_drawMouseOn && !cutRect.isEmpty()) {
				if (avatar.sceneCharacter.mouseRect != null) {
					avatar.sceneCharacter.mouseRect = avatar.sceneCharacter.mouseRect.union(cutRect);
				} else {
					avatar.sceneCharacter.mouseRect = cutRect;
				}
			}
		}
		
		/**
		 * 绘制, 并执行很多更新过程
		 */
		public function draw(iBitmap:IBitmapDrawable):void
		{
			var bitmapData:BitmapData;
			var rect:Rectangle;
			if (!needRender) {
				return;
			}
			needRender = false;
			if (!_enablePlay || !_currentAvatarPartStatus) {
				return;
			}
			
			// 执行 _playBeforeStart
			if (_playBeforeStart) {
				_playBeforeStart = false;
				if (_onPlayBeforeStart != null) {		// _onPlayBeforeStart( sceneCharacter, this)
					_onPlayBeforeStart(avatar!=null ? avatar.sceneCharacter : null, this);
				}
			}
			if (!_enablePlay || !_currentAvatarPartStatus) {
				return;
			}
			if (!avatar || !avatar.sceneCharacter) {
				return;
			}
			
			// 绘制位图, 判断可见性: this, avatar, avatar.sceneCharacter, camera
			if (visible && avatar.visible && avatar.sceneCharacter.visible && avatar.sceneCharacter.inViewDistance()) {
				bitmapData = _inMaskDrawSourceBitmapData || _drawSourceBitmapData;
				if (bitmapData != null) {
					// 遍历重绘区, 复制像素
					for each (rect in renderRectArr) {
						if (!rect.isEmpty()) {
							copyToAvatarBD(iBitmap, bitmapData, (_sourcePoint.x + (rect.x - cutRect.x)), (_sourcePoint.y + (rect.y - cutRect.y)), rect.width, rect.height, rect.x, rect.y);
						}
					}
				}
			}
			
			// 执行  _playStart
			if (_playStart) {
				_playStart = false;
				if (_onPlayStart != null) {
					_onPlayStart(avatar!=null ? avatar.sceneCharacter : null, this);
				}
			}
			// 执行 _onPlayUpdate
			if (_onPlayUpdate != null) {
				_onPlayUpdate(avatar!=null ? avatar.sceneCharacter : null, this);
			}
			
			// 显示攻击动画
			if (_callBackAttack) {
				if (avatar.sceneCharacter.showAttack != null && _currentFrame >= Math.max(_currentAvatarPartStatus.frame - 3, 0)) {
					_callBackAttack = false;
					avatar.sceneCharacter.showAttack();
					avatar.sceneCharacter.showAttack = null;
				}
			}
			
			// 执行 _playComplete
			if (_playComplete) {
				_playComplete = false;
				_enablePlay = false;
				
				if (_onPlayComplete != null) {
					_onPlayComplete(avatar!=null ? avatar.sceneCharacter : null, this);
				}
				
				if (_autoRecycle && avatar) {
					avatar.removeAvatarPart(this);
				} else {
					if (_autoToStand && avatar) {
						avatar.playTo(CharStatusType.STAND);
					}
				}
			}
		}
		
		/**
		 * 绘制像素
		 */
		private function copyToAvatarBD(iBitmap:IBitmapDrawable, src:BitmapData, sx:int, sy:int, width:int, height:int, left:int, top:int):void
		{
			if (!src) {
				return;
			}
			if (iBitmap is SceneAvatarLayer) {
				(iBitmap as SceneAvatarLayer).copyImage(src, sx, sy, width, height, left, top);
			} else {
				if ((iBitmap is BitmapData)) {
					left = left + ((iBitmap as BitmapData).width / 2);
					top = top + ((iBitmap as BitmapData).height / 2);
					(iBitmap as BitmapData).copyPixels(src, new Rectangle(sx, sy, width, height), new Point(left, top), null, null, true);
				}
			}
		}
		
		/**
		 * 根据像素位置判断命中
		 */
		public function hitPoint(pos:Point):Boolean
		{
			var colorPoint:uint;
			var bitmapData:BitmapData = _inMaskDrawSourceBitmapData || _drawSourceBitmapData;
			if (bitmapData != null) {
				colorPoint = bitmapData.getPixel32((pos.x - cutRect.x + _sourcePoint.x), (pos.y - cutRect.y + _sourcePoint.y));
				if (colorPoint != 0) {
					return true;
				}
			}
			return false;
		}
		
		public function clearMe():void
		{
			if (avatar.sceneCharacter.scene) {
				avatar.sceneCharacter.scene.sceneAvatarLayer.removeBoundsArr.push(Bounds.fromRectangle(_oldData.oldCutRect));
			}
		}
		
		public function get currentAvatarPartStatus():AvatarPartStatus
		{
			return _currentAvatarPartStatus;
		}
		
		/**
		 * 释放资源 
		 * 
		 */
		public function dispose():void
		{
			var _local1:String;
			usable = false;
			avatarParamData = null;
			clearMe();
			if (_currentStatus != null && _currentStatus != "") {
				_local1 = (_classNamePrefix + _currentStatus);
				SceneCache.uninstallAvatarImg(_local1);
			}
			needRender = false;
			_oldData = null;
			cutRect = null;
			_sourcePoint = null;
			renderRectArr = null;
			id = "";
			avatar = null;
			type = "";
			_classNamePrefix = "";
			depth = 0;
			useType = 0;
			_avatarPartStatusRes = null;
			_onPlayBeforeStart = null;
			_onPlayStart = null;
			_onPlayUpdate = null;
			_onPlayComplete = null;
			_onAdd = null;
			_onRemove = null;
			_sourceBitmapDataObj = null;
			if (_drawSourceBitmapData) {
				_drawSourceBitmapData = null;
			}
			if (_inMaskDrawSourceBitmapData) {
				_inMaskDrawSourceBitmapData.dispose();
				_inMaskDrawSourceBitmapData = null;
			}
			_currentStatus = "";
			_currentAvatarPartStatus = null;
			_currentFrame = -1;
			_currentLogicAngle = 0;
			_currentRotation = 0;
			_lastTime = 0;
			_playCount = 0;
			_playBeforeStart = false;
			_playStart = false;
			_playComplete = false;
			_playCondition;
			_only1Frame = false;
			_autoRecycle = false;
			_autoToStand = false;
			_drawMouseOn = true;
			_callBackAttack = false;
			_only1LogicAngle = false;
			_enablePlay = false;
			visible = true;
			isBlank = false;
		}
		
		/**
		 * 重置 
		 * @param arr
		 * 
		 */
		public function reset(arr:Array):void
		{
			id = arr[0];
			type = (arr[1] || AvatarPartType.BODY);
			depth = arr[2];
			useType = arr[3];
			_avatarPartStatusRes = arr[4];
			var vars:Object = arr[5];
			if (vars != null) {
				_onPlayBeforeStart = vars.onPlayBeforeStart;
				_onPlayStart = vars.onPlayStart;
				_onPlayUpdate = vars.onPlayUpdate;
				_onPlayComplete = vars.onPlayComplete;
				_onAdd = vars.onAdd;
				_onRemove = vars.onRemove;
			}
			usable = true;
			needRender = true;
			_oldData = {
				visible:true,
				oldCutRect:new Rectangle(),
				oldDrawRotation:-1
			};
			cutRect = new Rectangle();
			_sourcePoint = new Point();
			renderRectArr = [];
		}
	}
}