package cc
{
	import flash.display.Sprite;

	/**
	 * 人物附加对象管理
	 * <li> 血条、昵称、称号和对话文字等
	 * <li> 攻击的文字
	 * <li> 自定义图标
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class CCHead extends Sprite
	{
		private var headFaceContainer:Sprite;								// 血条、昵称和称号等容器
		private var isShowHeadFaceContainer:Boolean = true;
		
		private var attackFaceContainer:Sprite;								// 攻击文字容器
		private var isShowAttackFaceContainer:Boolean = true;
		
		private var customFaceContainer:Sprite;								// 自定义图标容器
		private var isShowCustomFaceContainer:Boolean = true;
		
		public function get HeadFaceContainer():Sprite {
			if (headFaceContainer == null) {
				headFaceContainer = new Sprite();
				if (isShowHeadFaceContainer) {
					ShowHeadFaceContainer();
				}
			}
			return headFaceContainer;
		}
		
		public function ShowHeadFaceContainer():void {
			isShowHeadFaceContainer = true;
			if (headFaceContainer != null && headFaceContainer.parent != this) {
				addChild(headFaceContainer);
			}
		}

		public function HideHeadFaceContainer():void {
			isShowHeadFaceContainer = false;
			if (headFaceContainer != null && headFaceContainer.parent != null) {
				headFaceContainer.parent.removeChild(headFaceContainer);
			}
		}
		
		public function get AttackFaceContainer():Sprite {
			if (attackFaceContainer == null) {
				attackFaceContainer = new Sprite();
				if (isShowAttackFaceContainer) {
					ShowAttackFaceContainer();
				}
			}
			return attackFaceContainer;
		}
		
		public function ShowAttackFaceContainer():void {
			isShowAttackFaceContainer = true;
			if (attackFaceContainer != null && attackFaceContainer.parent != this) {
				addChild(attackFaceContainer);
			}
		}
		
		public function HideAttackFaceContainer():void {
			isShowAttackFaceContainer = false;
			if (attackFaceContainer != null && attackFaceContainer.parent != null) {
				attackFaceContainer.parent.removeChild(attackFaceContainer);
			}
		}
		
		public function get CustomFaceContainer():Sprite {
			if (customFaceContainer == null) {
				customFaceContainer = new Sprite();
				if (isShowCustomFaceContainer) {
					ShowCustomFaceContainer();
				}
			}
			return customFaceContainer;
		}
		
		public function ShowCustomFaceContainer():void {
			isShowCustomFaceContainer = true;
			if (customFaceContainer != null && customFaceContainer.parent != this) {
				addChild(customFaceContainer);
			}
		}
		
		public function HideCustomFaceContainer():void {
			isShowCustomFaceContainer = false;
			if (customFaceContainer != null && customFaceContainer.parent != null) {
				customFaceContainer.parent.removeChild(customFaceContainer);
			}
		}
	}
}