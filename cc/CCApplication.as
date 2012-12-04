package cc
{
	import flash.display.Sprite;
	
	/**
	 * 编码规范：
	 * - 类名首字母大写
	 * - 私有变量和方法使用首字母小写
	 * - 公开变量和方法使用首字母大写
	 * - 回调方法（函数）使用 "on"为前缀，如 onClickButton
	 * - 引擎核心类都使用 "CC" 为前缀
	 * - 参数使用前缀 "p_"
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class CCApplication extends Sprite
	{
		public function CCApplication() {
			super();
		}
	}
}