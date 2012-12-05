package cc.define
{
    public class AvatarPartID
	{
        public static const BLANK:String = "BLANK";						// 空形象
        public static const BORN:String = "BORN";						// 裸模
        public static const BORN_ONMOUNT:String = "BORN_ONMOUNT";		// 骑坐骑形象
        public static const BORN_MOUNT:String = "BORN_MOUNT";			// 坐骑
        public static const SHADOW:String = "SHADOW";					// 影子
        public static const SELECTED:String = "SELECTED";				// 选中
        public static const MOUSE:String = "MOUSE";						// 鼠标

		/**
		 * 判断是否合法ID, 要求 非保留关键字
		 */
        public static function IsValidID(id:String):Boolean {
			if (id == null || id == "" || IsDefaultKey(id)) {
				return false;
			}
			return true;
        }
		
		/**
		 * 保留关键字
		 */
		public static function IsDefaultKey(id:String):Boolean {
			if (id == BLANK || id == BORN || id == BORN_ONMOUNT || id == BORN_MOUNT ||
				id == SHADOW || id == SELECTED || id == MOUSE) {
				return true;
			}
			return false;
		}
    }
}