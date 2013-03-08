package xy.meditor
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	import mm.fay.layout.HBoxUI;
	import mm.fay.vo.IntGap;
	
	import org.aswing.JButton;
	import org.aswing.JTextField;
	
	public class NPCBar extends Sprite
	{
		public var btn:JButton;
		public var btn2:JButton;
		public var btn3:JButton;
		public var btn4:JButton;
		public var btn5:JButton;
		public var btn6:JButton;
		public var btn_a0:JButton;
		public var btn_a1:JButton;
		public var btn_a2:JButton;
		public var btn_a3:JButton;
		public var btn_a4:JButton;
		public var btn_a5:JButton;
		public var btn_a6:JButton;
		public var btn_a7:JButton;

		public var btn_left:JButton;
		public var btn_center:JButton;
		public var btn_right:JButton;
		
		public var npcText:JTextField;
		public var effec1Text:JTextField;
		public var effec2Text:JTextField;
		public var effec3Text:JTextField;
		public var pathText:JTextField;
		
		public var npc:Object = {};
		public var effect:Object = {};
		public var _avatar:Sprite;
		public var _effect:Sprite;
		
		private static const ANGLE_BUTTON_WIDTH:int = 26;
		
		public function NPCBar()
		{
			super();
			
			var hbox2:HBoxUI = HBoxUI.create(this);
			hbox2.setLocation(0, 28)
				.setGap(new IntGap(4, 4))
				.setSize(414, 30);
			btn = addButton('站立', hbox2);
			btn2 = addButton('跑步', hbox2);
			btn3 = addButton('受伤', hbox2);
			btn4 = addButton('法术攻击', hbox2);
			btn5 = addButton('战斗待机', hbox2);
			btn6 = addButton('攻击', hbox2);
			btn_left = addButton('居左', hbox2);
			btn_center = addButton('居中', hbox2);
			btn_right = addButton('居右', hbox2);
			
			var hbox:HBoxUI = HBoxUI.create(this);
			hbox.setGap(new IntGap(4, 4))
				.setSize(200, 24);
			btn_a0 = addButton('0', hbox, 0, 0, ANGLE_BUTTON_WIDTH);
			btn_a1 = addButton('1', hbox, 0, 0, ANGLE_BUTTON_WIDTH);
			btn_a2 = addButton('2', hbox, 0, 0, ANGLE_BUTTON_WIDTH);
			btn_a3 = addButton('3', hbox, 0, 0, ANGLE_BUTTON_WIDTH);
			btn_a4 = addButton('4', hbox, 0, 0, ANGLE_BUTTON_WIDTH);
			btn_a5 = addButton('5', hbox, 0, 0, ANGLE_BUTTON_WIDTH);
			btn_a6 = addButton('6', hbox, 0, 0, ANGLE_BUTTON_WIDTH);
			btn_a7 = addButton('7', hbox, 0, 0, ANGLE_BUTTON_WIDTH);
			
			npcText = addText('', this, 120, 24, 250, 0);
			pathText = addText('f:/', this, 378, 24, 0, -28);
		}
		
		///////////////////////////////////
		// private methods
		///////////////////////////////////
		
		private function addText(name:String, parent:DisplayObjectContainer=null, pw:Number=150, ph:Number=28, xPos:Number=0, yPos:Number=0):JTextField
		{
			var eText:JTextField = new JTextField(name);
			eText.name = name;
			eText.setSizeWH(pw, ph);
			eText.setX(xPos);
			eText.setY(yPos);
			if (parent != null) {
				parent.addChild(eText);
			}
			return eText;
		}
		
		private function addButton(text:String='', parent:DisplayObjectContainer=null, xPos:int=0, yPos:int=0, w:int=60):JButton
		{
			var button:JButton = new JButton(text);
			button.setSizeWH(w, 24);
			button.setX(xPos);
			button.setY(yPos);
			if (parent != null) parent.addChild(button);
			
//			button.addEventListener(MouseEvent.CLICK, __onMouseDown);
			return button;
		}
	}
}