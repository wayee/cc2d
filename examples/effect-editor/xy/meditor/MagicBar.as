package xy.meditor
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	import mm.fay.layout.HBoxUI;
	import mm.fay.layout.VBoxUI;
	import mm.fay.vo.IntGap;
	
	import org.aswing.JButton;
	import org.aswing.JCheckBox;
	import org.aswing.JLabel;
	import org.aswing.JTextField;
	
	public class MagicBar extends Sprite
	{
		public var btnLoad:JButton;
		public var btnLoadConfig:JButton;
		public var btnSaveConfig:JButton;
		public var btnClearList:JButton;
		public var txtPath:JTextField;
		public var txtFileName:JTextField;
		public var dirChk:JCheckBox;
		public var effectVBox:VBoxUI;
		public var effDict:Dictionary;
		public var voDict:Dictionary;
		
		public function MagicBar()
		{
			super();
			effDict = new Dictionary;
			voDict = new Dictionary;
			
			btnLoad = addButton("展示特效", -250, 238, 60);
			btnSaveConfig = addButton("保存特效", -190, 238, 60);
			btnLoadConfig = addButton("加载配置", -130, 238, 60);
			btnClearList = addButton("清除列表", -70, 238, 60);
			txtPath = addText("effectPath", this, "f:/", 208, 24, -250, 212);
			txtFileName = addText("txtFileName", this, "...", 150, 24, -180, 184);
//			txtFileName.setEditable(false);
			dirChk = new JCheckBox("有方向");
			dirChk.name = "direction";
			dirChk.setSizeWH(70, 24);
			dirChk.setLocationXY(-250, 184);
			addChild(dirChk);
			
			var label:JLabel = new JLabel('特效id,位移x,位移y,缩放x,缩放y,旋转,延迟秒');
			label.setSizeWH(254, 24);
//			label.setLocationXY(0, 0);
			addChild(label);
			effectVBox = VBoxUI.create(this);
			effectVBox.setSize(250, 480)
					.setLocation(0, 30)
					.setGap(new IntGap(0, 0));
			createEffect('', 1);
			createEffect('', 2);
			createEffect('', 3);
			createEffect('', 4);
			createEffect('', 5);
			createEffect('', 6);
			createEffect('', 7);
			createEffect('', 8);
//			createEffect('107', 1);
//			createEffect('108', 2);
//			createEffect('305', 3);
//			createEffect('212', 4);
//			createEffect('201', 5);
//			createEffect('202', 6);
//			createEffect('101', 7);
//			createEffect('301', 8);
		}
		
		public function updateVo():void
		{
			var c:Comp;
			var t:JTextField;
			for (var key:String in voDict) {
				c = voDict[key] as Comp;
				c.magicId = String(getT(key, "magic"));
				c.magicName = "effect" + String(getT(key, "magic"));
				c.compName = key;
				c.offsetX = Number(getT(key, "offsetX"));
				c.offsetY = Number(getT(key, "offsetY"));
				c.scaleX = Number(getT(key, "scaleX"));
				c.scaleY = Number(getT(key, "scaleY"));
				c.rotation = int(getT(key, "rotation")); 
				c.delay = Number(getT(key, "delay"));
				c.flipH = getCheck(key, "flipH");
			}
		}
		
		public function updateTextField(magic:XML):void
		{
			setT(magic.comp, "magic", magic.id)
			setT(magic.comp, "offsetX", magic.offsetX)
			setT(magic.comp, "offsetY", magic.offsetY)
			setT(magic.comp, "scaleX", magic.scaleX)
			setT(magic.comp, "scaleY", magic.scaleY)
			setT(magic.comp, "rotation", magic.rotation)
			setT(magic.comp, "delay", magic.delay)
//			setT(magic.comp, "flipH", magic.flipH)
		}
		
		public function clearEffectList():void
		{
			for each (var hbox:HBoxUI in effDict) {
				(hbox.getChildByName("magic") as JTextField).setText("");
				(hbox.getChildByName("offsetX") as JTextField).setText("0");
				(hbox.getChildByName("offsetY") as JTextField).setText("0");
				(hbox.getChildByName("scaleX") as JTextField).setText("1");
				(hbox.getChildByName("scaleY") as JTextField).setText("1");
				(hbox.getChildByName("rotation") as JTextField).setText("0");
				(hbox.getChildByName("delay") as JTextField).setText("0");
			}
			
			updateFileName("");
		}
		
		public function updateFileName(text:String):void
		{
			if (text != "") text = "特效 " + text;
			txtFileName.setText(text);
		}
		
		public function updateDirection(dir:String):void
		{
			dirChk.setSelected( int(dir) == 1);
		}
		
		public function getComp(magicComName):Comp
		{
			updateVo();
			return voDict[magicComName] as Comp;
		}
		
		public function getT(magicComName:String, name:String):String
		{
			var h:HBoxUI = effDict[magicComName] as HBoxUI;
			return (h.getChildByName(name) as JTextField).getText();
		}
		
		public function setT(magicComName:String, textName:String, text:String):void
		{
			try {
				var h:HBoxUI = effDict[magicComName] as HBoxUI;
				(h.getChildByName(textName) as JTextField).setText(text);
			} catch (e:Error) {
				trace(e.message);
			}
		}
		
		public function getCheck(key:String, name:String):Boolean
		{
			var h:HBoxUI = effDict[key] as HBoxUI;
			return (h.getChildByName(name) as JCheckBox).isSelected();
		}
		
		public function getDirection():Boolean
		{
			return dirChk.isSelected();
		}
		
		private function createEffect(effectId:String, idx:int):void
		{
			var hbox:HBoxUI = HBoxUI.create(effectVBox);
			hbox.setSize(250, 30);
			
			var name:String = "magic";
			addText(name, hbox, effectId, 40);

			addText("offsetX", hbox, "0", 40);
			addText("offsetY", hbox, "0", 40);
			addText("scaleX", hbox, "1", 32);
			addText("scaleY", hbox, "1", 32);
			addText("rotation", hbox, "0", 40);
			addText("delay", hbox, "0", 32);
//			addText("flipH", hbox, "0", 20);
			
			var flipH:JCheckBox = new JCheckBox("水平翻转");
			flipH.name = "flipH";
			flipH.setSizeWH(70, 24);
			hbox.addChild(flipH);
			flipH.visible = false;
			
			effectVBox.addChild(hbox);
			
			var magicTextName:String = name + idx; // magic1, magic2, ...
			effDict[magicTextName] = hbox;
			voDict[magicTextName] = new Comp;
		}
		
		private function addText(name:String, parent:DisplayObjectContainer=null, defaualtValue:String="", pw:Number=70, ph:Number=28, xPos:Number=0, yPos:Number=0):JTextField
		{
			var eText:JTextField = new JTextField(defaualtValue);
			eText.name = name;
			eText.setSizeWH(pw, ph);
			eText.setX(xPos);
			eText.setY(yPos);
			if (parent != null) {
				parent.addChild(eText);
			}
			
			return eText;
		}
		
		private function addButton(text:String='', xPos:int=0, yPos:int=0, w:int=60, h:int=24):JButton
		{
			var button:JButton = new JButton(text);
			button.setSizeWH(w, h);
			button.setX(xPos);
			button.setY(yPos);
			addChild(button);
			//			button.addEventListener(MouseEvent.CLICK, __onMouseDown);
			
			return button;
		}
	}
}