package cc.helper
{
	import cc.CCCharacter;
	import cc.graphics.tagger.AttackFace;
	import cc.graphics.tagger.HeadFace;
	
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * 角色附加对象助手 (HeadFace, AttackFace)
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class TaggerHelper
	{
        private static var xDis:Number = 100;
        private static var yDis:Number = 70;
        private static var xyDis:Number = ((xDis + yDis) / 2) * Math.cos(Math.PI / 4);
        private static var yDistance:Number = 20;
        private static var duration:Number = 1.2;

		/**
		 * 自定义缓冲函数
		 * 
		 * time：缓动经历过的时间
		 * beforeMove：起始位置
		 * changeDistance：起始位置与目标位置的距离,也就是距离上的一个变化量
		 * duration：我们要求对象从起始位置移动到目标位置所需的时间，也就是缓动的总时长 
		 */		
		private static function myEaseOut(time:Number, beforeMove:Number, changeDistance:Number, 
										  duration:Number, dis:Number=6):Number {
			time = (time / duration) - 1;
			return (changeDistance * (((time * time) * (((dis + 1) * time) + dis)) + 1)) + beforeMove;
		}
		
        public static function ShowHeadFace(sceneChar:CCCharacter, nickName:String="", 
											nickNameColor:uint=0xFFFFFF, customTitle:String="", 
											leftIcon:DisplayObject=null, topIcon:DisplayObject=null):void {
            var headFace:HeadFace;
            if (!sceneChar.usable) {
                return;
            }
			
			// 是主玩家, 或者该类型可见
            var containerVisible:Boolean = sceneChar == sceneChar.scene.mainChar || sceneChar.scene.getCharVisible(sceneChar.type);
			
			// 把  container 添加到 sceneHeadLayer 中
            sceneChar.EnableContainer(sceneChar.scene.sceneHeadLayer, containerVisible);	
			
			// 建立 headFace
            if (sceneChar.headFace == null) {
                headFace = HeadFace.createHeadFace(nickName, nickNameColor, customTitle, leftIcon, topIcon);
                sceneChar.headFace = headFace;
                if (sceneChar.scene.getCharHeadVisible(sceneChar.type)){
                    sceneChar.showContainer.ShowHeadFaceContainer();	// 显示/隐藏
                } else {
                    sceneChar.showContainer.HideHeadFaceContainer();
                }
                sceneChar.showContainer.HeadFaceContainer.addChild(headFace);
            } else {
                headFace = sceneChar.headFace;
                headFace.reset([nickName, nickNameColor, customTitle, leftIcon, topIcon]);
            }
            headFace.x = 0;
            var rect:Rectangle = sceneChar.mouseRect || sceneChar.oldMouseRect;
            headFace.y = rect!=null ? ((rect.y - sceneChar.PixelY) - HeadFace.HEADFACE_SPACE) : HeadFace.DEFAULT_HEADFACE_Y;
        }
		
        public static function ShowAttackFace(sceneChar:CCCharacter, attackType:String="", 
											  attackValue:int=0, selfText:String="",
											  selfFontSize:uint=0, selfFontColor:uint=0):void {
            var attackFace:AttackFace = null;
            var onComplete:Function = null;
			
			// 播放结束后, 删除 attackFace 对象
            onComplete = function ():void{
                if (attackFace.parent){
                    attackFace.parent.removeChild(attackFace);
                }
                AttackFace.recycleAttackFace(attackFace);
            }
            if (!sceneChar.usable){
                return;
            }
			
			// 可见性标志
            var containerVisible:* = (((sceneChar == sceneChar.scene.mainChar)) || (sceneChar.scene.getCharVisible(sceneChar.type)));
            sceneChar.EnableContainer(sceneChar.scene.sceneHeadLayer, containerVisible);
			
			// 建立  attackFace
//            attackFace = AttackFace.createAttackFace(attackType, attackValue, selfText, selfFontSize, selfFontColor);
			attackFace = AttackFace.createAttackFace('', '');
            var mouseRect:Rectangle = sceneChar.mouseRect || sceneChar.oldMouseRect;
            var from:Point = new Point(0, mouseRect != null ? (mouseRect.y - sceneChar.PixelY) + yDistance : (-40 + yDistance));
            var to:Point = from.clone();
            var dir:int = attackFace.dir;
            if (dir == 2){
                to.x = (from.x - xDis);		// 向左
            } else {
                if (dir == 3){
                    to.x = (from.x - xyDis);		// 向左
                    to.y = (from.y - xyDis);		// 向上
                } else {
                    if (dir == 6){
                        to.x = (from.x + xDis);		// 向右
                    } else {
                        to.y = (from.y - yDis);		// 向上
                    }
                }
            }
            attackFace.x = from.x;
            attackFace.y = from.y;
			
			// 显示/隐藏
            if (sceneChar.scene.getCharAvatarVisible(sceneChar.type)){
                sceneChar.showContainer.ShowAttackFaceContainer();
            } else {
                sceneChar.showContainer.HideAttackFaceContainer();
            }
            sceneChar.showContainer.AttackFaceContainer.addChild(attackFace);
			
			// 动画
            TweenLite.to(attackFace, duration, {
                x:to.x,
                y:to.y,
                onComplete:onComplete,
                ease:myEaseOut
            });
        }
		
        public static function GetCustomFaceByName(sceneChar:CCCharacter, faceName:String):DisplayObject {
            if (!sceneChar.usable || !sceneChar.UseContainer) {
                return null;
            }
            var face:DisplayObject = sceneChar.showContainer.CustomFaceContainer.getChildByName(faceName);
			
            return face;
        }
		
        public static function AddCustomFace(sceneChar:CCCharacter, face:DisplayObject):void {
            if (!sceneChar.usable) {
                return;
            }
            var isVisible:Boolean = sceneChar == sceneChar.scene.mainChar || sceneChar.scene.getCharVisible(sceneChar.type);
            sceneChar.EnableContainer(sceneChar.scene.sceneHeadLayer, isVisible);
            if (sceneChar.scene.getCharAvatarVisible(sceneChar.type)) {
                sceneChar.showContainer.ShowCustomFaceContainer();
            } else {
                sceneChar.showContainer.HideCustomFaceContainer();
            }
            sceneChar.showContainer.CustomFaceContainer.addChild(face);
        }
		
        public static function RemoveCustomFace(sceneChar:CCCharacter, face:DisplayObject):void {
            if (!sceneChar.usable || !sceneChar.UseContainer) {
                return;
            }
            if (face.parent) {
                face.parent.removeChild(face);
            }
        }
		
        public static function RemoveCustomFaceByName(sceneChar:CCCharacter, faceName:String):void {
            if (!sceneChar.usable || !sceneChar.UseContainer) {
                return;
            }
            var face:DisplayObject = sceneChar.showContainer.CustomFaceContainer.getChildByName(faceName);
            if (face != null) {
                sceneChar.showContainer.CustomFaceContainer.removeChild(face);
            }
        }
    }
}