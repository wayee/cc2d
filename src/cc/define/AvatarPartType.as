package cc.define
{
    public class AvatarPartType
	{
        public static var BODY:String = "body";					// 身体
        public static var WEAPON:String = "weapon";				// 武器
        public static var MOUNT:String = "mount";					// 坐骑
        public static var MAGIC:String = "magic";					// 法术
        public static var MAGIC_PASS:String = "magic_pass";		// 弹道
        public static var WING:String = "wing";					// 翅膀

        private static const defautDepthArr:Array = [[MOUNT, -21], [WING, -11], [BODY, 0], [WEAPON, 21], [MAGIC, 31], [MAGIC_PASS, 30]];
		
		/**
		 * 返回类型对应的深度
		 */
        public static function GetDefaultDepth(PartType:String):int {
			var arr:Array;
			for each (arr in defautDepthArr) {
				if (arr[0] == PartType) {
					return arr[1];
				}
			}
			return 0;
        }
    }
}