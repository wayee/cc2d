package cc.events
{
	/**
	 * 场景事件动作 - 移动类型
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class CCEventActionWalk
	{
        public static const READY:String = "CCEventActionWalk.READY";						// 预备
        public static const THROUGH:String = "CCEventActionWalk.THROUGH";					// 经过
        public static const ARRIVED:String = "CCEventActionWalk.ARRIVED";					// 到达
        public static const UNABLE:String = "CCEventActionWalk.UNABLE";					// 不能到达
        public static const JUMP_READY:String = "CCEventActionWalk.JUMP_READY";			// 准备起跳
        public static const JUMP_THROUGH:String = "CCEventActionWalk.JUMP_THROUGH";		// 跳过
        public static const JUMP_ARRIVED:String = "CCEventActionWalk.JUMP_ARRIVED";		// 跳跃完成
        public static const JUMP_UNABLE:String = "CCEventActionWalk.JUMP_UNABLE";			// 不能跳过
        public static const ON_TRANSPORT:String = "CCEventActionWalk.ON_TRANSPORT";		// 到达传送点
        public static const SEND_PATH:String = "CCEventActionWalk.SEND_PATH";				// 发送路径
        public static const SEND_JUMP_PATH:String = "CCEventActionWalk.SEND_JUMP_PATH";	// 发送跳跃路径
    }
}