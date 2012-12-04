package cc.graphics.tagger
{
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import cc.tools.ScenePool;
	import wit.pool.IPoolObject;
	
	/**
	 * 攻击时, 血量获得/丢失, 接/交人物, 等的文字显示
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class AttackTextFace extends Sprite implements IPoolObject
	{
		public static const ATTACK_SPECIAL_EFFECT:String = "ae.aSpecialEffect";
		public static const ATTACK_CRITICALHIT:String = "ae.aCriticalHit";
		public static const ATTACK_CRITICALHIT_FROM_MOUNT:String = "ae.aCriticalHitFromMount";
		public static const ATTACK_ZHIMING:String = "ae.aZhiming";
		public static const ATTACK_MISS:String = "ae.aMiss";
		public static const ATTACK_LOSE:String = "ae.aLose";
		public static const ATTACK_LOSE_FROM_MOUNT:String = "ae.aLoseHitFromMount";
		public static const ATTACK_JUMPMISS:String = "ae.aJumpMiss";
		public static const ATTACK_ANQI_JUMPMISS:String = "ae.ATTACK_ANQI_JUMPMISS";
		public static const LOOK_ME_ANQI:String = "ae.LOOK_ME_ANQI";
		public static const ZUHEJI:String = "ae.ZUHEJI";
		
		// MP(普通/他人/他人马/暗器), PP, GP, EXP, PRESTIGE/威望, ENERGY/能量
		public static const CHANGE_HP:String = "ae.cHp";
		public static const CHANGE_HP_OTHER:String = "ae.cHpOther";
		public static const CHANGE_HP_OTHER_FROM_MOUNT:String = "ae.cHpOtherFromMount";
		public static const CHANGE_HP_ANQI:String = "ae.CHANGE_HP_ANQI";
		public static const CHANGE_MP:String = "ae.cMp";
		public static const CHANGE_PP:String = "ae.cPp";
		public static const CHANGE_GP:String = "ae.cGp";
		public static const CHANGE_EXP:String = "ae.cExp";
		public static const CHANGE_PRESTIGE:String = "ae.cPrestige";
		public static const CHANGE_ENERGY:String = "ae.cEnergy";
		
		// HP, MP, PP, AP, DP, CP, EV, ADX, MDX
		public static const MAX_HP:String = "ae.mHp";
		public static const MAX_MP:String = "ae.mMp";
		public static const MAX_PP:String = "ae.mPp";
		public static const MAX_AP:String = "ae.mAp";
		public static const MAX_DP:String = "ae.mDp";
		public static const MAX_CP:String = "ae.mCp";
		public static const MAX_EV:String = "ae.mEv";
		public static const MAX_ADX:String = "ae.mAdx";
		public static const MAX_MDX:String = "ae.mMdx";
		
		// 他人: 升级, 自动寻径, 自动挂机, 接任务, 交任务, 战绩?, 连战
		public static const OTHERS_LEVEL_UP:String = "ae.oLevelUp";
		public static const OTHERS_AUTO_SEARCH_PATH:String = "ae.oAutoSearchPath";
		public static const OTHERS_AUTO_AFK:String = "ae.oAutoAfk";
		public static const OTHERS_TASK_ACCEPT:String = "ae.oTaskAccept";
		public static const OTHERS_TASK_HANDIN:String = "ae.oTaskHandIn";
		public static const OTHERS_ZHAN_JI:String = "ae.OTHERS_ZHAN_JI";
		public static const OTHERS_LIANZHAN:String = "ae.OTHERS_LIANZHAN";
		
		private static const FOUNT_OFFSET:int = 13;
		public static const DEFAULT_FOUNT_SIZE_4:int = 17;
		public static const DEFAULT_FOUNT_SIZE_5:int = 18;
		public static const DEFAULT_FOUNT_SIZE_14:int = 27;
		public static const DEFAULT_FOUNT_SIZE_15:int = 28;
		public static const DEFAULT_FOUNT_SIZE_16:int = 29;
		public static const DEFAULT_FOUNT_SIZE_18:int = 31;
		public static const DEFAULT_FOUNT_SIZE_20:int = 33;
		public static const DEFAULT_FOUNT_SIZE_22:int = 35;
		public static const DEFAULT_FOUNT_SIZE_24:int = 37;
		public static const DEFAULT_FOUNT_SIZE_26:int = 39;
		
		public static const DEFAULT_FOUNT_COLOR_RED:int = 0xFF0000;
		public static const DEFAULT_FOUNT_COLOR_BLUE:int = 2003199;
		public static const DEFAULT_FOUNT_COLOR_YELLOW:int = 0xFFFF00;
		public static const DEFAULT_FOUNT_COLOR_GREEN:int = 0xFF00;
		public static const DEFAULT_FOUNT_COLOR_PURPLE:int = 10040314;
		public static const DEFAULT_FOUNT_COLOR_WHITE:int = 0xFFFFFF;
		public static const DEFAULT_FOUNT_COLOR_ORANGE:int = 0xFF8A00;
		
		
		/**
		 * 发光效果, 
		 * color = 0x484848;			// 颜色, 中灰色
		 * alpha = 0.5;					// 透明度, 0.5
		 * blurX = 4;					// 模糊量, 4像素
		 * blurY = 4;
		 * strength = 8;				// 强度, [0-255], 值越高颜色越深
		 * inner = false				// 内发光
		 * knockout = false;			// 镂空
		 */
		private static const filterArr:Array = [new GlowFilter(0x484848, 0.5, 4, 4, 8, BitmapFilterQuality.LOW)];
		private static const DEFAULT_FOUNT_SIZE:int = 16;
		
		private var tf:TextField;
		private var _type:String = "";
		private var _value:int = 0;
		private var _text:String = "";
		private var _fontSize:uint = 16;
		private var _fontColor:uint = 0;
		private var _dir:int = 4;				// 运动方向
		
		/**
		 * 构造函数
		 * @param type 类型, 常量定义
		 * @param value 伤害值
		 * @param 
		 */
		public function AttackTextFace(type:String="", value:int=0, prefix:String="", fontSize:uint=0, fontColor:uint=0)
		{
			tf = new TextField();
			tf.autoSize = TextFormatAlign.LEFT;
			tf.mouseEnabled = false;
			tf.filters = filterArr;
			reset([type, value, prefix, fontSize, fontColor]);
		}
		
		// 建立
		public static function createAttackFace(attackType:String="", 
												attackValue:int=0, selfText:String="",
												selfFontSize:uint=0, selfFontColor:uint=0):AttackFace
		{
			return ScenePool.attackFacePool.createObj(AttackFace, attackType, attackValue, selfText, selfFontSize, selfFontColor) as AttackFace;
		}
		
		// 释放并备用
		public static function recycleAttackFace(af:AttackFace):void
		{
			ScenePool.attackFacePool.disposeObj(af);
		}
		
		public function get dir():int
		{
			return _dir;
		}
		
		public function dispose():void
		{
			_type = "";
			_value = 0;
			_text = "";
			_fontSize = DEFAULT_FOUNT_SIZE;
			_fontColor = 0;
			_dir = 4;
		}
		
		public function reset(value:Array):void
		{
			_type = value[0];
			_value = value[1];
			var prefix:String = value[2];
			var fontSize:uint = value[3];
			var fontColor:uint = value[4];
			var text:String = "";
			switch (_type) {
				
				case ATTACK_SPECIAL_EFFECT:
					_fontSize = DEFAULT_FOUNT_SIZE_20;
					_fontColor = DEFAULT_FOUNT_COLOR_RED;
					break;
				
				// 攻击: 红色, 20
				case ATTACK_CRITICALHIT:
					if (_value > 0){
						text = (" +" + _value);			// " +100"
					} else {
						text = (" " + _value);				// " -100"
					}
					_fontSize = DEFAULT_FOUNT_SIZE_20;
					_fontColor = DEFAULT_FOUNT_COLOR_RED;
					break;
				
				// 马攻击: 红色, 15
				case ATTACK_CRITICALHIT_FROM_MOUNT:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = (" " + _value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_15;
					_fontColor = DEFAULT_FOUNT_COLOR_RED;
					break;
				// 致命: 黄色, 20
				case ATTACK_ZHIMING:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = (" " + _value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_20;
					_fontColor = DEFAULT_FOUNT_COLOR_YELLOW;
					break;
				// 闪避: 绿色, 18
				case ATTACK_MISS:
					_fontSize = DEFAULT_FOUNT_SIZE_18;
					_fontColor = DEFAULT_FOUNT_COLOR_GREEN;
					_dir = 2;
					break;
				// 损失: 蓝色, 18
				case ATTACK_LOSE:
					_fontSize = DEFAULT_FOUNT_SIZE_18;
					_fontColor = DEFAULT_FOUNT_COLOR_BLUE;
					_dir = 6;
					break;
				// 马损失: 蓝色, 15
				case ATTACK_LOSE_FROM_MOUNT:
					_fontSize = DEFAULT_FOUNT_SIZE_15;
					_fontColor = DEFAULT_FOUNT_COLOR_BLUE;
					_dir = 6;
					break;
				// 跳跃闪避: 绿色, 18
				case ATTACK_JUMPMISS:
					_fontSize = DEFAULT_FOUNT_SIZE_18;
					_fontColor = DEFAULT_FOUNT_COLOR_GREEN;
					_dir = 2;
					break;
				// 暗器跳跃闪避: 红色, 15
				case ATTACK_ANQI_JUMPMISS:
					_fontSize = DEFAULT_FOUNT_SIZE_15;
					_fontColor = DEFAULT_FOUNT_COLOR_RED;
					_dir = 2;
					break;
				// 看招: 红色, 15
				case LOOK_ME_ANQI:
					_fontSize = DEFAULT_FOUNT_SIZE_15;
					_fontColor = DEFAULT_FOUNT_COLOR_RED;
					_dir = 2;
					break;
				// 组合技: 绿色, 15
				case ZUHEJI:
					_fontSize = DEFAULT_FOUNT_SIZE_15;
					_fontColor = DEFAULT_FOUNT_COLOR_GREEN;
					_dir = 2;
					break;
				// 血量修改: 红色, 16
				case CHANGE_HP:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = String(_value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_16;
					_fontColor = DEFAULT_FOUNT_COLOR_RED;
					break;
				// 他人血量修改: 白色, 16
				case CHANGE_HP_OTHER:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = String(_value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_16;
					_fontColor = DEFAULT_FOUNT_COLOR_WHITE;
					break;
				case CHANGE_HP_OTHER_FROM_MOUNT:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = String(_value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_4;
					_fontColor = DEFAULT_FOUNT_COLOR_WHITE;
					break;
				case CHANGE_HP_ANQI:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = (" " + String(_value));
					}
					_fontSize = DEFAULT_FOUNT_SIZE_14;
					_fontColor = DEFAULT_FOUNT_COLOR_ORANGE;
					break;
				case CHANGE_MP:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = String(_value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_14;
					_fontColor = DEFAULT_FOUNT_COLOR_BLUE;
					break;
				case CHANGE_PP:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = String(_value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_14;
					_fontColor = DEFAULT_FOUNT_COLOR_YELLOW;
					break;
				case CHANGE_GP:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = (" " + _value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_16;
					_fontColor = DEFAULT_FOUNT_COLOR_PURPLE;
					break;
				case CHANGE_EXP:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = (" " + _value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_16;
					_fontColor = DEFAULT_FOUNT_COLOR_YELLOW;
					break;
				case CHANGE_PRESTIGE:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = (" " + _value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_16;
					_fontColor = DEFAULT_FOUNT_COLOR_PURPLE;
					break;
				case CHANGE_ENERGY:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = String(_value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_5;
					_fontColor = DEFAULT_FOUNT_COLOR_GREEN;
					break;
				case MAX_HP:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = (" " + _value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_16;
					_fontColor = DEFAULT_FOUNT_COLOR_RED;
					break;
				case MAX_MP:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = (" " + _value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_16;
					_fontColor = DEFAULT_FOUNT_COLOR_BLUE;
					break;
				case MAX_PP:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = (" " + _value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_16;
					_fontColor = DEFAULT_FOUNT_COLOR_YELLOW;
					break;
				case MAX_AP:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = (" " + _value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_16;
					_fontColor = DEFAULT_FOUNT_COLOR_YELLOW;
					break;
				case MAX_DP:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = (" " + _value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_16;
					_fontColor = DEFAULT_FOUNT_COLOR_YELLOW;
					break;
				case MAX_CP:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = (" " + _value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_16;
					_fontColor = DEFAULT_FOUNT_COLOR_YELLOW;
					break;
				case MAX_EV:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = (" " + _value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_16;
					_fontColor = DEFAULT_FOUNT_COLOR_YELLOW;
					break;
				case MAX_ADX:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = (" " + _value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_16;
					_fontColor = DEFAULT_FOUNT_COLOR_GREEN;
					break;
				case MAX_MDX:
					if (_value > 0){
						text = (" +" + _value);
					} else {
						text = (" " + _value);
					}
					_fontSize = DEFAULT_FOUNT_SIZE_16;
					_fontColor = DEFAULT_FOUNT_COLOR_GREEN;
					break;
				case OTHERS_LEVEL_UP:
					_fontSize = DEFAULT_FOUNT_SIZE_20;
					_fontColor = DEFAULT_FOUNT_COLOR_YELLOW;
					break;
				case OTHERS_AUTO_SEARCH_PATH:
					_fontSize = DEFAULT_FOUNT_SIZE_20;
					_fontColor = DEFAULT_FOUNT_COLOR_YELLOW;
					break;
				case OTHERS_AUTO_AFK:
					_fontSize = DEFAULT_FOUNT_SIZE_20;
					_fontColor = DEFAULT_FOUNT_COLOR_YELLOW;
					break;
				case OTHERS_TASK_ACCEPT:
					_fontSize = DEFAULT_FOUNT_SIZE_20;
					_fontColor = DEFAULT_FOUNT_COLOR_YELLOW;
					break;
				case OTHERS_TASK_HANDIN:
					_fontSize = DEFAULT_FOUNT_SIZE_20;
					_fontColor = DEFAULT_FOUNT_COLOR_YELLOW;
					break;
				case OTHERS_ZHAN_JI:
					_fontSize = DEFAULT_FOUNT_SIZE_20;
					_fontColor = DEFAULT_FOUNT_COLOR_YELLOW;
					break;
				case OTHERS_LIANZHAN:
					_fontSize = DEFAULT_FOUNT_SIZE_20;
					_fontColor = DEFAULT_FOUNT_COLOR_YELLOW;
					break;
			}
			_text = (prefix + text);
			if (fontSize != 0) {
				_fontSize = fontSize;
			}
			if (fontColor != 0) {
				_fontColor = fontColor;
			}
			if (_text != "") {
				tf.text = _text;
				tf.setTextFormat(new TextFormat("楷体", _fontSize, _fontColor));
				tf.x = (-(tf.width) / 2);
				tf.y = (-(tf.height) / 2);
				if (tf.parent != this){
					addChild(tf);
				}
			} else {
				tf.text = "";
			}
		}
	}
}