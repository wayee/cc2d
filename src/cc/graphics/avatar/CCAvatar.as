package cc.graphics.avatar
{
	import cc.CCCharacter;
	import cc.define.AvatarPartID;
	import cc.define.AvatarPartType;
	import cc.define.CharStatusType;
	import cc.define.CharType;
	import cc.events.CCEvent;
	import cc.events.CCEventActionStatus;
	import cc.loader.AvatarPartLoader;
	import cc.tools.SceneCache;
	import cc.tools.ScenePool;
	import cc.vo.avatar.AvatarParamData;
	import cc.vo.avatar.AvatarPlayCondition;
	
	import flash.display.IBitmapDrawable;
	import flash.geom.Point;
	
	import wit.event.EventDispatchCenter;
	import wit.handler.HandlerHelper;
	import wit.pool.IPoolObject;

	public class CCAvatar implements IPoolObject
	{
		public var usable:Boolean = false;
		public var sceneCharacter:CCCharacter;						// 场景角色信息
		public var status:String = "stand";							// 当前状态
		public var logicAngle:int = 0;								// 逻辑方向, [0-7]
		public var visible:Boolean = true;							// 可见性
		public var updateNow:Boolean;								// 需要更新显示
		public var playCondition:AvatarPlayCondition;				// 播放/循环方式 
		
		private var _oldData:Object;								// {visible:true} 重绘区管理
		private var _isOnMount:Boolean = false;
		
		private var _hideAvatarPartTypes:Array;						// AvatarPartType 中枚举值, 被隐藏的部分, 可以不依赖于 avatarParts
		public var avatarParts:Array;								// [AvatarPart], 每个部分
		
		private var _bornAvatarParamData:AvatarParamData;			// 身体数据 -- 原始值
		private var _bornOnMountAvatarParamData:AvatarParamData;	// 骑马时的身体数据 -- 原始值
		private var _bornMountAvatarParamData:AvatarParamData;		// 马的数据 -- 原始值
		
		/**
		 * Avatar 必须关联到一个  CCCharacter 对象, 作为后者的表观(VIEW)
		 */
		public function CCAvatar(sceneChar:CCCharacter) {
			_hideAvatarPartTypes = [];
			avatarParts = [];
			super();
			reset([sceneChar]);
		}
		
		public static function createAvatar(sceneChar:CCCharacter):CCAvatar {
			return ScenePool.avatarPool.createObj(CCAvatar, sceneChar) as CCAvatar;
		}

		public static function recycleAvatar(avatar:CCAvatar):void {
			ScenePool.avatarPool.disposeObj(avatar);
		}
		
		public function playTo(statusArg:String=null, logicAngleArg:int=-1, rotation:int=-1, 
							   avatarPlayCondition:AvatarPlayCondition=null):void {
			var part:CCAvatarPart;
			var event:CCEvent;
			var oldStatus:String = this.status;
			
			// 设置 statuc, logicAngleArg, playCondition
			if (statusArg != null){
				this.status = statusArg;
			}
			if (logicAngleArg != -1) {
				this.logicAngle = logicAngleArg;
			}
			if (avatarPlayCondition != null) {
				this.playCondition = avatarPlayCondition;
			} else {
				if (this.playCondition == null) {
					this.playCondition = new AvatarPlayCondition();
				}
			}
			
			// 每个部分, 播放该动作
			for each (part in this.avatarParts) {
				part.playTo(statusArg, logicAngle, rotation, playCondition.clone());
			}
			
			// 执行  showAttack 函数
			if (sceneCharacter.showAttack != null) {
				HandlerHelper.execute(sceneCharacter.showAttack);
				sceneCharacter.showAttack = null;
			}
			
			// 如果是主对象, 并且状态变更. 发送通知消息
			if ( sceneCharacter.scene && sceneCharacter == sceneCharacter.scene.mainChar && !(oldStatus == statusArg) )
			{
				event = new CCEvent(CCEvent.STATUS, CCEventActionStatus.CHANGED, [sceneCharacter, statusArg]);
				EventDispatchCenter.getInstance().dispatchEvent(event);
			}
		}
		
		public function run(frame:int=-1):void {
			// 更新 visible
			if (_oldData.visible != visible) {
				_oldData.visible = visible;
				updateNow = true;
			}
			
			// 更新每个部分
			var part:CCAvatarPart;
			for each (part in avatarParts) {
				part.run(frame);
			}
			
			// 恢复标记
			updateNow = false;
		}
		
		public function draw(bitmap:IBitmapDrawable):void {
			var part:CCAvatarPart;
			for each (part in avatarParts) {
				part.draw(bitmap);
			}
		}
		
		public function hitPoint(mousePoint:Point):Boolean {
			var avatarPart:CCAvatarPart;
			for each (avatarPart in avatarParts) {
				// not the magic or magic pass
				if (avatarPart.type != AvatarPartType.MAGIC && avatarPart.type != AvatarPartType.MAGIC_PASS && avatarPart.hitPoint(mousePoint)) {
					return true;
				}
			}
			return false;
		}
		
		public function clearMe():void {
			var part:CCAvatarPart;
			for each (part in avatarParts) {
				part.clearMe();
			}
		}
		
		/**
		 * 获取所有部件中最大播放时间的 
		 * @return int 时间（毫秒）
		 */
		/*public function getMaxTimeFromPart():int
		{
			var time:int = 0;
			
			var totalTime:int;
			var part:CCAvatarPart;
			if (avatarParts && avatarParts.length > 0) {
				for each (part in avatarParts) {
					if (part.currentAvatarPartStatus) {
						totalTime = part.currentAvatarPartStatus.delay * (part.currentAvatarPartStatus.frame-1);
						if (totalTime > time) {
							time = totalTime;
						}
					}
				}
			}
			
			return time;
		}*/
		
		public function dispose():void {
			usable = false;
			removeAllAvatarParts(false);
			sceneCharacter = null;
			status = CharStatusType.STAND;
			avatarParts.length = 0;
			logicAngle = 0;
			playCondition = null;
			_hideAvatarPartTypes.length = 0;
			visible = true;
			updateNow = false;
			_oldData = null;
			_isOnMount = false;
			_bornAvatarParamData = null;
			_bornOnMountAvatarParamData = null;
			_bornMountAvatarParamData = null;
		}
		
		public function reset(value:Array):void {
			sceneCharacter = value[0];
			_oldData = {visible:true};
			usable = true;
		}
		
		/**
		 * 是否在马背上
		 */
		public function set IsOnMount(b:Boolean):void {
			this._isOnMount = b;
			this.updateDefaultAvatar();
		}
		
		public function get IsOnMount():Boolean{
			return this._isOnMount;
		}
		
		public function GetBornAvatarParamData():AvatarParamData {
			return _bornAvatarParamData;
		}
		
		public function SetBornAvatarParamData(avatarParamData:AvatarParamData):void {
			if (avatarParamData == null) {
				return;
			}
			avatarParamData.Id_noCheckValid = AvatarPartID.BORN;			// id
			avatarParamData.avatarPartType = AvatarPartType.BODY;			// type
			avatarParamData.depth = AvatarPartType.GetDefaultDepth(AvatarPartType.BODY);
			avatarParamData.useType = 1;
			avatarParamData.clearSameType = false;
			this._bornAvatarParamData = avatarParamData;
			this.updateDefaultAvatar();
		}
		
		/**
		 * 设置 _bornOnMountAvatarParamData
		 */
		public function GetBornOnMountAvatarParamData():AvatarParamData {
			return this._bornOnMountAvatarParamData;
		}
		
		public function SetBornOnMountAvatarParamData(apd:AvatarParamData):void{
			if (apd == null) {
				return;
			}
			apd.Id_noCheckValid = AvatarPartID.BORN_ONMOUNT;		// id
			apd.avatarPartType = AvatarPartType.BODY;				// type
			apd.depth = AvatarPartType.GetDefaultDepth(AvatarPartType.BODY);
			apd.useType = 2;
			apd.clearSameType = false;
			this._bornOnMountAvatarParamData = apd;
			this.updateDefaultAvatar();
		}
		
		/**
		 * 设置 _bornMountAvatarParamData
		 */
		public function GetBornMountAvatarParamData():AvatarParamData{
			return this._bornMountAvatarParamData;
		}
		
		public function SetBornMountAvatarParamData(apd:AvatarParamData):void{
			if (apd == null) {
				return;
			}
			apd.Id_noCheckValid = AvatarPartID.BORN_MOUNT;		// id
			apd.avatarPartType = AvatarPartType.MOUNT;			// type
			apd.depth = AvatarPartType.GetDefaultDepth(AvatarPartType.MOUNT);
			apd.useType = 2;
			apd.clearSameType = false;
			this._bornMountAvatarParamData = apd;
			this.updateDefaultAvatar();
		}
		
		private function updateDefaultAvatar():void {
			if ( !this._isOnMount ) { // 不在马上
				// 删除  BORN_ONMOUNT, BORN_MOUNT
				this.sceneCharacter.RemoveAvatarPartByID(AvatarPartID.BORN_ONMOUNT, false);	// this.removeAvatarPartByID
				this.sceneCharacter.RemoveAvatarPartByID(AvatarPartID.BORN_MOUNT, false);
				
				// 如果 没有身体
				if ( !hasTypeAvatarParts(AvatarPartType.BODY) ) {
					// 根据 _bornAvatarParamData 加载身体数据 
					if (this._bornAvatarParamData != null) {
						this.sceneCharacter.LoadAvatarPart(this._bornAvatarParamData);
					} else {
						// 否则根据 blankAvatarParamData(默认空白对象) 来加载身体
						if (this.sceneCharacter.scene.blankAvatarParamData != null) {
							if (this.sceneCharacter.type != CharType.DUMMY 
								&& this.sceneCharacter.type != CharType.BAG) {
								this.sceneCharacter.LoadAvatarPart(this.sceneCharacter.scene.blankAvatarParamData);
							}
						}
					}
				} else {
					if (this.hasIDAvatarPart(AvatarPartID.BLANK)) {
						if (this._bornAvatarParamData != null) {
							this.sceneCharacter.LoadAvatarPart(this._bornAvatarParamData);
						}
					}
				}
			} else { // 在马上
				this.sceneCharacter.RemoveAvatarPartByID(AvatarPartID.BLANK, false);
				this.sceneCharacter.RemoveAvatarPartByID(AvatarPartID.BORN, false);
				
				if ( !this.hasTypeAvatarParts(AvatarPartType.BODY) ) {
					if (this._bornOnMountAvatarParamData != null) {
						this.sceneCharacter.LoadAvatarPart(this._bornOnMountAvatarParamData);
					}
				}
				if ( !this.hasTypeAvatarParts(AvatarPartType.MOUNT) ) {
					if (this._bornMountAvatarParamData != null) {
						this.sceneCharacter.LoadAvatarPart(this._bornMountAvatarParamData);
					}
				}
			}
		}
		
		public function hasTypeAvatarParts(partType:String):Boolean {
			var part:CCAvatarPart;
			for each (part in avatarParts) {
				if (part.type == partType) {
					return true;
				}
			}
			return false;
		}
		
		public function hasIDAvatarPart(partID:String):Boolean {
			var part:CCAvatarPart;
			for each (part in avatarParts) {
				if (part.id == partID) {
					return true;
				}
			}
			return false;
		}

		public function loadAvatarPart(param:AvatarParamData):void {
			AvatarPartLoader.LoadAvatarPart(sceneCharacter, param);
		}
		
		public function showAvatarPart(part:CCAvatarPart):void {
			part.visible = true;
		}
		
		public function hideAvatarPart(part:CCAvatarPart):void {
			part.visible = true;
		}
		
		public function showAvatarPartsByType(partType:String):void {
			var part:CCAvatarPart;
			var index:int = this._hideAvatarPartTypes.indexOf(partType);	 
			if (index != -1) {
				this._hideAvatarPartTypes.splice(index, 1);		// 保存到 数组中, 即时部分数据未就绪, 仍可设置
			}
			for each (part in this.avatarParts) {
				if (part.type == partType) {
					part.visible = true;
				}
			}
		}
		
		public function hideAvatarPartsByType(partType:String):void {
			var part:CCAvatarPart;
			if (this._hideAvatarPartTypes.indexOf(partType) == -1){
				this._hideAvatarPartTypes.push(partType);
			}
			for each (part in this.avatarParts) {
				if (part.type == partType) {
					part.visible = false;
				}
			}
		}
		
		public function showAvatarPartByID(partID:String):void {
			var part:CCAvatarPart = this.getAvatarPartByID(partID);
			if (part != null) {
				part.visible = true;
			}
		}
		
		public function hideAvatarPartByID(partID:String):void {
			var part:CCAvatarPart = this.getAvatarPartByID(partID);
			if (part != null) {
				part.visible = false;
			}
		}

		public function addAvatarPart(avatarPart:CCAvatarPart, removeExist:Boolean=false):void {
			var part:CCAvatarPart;
			
			// 删除同类型
			if (removeExist) {
				removeAvatarPartsByType(avatarPart.type, false);
			}
			// 已经添加, 忽略
			if (avatarParts.indexOf(avatarPart) != -1) {
				return;
			}
			// 根据 ID 删除
			if (avatarPart.id != null && avatarPart.id != "") {
				part = getAvatarPartByID(avatarPart.id);
				if (part != null) {
					removeAvatarPart(part, false, false);
				}
			}
			
			// 添加到  avatarParts
			avatarPart.visible = (_hideAvatarPartTypes.indexOf(avatarPart.type) == -1);
			avatarPart.avatar = this;
			avatarPart.needRender = true;
			avatarParts.push(avatarPart);
			avatarParts.sortOn("depth", Array.NUMERIC);
			avatarPart.onAdd();
		}
		
		public function removeAvatarPart(avatarPart:CCAvatarPart, byType:Boolean=false, update:Boolean=true):void {
			var index:int;
			if (byType) {
				removeAvatarPartsByType(avatarPart.type);
			} else {
				index = avatarParts.indexOf(avatarPart);
				if (index == -1){
					return;
				}
				avatarPart.onRemove();
				avatarParts.splice(index, 1);
				CCAvatarPart.recycleAvatarPart(avatarPart);
			}
			if (update) {
				updateDefaultAvatar();
			}
		}
		
		public function removeAvatarPartByID(partID:String, update:Boolean=true):void {
			var part:CCAvatarPart;
			if (partID == null || partID == "") {
				return;
			}
			SceneCache.RemoveWaitingAvatar(sceneCharacter, partID);
			for each (part in avatarParts) {
				if (part.id == partID) {
					part.onRemove();
					avatarParts.splice(avatarParts.indexOf(part), 1);
					CCAvatarPart.recycleAvatarPart(part);
					break;
				}
			}
			if (update) {
				updateDefaultAvatar();
			}
		}
		
		public function removeAvatarPartsByType(partType:String, update:Boolean=true):void {
			var part:CCAvatarPart;
			SceneCache.RemoveWaitingAvatar(this.sceneCharacter, null, partType);
			for each (part in this.avatarParts) {
				if (part.type == partType) {
					part.onRemove();
					this.avatarParts.splice(this.avatarParts.indexOf(part), 1);
					CCAvatarPart.recycleAvatarPart(part);
				}
			}
			if (update) {
				this.updateDefaultAvatar();
			}
		}
		
		public function removeAllAvatarParts(update:Boolean=true):void {
			var part:CCAvatarPart;
			SceneCache.RemoveWaitingAvatar(this.sceneCharacter);
			for each (part in this.avatarParts) {
				part.onRemove();
				CCAvatarPart.recycleAvatarPart(part);
			}
			this.avatarParts.length = 0;
			if (update) {
				this.updateDefaultAvatar();
			}
		}
		
		public function getAvatarPartByID(id:String):CCAvatarPart {
			var part:CCAvatarPart;
			for each (part in this.avatarParts) {
				if (part.id == id) {
					return (part);
				}
			}
			return null;
		}
		
		public function getAvatarPartsByType(type:String):Array {
			var part:CCAvatarPart;
			var arr:Array = [];
			for each (part in this.avatarParts) {
				if (part.type == type){
					arr.push(part);
				}
			}
			return arr;
		}
	}
}