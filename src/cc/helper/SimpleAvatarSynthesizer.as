package cc.helper
{
	import cc.CCCharacter;
	import cc.define.CharType;
	import cc.define.StaticData;
	import cc.graphics.avatar.CCAvatarPart;
	import cc.vo.avatar.AvatarParamData;
	import cc.vo.avatar.AvatarPlayCondition;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * 纸娃娃合成 
	 */	
    public class SimpleAvatarSynthesizer
	{
        public static function synthesisSimpleAvatar(id:*, callBack:Function, apdArr:Array, 
													 frame:int=1, charStatus:String="stand", charLogicAngle:int=0, 
													 maxBDWidth:Number=0x0200, maxBDHeight:Number=0x0200):void {
            var totalNum:int = 0;
            var loadedNum:int = 0;
            var sc:CCCharacter = null;
            var apd:AvatarParamData = null;
            var onAvatarPartAdd:Function = null;
            onAvatarPartAdd = function (sceneChar:CCCharacter=null, part:CCAvatarPart=null):void
			{
                var tmpBMD:BitmapData;
                var rect:Rectangle;
                var targetBMD:BitmapData;
                loadedNum++;
                if (loadedNum <= totalNum) {
                    tmpBMD = new BitmapData(maxBDWidth, maxBDHeight, true, 0);
                    sc.playTo(charStatus, charLogicAngle, -1, new AvatarPlayCondition(true));
                    sc.runAvatar(frame);
                    sc.drawAvatar(tmpBMD);
                    rect = tmpBMD.getColorBoundsRect(4278190080, 0, false);
                    rect.x = 0;
                    rect.width = maxBDWidth;
                    if (rect.width > 0 && rect.height > 0) {
                        targetBMD = new BitmapData(rect.width, rect.height, true, 0);
                        targetBMD.copyPixels(tmpBMD, rect, new Point(0, 0), null, null, true);
                    }
                    callBack(id, targetBMD);
                }
                if (loadedNum == totalNum) {
                    CCCharacter.recycleSceneCharacter(sc);
                }
            }
            totalNum = apdArr.length;
            loadedNum = 0;
            sc = CCCharacter.createSceneCharacter(CharType.PLAYER, null);
            for each (apd in apdArr) {
                apd = apd.clone();
                apd.vars = null;
                apd.useType = 0;
                apd.clearSameType = false;
                apd.extendCallBack(null, null, null, null, onAvatarPartAdd);
                sc.loadAvatarPart(apd);
            }
        }
    }
}