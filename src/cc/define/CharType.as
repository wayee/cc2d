package cc.define
{
    public class CharType
	{
        public static const DUMMY:int = 0;				// 虚拟物体，如弹道
        public static const PLAYER:int = 1;				// 玩家
        public static const MONSTER:int = 2;			// 怪物
        public static const MOUNT:int = 3;				// 坐骑
        public static const NPC_FRIEND:int = 4;			// 其他玩家
        public static const PET:int = 5;				// 宠物
        public static const NPC:int = 6;				// NPC
        public static const TRANSPORT:int = 7;			// 传送点
        public static const BAG:int = 11;				// 袋子
		
        private static const defautDepthArr:Array = [[BAG, (-(int.MAX_VALUE) + 1)], [TRANSPORT, -(int.MAX_VALUE)]];

        public static function GetDefaultDepth(charType:int):int {
            var arr:Array;
            for each (arr in defautDepthArr) {
                if (arr[0] == charType) {
                    return arr[1];
                }
            }
            return 0;
        }
    }
}