package xy.meditor
{
	import cc.define.CharStatusType;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mm.fay.layout.HBoxUI;
	
	import org.aswing.ASColor;
	import org.aswing.AsWingManager;
	import org.aswing.JButton;
	import org.aswing.JLabel;
	import org.aswing.JTextField;
	
	import wit.event.BaseEvent;
	
	public class MEditor extends Sprite
	{
		public var magicBar:MagicBar;
		public var npcBar:NPCBar;
		
		private var curStatus:String = CharStatusType.STAND;
		private var curAngle:int = 0;
		private var npcs:Object = {};
		private var magics:Object = {};
		private var resourePath:String = "./"
		private var resoureMagicPath:String = "./"
		private var magicLen:int = TOTAL_MAGIC;	// total magics
		private var handlerNum:int = 1;
		private var offsetText:JLabel;
		private var tfOffsetX:JTextField;
		private var tfOffsetY:JTextField;
		private var fileReader:FileReference;
		private var fileWriter:FileReference;
		
		private static const DEFAULT_EXPORTING_FILE_NAME:String = "effect1.xml";
//		private static const TARGET_X:int = 580;
//		private static const TARGET_Y:int = 450;
		private static const TARGET_X:int = 658;
		private static const TARGET_Y:int = 436;
		private static const TOTAL_MAGIC:int = 8;	// 同时支持特效个数
		
		public static const EVENT_SHOW_NPC:String = "event_show_npc";
		public static const EVENT_SHOW_MAGICS:String = "event_show_magics";
		
		public function MEditor()
		{
			//
		}
		
		public function init():void
		{
			AsWingManager.initAsStandard(this);
//			UIManager.setLookAndFeel(new YiTongLNF);
			
			// 特效编辑菜单
			magicBar = new MagicBar;
			magicBar.x = 942;
			magicBar.y = 530;
			addChild(magicBar);
			
			// 人物编辑菜单
			npcBar = new NPCBar;
			npcBar.y = 740;
			addChild(npcBar);
			
			npcBar.addEventListener(MouseEvent.CLICK, __onMouseDown);
			magicBar.addEventListener(MouseEvent.CLICK, __onMouseDown);

			offsetText = new JLabel("0, 0");
			offsetText.setSizeWH(80, 24);
			offsetText.setForeground(ASColor.WHITE);
			addChild(offsetText);
			
			this.addEventListener(Event.ENTER_FRAME, __onEnterFrame);
			this.stage.addEventListener(MouseEvent.CLICK, __onStageMouseDown);
			
			fileWriter = new FileReference;
			fileReader = new FileReference;
			
			fileReader.addEventListener(Event.SELECT, __onSelectFile);
			fileReader.addEventListener(Event.CANCEL, __onSelectFile);
			fileReader.addEventListener(Event.COMPLETE, __onCompleteLoadConf);
			
			fileWriter.addEventListener(Event.COMPLETE, __onCompleteSaveConf);
		}

		private function getNpcPath():String
		{
			var path:String;
			if (npcBar.pathText.getText() != "f:/" || npcBar.pathText.getText()  == '') {
				path =  npcBar.pathText.getText() + "/";
			} else {
				path = resourePath;
			}
			return path;
		}
		
		///////////////////////////////////
		// 法术特效私有方法
		///////////////////////////////////
		
		private function getMagicPath():String
		{
			var path:String;
			if (magicBar.txtPath.getText() != "f:/" || magicBar.txtPath.getText() == '') {
				path =  magicBar.txtPath.getText() + "/";
			} else {
				path = resoureMagicPath;
			}
			return path;
		}
		
		private function magicGetName(id:String):String
		{
			return "effect" + id;
		}
		
		private function checkReadyShowMagic():void // 检查是否准备好要播放
		{
			--magicLen;
//			trace("magicLen", magicLen);
			if (magicLen == 0) {
				playMagics();
			}
		}
		
		private function saveConf():void
		{
			magicBar.updateVo();
			
			var conf:XML = <data/>;
			var confChild:XML
			var magicsVo:Dictionary = magicBar.voDict;
			for each (var c:Comp in magicsVo) {
				confChild = <magic/>;
				if (c && c.magicName && c.magicId) {
					confChild.id = c.magicId;
					confChild.name = c.magicName;
					confChild.comp = c.compName;
					confChild.offsetX = c.offsetX;
					confChild.offsetY = c.offsetY;
					confChild.scaleX = c.scaleX;
					confChild.scaleY = c.scaleY;
					confChild.rotation = c.rotation;
					confChild.delay = c.delay;
					confChild.fligH = c.flipH ? 1 : 0;
					conf.appendChild(confChild);
				}
			}
			conf.@direction = magicBar.getDirection() ? 1 : 0;
			
			var text:String = conf.toString();
			trace(text);
//			var _fileRef:FileReference=new FileReference();//用于保存文件
			fileWriter.save(text, DEFAULT_EXPORTING_FILE_NAME);//保存到磁盘，会出现个系统保存对话框。
		}
		
		private function loadConf():void
		{
			var fileFilter:FileFilter = new FileFilter("xml", "*.xml");
			fileReader.browse([fileFilter]);
		}

		private function __onSelectFile(event:Event):void
		{
			if (event.type == Event.SELECT) {
				fileReader.load();
			}
		}

		private function __onCompleteLoadConf(event:Event):void
		{
			var data:ByteArray = ByteArray(event.target.data);
			var conf:XML = XML(data.readMultiByte(data.length, "utf-8"));
			for each (var magic:XML in conf.magic) {
				magicBar.updateTextField(magic);
			}
			magicBar.updateDirection(conf.@direction);
			magicBar.updateFileName(fileReader.name);
		}

		private function __onCompleteSaveConf(event:Event):void
		{
			magicBar.updateFileName(fileWriter.name);
		}
		
		private var interCount:int = 0;
		private function setInterCount(value:int):void
		{
			interCount += value;
			if (interCount < 0) interCount = 0;
		}
		
		
		///////////////////////////////////
		// 所有资源
		///////////////////////////////////
		
		private function loadNpc(path:String, status:String):void
		{
			dispatchEvent(new BaseEvent(EVENT_SHOW_NPC, '', [path, status]));
		}
		

		///////////////////////////////////
		// 法术特效
		///////////////////////////////////
		
		private function playMagics():void
		{
			magicBar.updateVo();
			
			dispatchEvent(new BaseEvent(EVENT_SHOW_MAGICS));
		}
		
		
		///////////////////////////////////
		// 事件处理
		///////////////////////////////////
		
		private function __onEnterFrame(event:Event):void
		{
			offsetText.x = mouseX + 10;
			offsetText.y = mouseY;
			
			var tX:int = mouseX - TARGET_X;
			var tY:int = mouseY - TARGET_Y;
			
			offsetText.setText(tX + ", " + tY);
		}
		
		private function __onStageMouseDown(event:MouseEvent):void
		{
			var target:Object = event.target;
			if ( !(target is JButton) && !(target is TextField) ) {
				if (tfOffsetX) {
					var tX:int = mouseX - TARGET_X;
					tfOffsetX.setText(tX + '');
				}
				if (tfOffsetY) {
					var tY:int = mouseY - TARGET_Y;
					tfOffsetY.setText(tY + '');
				}
			}
		}
		
		private function __onMouseDown(event:MouseEvent):void
		{
			
			var target:Object = event.target;
			var npcName:String = npcBar.npcText.getText();
			
			// 点击偏移 textfield
			if (target && target['parent'] is JTextField) {
				var tf:JTextField = target['parent'] as JTextField;
				var hbox:HBoxUI = tf.parent as HBoxUI;
				if (tf.name == "offsetX" || tf.name == "offsetY") {
					tfOffsetX = hbox.getChildByName("offsetX") as JTextField;
					tfOffsetY = hbox.getChildByName("offsetY") as JTextField;
				}
			} 			
				
			if (target is JButton) {
				switch (target) {
					case magicBar.btnLoad:
						playMagics();
						break;
					case magicBar.btnSaveConfig:
						saveConf();
						break;
					case magicBar.btnLoadConfig:
						loadConf();
//						clearLastMagics();
						break;
					case magicBar.btnClearList:
						magicBar.clearEffectList();
						break;
					case npcBar.btn:
						loadNpc(npcName, CharStatusType.STAND);
						break;
					case npcBar.btn2:
						loadNpc(npcName, CharStatusType.WALK);
						break;
					case npcBar.btn3:
						loadNpc(npcName, CharStatusType.INJURED);
						break;
					case npcBar.btn4:
						loadNpc(npcName, CharStatusType.MAGIC_ATTACK);
						break;
					case npcBar.btn5:
						loadNpc(npcName, CharStatusType.STANDBY);
						break;
					case npcBar.btn6:
						loadNpc(npcName, CharStatusType.ATTACK);
						break;
//					case npcBar.btn_left:
//						this.x = 0;
//						this.y = stage.stageHeight - 800;
//						break;
//					case npcBar.btn_center:
//						this.x = (stage.stageWidth - 1200)/2;
//						this.y = stage.stageHeight - 800;
//						break;
//					case npcBar.btn_right:
//						this.x = stage.stageWidth - 1200;
//						this.y = stage.stageHeight - 800;
//						break;
				}
			}
		}
	}
}