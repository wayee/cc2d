package cc
{
	import cc.define.RestType;
	import cc.graphics.avatar.CCAvatar;
	import cc.graphics.avatar.CCAvatarPart;
	import cc.graphics.tagger.HeadFace;
	import cc.helper.MagicHelper;
	import cc.helper.TaggerHelper;
	import cc.helper.WalkHelper;
	import cc.tools.SceneCache;
	import cc.tools.ScenePool;
	import cc.utils.Transformer;
	import cc.vo.avatar.AvatarParamData;
	import cc.vo.avatar.AvatarPlayCondition;
	import cc.vo.map.MapTile;
	import cc.vo.walk.WalkData;
	import cc.walk.WalkStep;
	
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import wit.pool.IPoolObject;
	import wit.utils.ZMath;

	/**
	 * 场景中的对象，继承自BaseElement
	 * <br> 人物、NPC、怪物、传送门、掉落包和傀儡等
	 * 
	 * -|- 垂直向下为0度角
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class CCCharacter extends CCNode implements IPoolObject
	{
        public var type:int;
		public var restStatus:int;
        public var usable:Boolean = false;
        public var visible:Boolean = true;
        public var showIndex:int = 0;
        public var updateNow:Boolean;			// 需要更新
		
		public var specilizeX:Number = 0;
		public var specilizeY:Number = 0;
		
		public var avatar:CCAvatar;				// 外观
        public var headFace:HeadFace;			// 在 SceneHeadLayer 中显示, 昵称/对话 等显示
        public var scene:CCScene;
		
        public var oldMouseRect:Rectangle;		// 鼠标范围
        public var mouseRect:Rectangle;
        public var isMouseOn:Boolean;
        public var isSelected:Boolean;
        
        public var showAttack:Function;			// 显示攻击动画回调, see Avatar.playTo
		
		/**
		 * {
		 * visible:true,
		 * inViewDistance:false,
		 * isMouseOn:false,
		 * isSelected:false,
		 * pos:new Point()
		 * }
		 */		
        private var oldData:Object;				// 旧的状态数据
        private var walkData:WalkData;			// 移动数据

		/**
		 * 场景对象 
		 * @param type 类型
		 * @param scene 场景
		 * @param tx 块坐标x
		 * @param ty 块坐标y
		 * @param showIndex 深度
		 */
        public function CCCharacter(type:int, scene:CCScene, tx:int=0, ty:int=0, showIndex:int=0) {
            reset([type, scene, tx, ty, showIndex]);
        }
		
        public static function createSceneCharacter(type:int, scene:CCScene, tx:int=0, 
													ty:int=0, showIndex:int=0):CCCharacter {
            return ScenePool.sceneCharacterPool.createObj(CCCharacter, type, scene, tx, ty, showIndex) as CCCharacter;
        }
		
        public static function recycleSceneCharacter(sceneChar:CCCharacter):void {
            ScenePool.sceneCharacterPool.disposeObj(sceneChar);
        }

        public function get isInMask():Boolean {
            return ( SceneCache.MapTiles[TileX + "_" + TileY] != null && 
				(SceneCache.MapTiles[TileX + "_" + TileY] as MapTile).isMask );
        }
		
        public function get Walkdata():WalkData {
            if (walkData == null) {
                walkData = new WalkData();
            }
            return walkData;
        }
		
        public function faceTo(px:Number, py:Number):void {
            if (pixelX == px && pixelY == py) {
                return;
            }
			
            var angle:Number = ZMath.getTwoPointsAngle(new Point(pixelX, pixelY), new Point(px, py));
            setAngle(angle);
        }
		
        public function faceToTile(p_x:Number, p_y:Number):void {
            var pos:Point = Transformer.TransTilePoint2PixelPoint(new Point(p_x, p_y));
            faceTo(pos.x, pos.y);
        }
		
        public function faceToCharacter(p_char:CCCharacter):void {
            faceTo(p_char.PixelX, p_char.PixelY);
        }
		
        public function setXY(p_x:Number, p_y:Number):void {
            PixelX = p_x;
            PixelY = p_y;
        }
		
        public function setTileXY(p_tx:Number, p_ty:Number):void {
			// don't change the order, set y and then x
			TileY = p_ty;	
			TileX = p_tx;
        }
		
        public function reviseTileXY(p_tx:Number, p_ty:Number):void {
            setTileXY(p_tx, p_ty);
            WalkHelper.reviseWalkPath(this);
        }
		
        public function setSpeed(p_walkSpeed:Number):void {
            walkData.walk_speed = p_walkSpeed;
        }
		
        public function getSpeed():Number {
            return walkData.walk_speed;
        }
		
        public function setStatus(p_status:String):void {
            if (getStatus() == p_status) {
                return;
            }
            playTo(p_status, -1, -1);
        }
		
        public function getStatus():String {
            return avatar.status;
        }
		
        public function setAngle(p_angle:Number):void {
            var logicAngle:int = Transformer.TransAngle2LogicAngle(p_angle);  // angle: 0-360
			setLogicAngle(logicAngle);	// logic angle: 0-7	
        }
		
        public function setLogicAngle(p_angle:int):void{
            if (getLogicAngle() == p_angle) {
                return;
            }
            playTo(null, p_angle, -1); // 0-7
        }
		
        public function getLogicAngle():int {
            return avatar.logicAngle;
        }
		
        public function get logicAnglePRI():int {
			var tmp:Array = [0, 1, 3, 5, 7, 6, 4, 2];
			var index:int = (avatar.logicAngle>7 || avatar.logicAngle<0) ? 0 : tmp[avatar.logicAngle];
			return index;
        }
		
        public function setRotation(p_rotation:Number):void {
            playTo(null, -1, p_rotation);
        }
		
        public function playTo(p_status:String=null, p_logicAngle:int=-1, p_rotation:int=-1, 
							   p_playCondition:AvatarPlayCondition=null):void {
            avatar.playTo(p_status, p_logicAngle, p_rotation, p_playCondition);
        }
		
        public function stopWalk(is_stand:Boolean=true):void {
            WalkHelper.stopWalk(this, is_stand);
        }
		
		/**
		 * 走路
		 * <br> 需要先经过寻路后获取路径数组
		 * 
		 * @param targetTilePoint 目标
		 * @param walkSpeed 速度
		 * @param error 距离误差
		 * @param walkVars 回调列表
		 */
        public function walk(targetTilePoint:Point, walkSpeed:Number=-1, 
							 error:Number=0, walkVars:Object=null):void {
            WalkHelper.walk(this, targetTilePoint, walkSpeed, error, walkVars);
        }
		
		/**
		 * 走路
		 * <br> 直接提供路径 
		 */
        public function walk0(walkPaths:Array, targetTilePoint:Point=null, walkSpeed:Number=-1, 
							  error:Number=0, walkVars:Object=null):void {
            WalkHelper.walk0(this, walkPaths, targetTilePoint, walkSpeed, error, walkVars);
        }
		
		/**
		 * 走路
		 * <br> 路径信息是二进制
		 */
        public function walk1(pathByteData:ByteArray, targetTilePoint:Point=null, 
							  walkSpeed:Number=-1, error:Number=0, walkVars:Object=null):void {
            WalkHelper.walk1(this, pathByteData, targetTilePoint, walkSpeed, error, walkVars);
        }
		
		/**
		 * 跳跃 
		 */		
		public function jump(p_pos:Point, p_speed:Number=-1, p_max_dis:Number=-1, p_vars:Object=null):void {
			WalkHelper.jump(this, p_pos, p_speed, p_max_dis, p_vars);
		}
		public function lineTo(p_pos:Point, p_speed:Number, p_is_pet:Boolean=false, p_vars:Object=null):void {
			WalkHelper.lineTo(this, p_pos, p_speed, p_is_pet, p_vars);
		}
		public function lineToPixel(p_pos:Point, p_speed:Number, p_callback:Function=null):void {
			WalkHelper.lineToPixel(this, p_pos, p_speed, p_callback);
		}
		
		///////////////////////////////////
		// 角色部件接口
		///////////////////////////////////
		
		public function setBornAvatarParamData(avatarParamData:AvatarParamData):void {
			avatar.setBornAvatarParamData(avatarParamData);
		}
		public function getBornAvatarParamData():AvatarParamData {
			return avatar.getBornAvatarParamData();
		}
		public function hasTypeAvatarParts(partType:String):Boolean {
			return avatar.hasTypeAvatarParts(partType);
		}
		public function hasIDAvatarPart(partID:String):Boolean {
			return (avatar.hasIDAvatarPart(partID));
		}
		public function loadAvatarPart(avatarParamData:AvatarParamData=null):void {
			avatar.loadAvatarPart(avatarParamData);
		}
		public function showAvatarPart(part:CCAvatarPart):void {
			avatar.showAvatarPart(part);
		}
		public function hideAvatarPart(part:CCAvatarPart):void {
			avatar.hideAvatarPart(part);
		}
		public function showAvatarPartsByType(partType:String):void {
			avatar.showAvatarPartsByType(partType);
		}
		public function hideAvatarPartsByType(partType:String):void {
			avatar.hideAvatarPartsByType(partType);
		}
		public function showAvatarPartByID(partID:String):void {
			avatar.showAvatarPartByID(partID);
		}
		public function hideAvatarPartByID(partID:String):void {
			avatar.hideAvatarPartByID(partID);
		}
		public function addAvatarPart(part:CCAvatarPart, removeExist:Boolean=false):void {
			avatar.addAvatarPart(part, removeExist);
		}
		public function removeAvatarPart(part:CCAvatarPart, byType:Boolean=false, update:Boolean=true):void {
			avatar.removeAvatarPart(part, byType, update);
		}
		public function removeAllAvatarParts(update:Boolean=true):void {
			avatar.removeAllAvatarParts(update);
		}
		public function removeAvatarPartsByType(partType:String, update:Boolean=true):void {
			avatar.removeAvatarPartsByType(partType, update);
		}
		public function removeAvatarPartByID(partID:String, update:Boolean=true):void {
			avatar.removeAvatarPartByID(partID, update);
		}
		public function getAvatarPartsByType(partType:String):Array {
			return avatar.getAvatarPartsByType(partType);
		}
		public function getAvatarPartByID(partID:String):CCAvatarPart {
			return avatar.getAvatarPartByID(partID);
		}
		

		///////////////////////////////////
		// 法术接口
		///////////////////////////////////
		
		public function showMagic_from1passNtoN(toArray:Array, fromApd:AvatarParamData=null, 
												toApd:AvatarParamData=null, passApd:AvatarParamData=null):void {
			MagicHelper.showMagic_from1passNtoN(this, toArray, fromApd, toApd, passApd);
		}
		
		public function showMagic_from1pass1toPointArea(toPoint:Point, fromApd:AvatarParamData=null, 
														toApd:AvatarParamData=null, passApd:AvatarParamData=null):void {
			MagicHelper.showMagic_from1pass1toPointArea(this, toPoint, fromApd, toApd, passApd);
		}
		
		public function showMagic_from1passNtoRectArea(toRectCenter:Point, toRectHalfWidth:int, 
													   toRectHalfHeight:int, showSpace:int=25, 
													   includeCenter:Boolean=true, fromApd:AvatarParamData=null, 
													   toApd:AvatarParamData=null, passApd:AvatarParamData=null):void {
			MagicHelper.showMagic_from1passNtoRectArea(this, toRectCenter, toRectHalfWidth, 
														toRectHalfHeight, showSpace, includeCenter, fromApd, toApd, toApd);
		}
		
		public function showMagic_from1pass1toRectArea(toRectCenter:Point, toRectHalfWidth:int, 
													   toRectHalfHeight:int, showSpace:int=25, 
													   includeCenter:Boolean=true, fromApd:AvatarParamData=null, 
													   toApd:AvatarParamData=null, passApd:AvatarParamData=null):void {
			MagicHelper.showMagic_from1pass1toRectArea(this, toRectCenter, toRectHalfWidth, 
														toRectHalfHeight, showSpace, includeCenter, fromApd, toApd, toApd);
		}
		
		
		///////////////////////////////////
		// HeadFace接口
		///////////////////////////////////
		
		public function showHeadFace(nickName:String="", 
									 nickNameColor:uint=0xFFFFFF, customTitle:String="", 
									 leftIcon:DisplayObject=null, topIcon:DisplayObject=null):void {
			TaggerHelper.ShowHeadFace(this, nickName, nickNameColor, customTitle, leftIcon, topIcon);
		}
		
		public function setHeadFaceNickNameVisible(b:Boolean):void {
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceNickNameVisible(b);
		}
		
		public function setHeadFaceCustomTitleVisible(b:Boolean):void {
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceCustomTitleVisible(b);
		}
		
		public function setHeadFaceLeftIcoVisible(b:Boolean):void {
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceLeftIcoVisible(b);
		}
		
		public function setHeadFaceTopIcoVisible(b:Boolean):void {
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceTopIcoVisible(b);
		}
		
		public function removieFightStatus():void {
			if(headFace.topMc){
				headFace.removeChild(headFace.topMc);
				headFace.topMc.stop();
				headFace.topMc=null;
			}
		}
		
		public function setHeadFaceBarVisible(b:Boolean):void {
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceBarVisible(b);
		}
		
		public function setHeadFaceNickName(nickName:String="", nickNameColor:uint=0xFFFFFF):void {
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceNickName(nickName, nickNameColor);
		}
		
		public function setHeadFaceCustomTitleHtmlText(customTitle:String=""):void {
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceCustomTitleHtmlText(customTitle);
		}
		
		public function setHeadFaceLeftIco(leftIcon:DisplayObject=null):void {
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceLeftIco(leftIcon);
		}
		
		public function setHeadFaceTopIco(topIcon:DisplayObject=null):void {
			if (headFace == null) {
				showHeadFace();
			}
			if(headFace)
				headFace.setHeadFaceTopIco(topIcon);
		}
		
		public function setHeadFaceTopMc(topMc:MovieClip=null):void {
			if (headFace == null) {
				showHeadFace();
			}
			if(headFace)
				headFace.setHeadFaceTopMc(topMc);
		}
		
		public function setHeadFaceBar(barNow:int, barTotal:int):void {
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceBar(barNow, barTotal);
		}
		
		public function setHeadFaceTalkText(talkText:String="", talkTextColor:uint=0xFFFFFF, 
											talkTimeDelay:int=8000):void {
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceTalkText(talkText, talkTextColor, talkTimeDelay);
		}
		
		public function getHeadFaceNickName():String {
			if (headFace == null) {
				return (name);
			}
			return (headFace.nickName);
		}
		
		public function getHeadFaceNickNameColor():uint {
			if (headFace == null) {
				return (0);
			}
			return (headFace.nickNameColor);
		}
		
		public function showAttackFace(attackType:String="", 
									   attackValue:int=0, selfText:String="",
									   selfFontSize:uint=0, selfFontColor:uint=0):void {
			TaggerHelper.ShowAttackFace(this, attackType, attackValue, selfText, selfFontSize, selfFontColor);
		}
		
		public function getCustomFaceByName(faceName:String):DisplayObject {
			return TaggerHelper.GetCustomFaceByName(this, faceName);
		}
		
		public function addCustomFace(face:DisplayObject):void {
			TaggerHelper.AddCustomFace(this, face);
		}
		
		public function removeCustomFace(face:DisplayObject):void {
			TaggerHelper.RemoveCustomFace(this, face);
		}
		
		public function removeCustomFaceByName(faceName:String):void {
			TaggerHelper.RemoveCustomFaceByName(this, faceName);
		}
		
        public function isMainChar():Boolean {
            return scene != null ? this == scene.mainChar : false;
        }
		
        public function hitPoint(pt:Point):Boolean {
            return avatar.hitPoint(pt);
        }
		
        public function inViewDistance():Boolean {
            return scene == null || scene.sceneCamera.CanSee(this);
        }
		
		public function isJumping():Boolean {
			return Walkdata.isJumping;
		}
		
        public function clearMe():void {
			avatar.clearMe();
        }
		
        public function dispose():void {
            usable = false;
            SceneCache.removeWaitingAvatar(this);
            CCAvatar.recycleAvatar(avatar);
			if (headFace != null) {
				if (headFace.parent) {
					headFace.parent.removeChild(headFace);
				}
				HeadFace.recycleHeadFace(headFace);
			}

			type = -1;
            avatar = null;
			headFace = null;
            scene = null;
            oldMouseRect = null;
            mouseRect = null;
            isSelected = false;
            isMouseOn = false;
            restStatus = RestType.COMMON;
            walkData = null;
			specilizeX = 0;
			specilizeY = 0;
            showIndex = 0;
            showAttack = null;
            visible = true;
            updateNow = false;
            oldData = null;
            data = null;
			
			DisableContainer();
        }
		
        public function reset(value:Array):void {
			// init
            type = value[0];
            scene = value[1];
            TileY = value[3]; // 设置y先，战场中需要
            TileX = value[2];
            showIndex = value[4];
			
            avatar = CCAvatar.createAvatar(this);
			
            if (scene != null) {
                avatar.visible = (this == scene.mainChar) || scene.GetCharAvatarVisible(type);
            }
            oldData = {
                visible:true,
                inViewDistance:false,
                isMouseOn:false,
                isSelected:false,
                pos:new Point(),
				spPos:new Point()
            }
            usable = true;
        }
		
        public function runWalk():void {
            WalkStep.step(this);
        }
		
        public function runAvatar(frame:int=-1):void {
			// 更新 pos
            var px:Number = Math.round(pixelX);
            var py:Number = Math.round(pixelY);
			var pos:Point = oldData['pos'] as Point;
            if (pos.x != px || pos.y != py) {
				pos.x = px;
				pos.y = py;
                updateNow = true;
            }
			
			// 更新 spPos
			px = Math.round(specilizeX);
			py = Math.round(specilizeY);
			var spPos:Point = oldData['spPos'] as Point;
			if (spPos.x != px || spPos.y != py) {
				spPos.x = px;
				spPos.y = py;
				updateNow = true;
			}
			
			// 更新 isMouseOn
            if (oldData['isMouseOn'] != isMouseOn) {
                oldData['isMouseOn'] = isMouseOn;
                updateNow = true;
            }
			
			// 更新 visible
            if (oldData['visible'] != visible) {
                oldData['visible'] = visible;
                updateNow = true;
            }
			
			// 更新 inViewDistance
            var canSee:Boolean = inViewDistance();
            if (oldData['inViewDistance'] != canSee){
                oldData['inViewDistance'] = canSee;
                updateNow = true;
            }
			
            mouseRect = null;
			
			// 调用  avatar.run, 让它继续更新
            avatar.run(frame);
            if (mouseRect != null){
                oldMouseRect = mouseRect.clone();
            }
			
			// 恢复标记
            updateNow = false;
        }
		
        public function drawAvatar(bitmap:IBitmapDrawable):void {
            avatar.draw(bitmap);
        }
    }
}