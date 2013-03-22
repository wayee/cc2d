package
{
	import cc.CCDirector;
	import cc.define.CharStatusType;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.aswing.AsWingManager;
	import org.aswing.JButton;
	import org.aswing.JLabel;
	import org.aswing.JTextField;
	
	import wit.utils.Fun;
	import cc.ext.CCSpriteSheet;
	
	[SWF(width="900", height="600", backgroundColor="0x838383", frameRate="24")]
	public class CharacterEditor extends Sprite
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
		
		public var npcText:JTextField;
		public var wingText:JTextField;
		public var mountText:JTextField;
		
		public var npc:Object = {};
		public var _avatar:Sprite;
		public var _wingLeft:Sprite;
		public var _wingRight:Sprite;
		public var _mount:Sprite;
		
		private var _currentNpc:CCSpriteSheet;
		private var _currentWingLeft:CCSpriteSheet;
		private var _currentWingRight:CCSpriteSheet;
		private var _currentMount:CCSpriteSheet;
		private var _isOnMount:Boolean;
		private var _hasWing:Boolean;
		
		private var _loadNum:int = 0;
		
		public static const OFFSET:int = 120;
		
		public function CharacterEditor()
		{
			if (stage) init(null);
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void
		{
			AsWingManager.initAsStandard(this);
//			UIManager.setLookAndFeel(new YiTongLNF);
			
			CCDirector.Init('./', 24);
			
			btn = addButton('站立');
			btn2 = addButton('跑步', 70);
			btn3 = addButton('受伤', 140);
			btn4 = addButton('法术攻击', 210);
			btn5 = addButton('战斗待机', 280);
			btn6 = addButton('攻击', 350);

			btn_a0 = addButton('0', 560, 555, 20);
			btn_a1 = addButton('1', 420, 555, 20);
			btn_a2 = addButton('2', 440, 555, 20);
			btn_a3 = addButton('3', 460, 555, 20);
			btn_a4 = addButton('4', 480, 555, 20);
			btn_a5 = addButton('5', 500, 555, 20);
			btn_a6 = addButton('6', 520, 555, 20);
			btn_a7 = addButton('7', 540, 555, 20);
			
			npcText = new JTextField('hero1');
			npcText.setSizeWH(120, 24);
			npcText.setX(420);
			npcText.setY(580);
			addChild(npcText);
			
			wingText = new JTextField('1');
			wingText.setSizeWH(80, 24);
			wingText.setX(545);
			wingText.setY(580);
			addChild(wingText);
			
			mountText = new JTextField('1001');
			mountText.setSizeWH(80, 24);
			mountText.setX(630);
			mountText.setY(580);
			addChild(mountText);

			var labal:JLabel = new JLabel('请输入：英雄name 翅膀id 坐骑id');
			labal.setSizeWH(200, 24);
			labal.setX(710);
			labal.setY(580);
			addChild(labal);
			
			_wingRight = new Sprite;
			_wingRight.x = 420;
			_wingRight.y = 360;
			addChild(_wingRight);
			
			_mount = new Sprite;
			_mount.x = 420;
			_mount.y = 360;
			addChild(_mount);
			
			_wingLeft = new Sprite;
			_wingLeft.x = 420;
			_wingLeft.y = 360;
			addChild(_wingLeft);
			
			_avatar = new Sprite;
			_avatar.x = 420;
			_avatar.y = 360;
			addChild(_avatar);
			
			var callback:Function = function(sp:CCSpriteSheet):void
			{
				addChild(sp);
				sp.x = 420;
				sp.y = 360;
				sp.play();
			};
			
			CharacterHelper.getAvatar('shadow.swf', callback);
		}
		
		private function addButton(text:String='', xPos:int=0, yPos:int=580, w:int=60):JButton
		{
			var button:JButton = new JButton(text);
			button.setSizeWH(w, 24);
			button.setX(xPos);
			button.setY(yPos);
			addChild(button);
			
			button.addEventListener(MouseEvent.CLICK, __onMouseDown);
			
			return button;
		}
		
		private var curStatus:String = '';
		private function loadNpc(status:String='', angle:int=0):void
		{
			_loadNum = 0;
			_isOnMount = false;
			_hasWing = false;
			_currentMount = null;
			_currentNpc = null;
			_currentWingLeft = null;
			_currentWingRight = null;
			
			var name:String = npcText.getText();
			
			if (status == '') status = curStatus;
			else curStatus = status;
			var key:String = name + status;
//			if (npc.hasOwnProperty(key)) {
//				showNpc(key);
//			} else {
				var errCallback:Function = function():void
				{
					_loadNum++;
					tidyAll();
				};
					
				var callback:Function = function(sp:CCSpriteSheet):void
				{
					_loadNum++;
					npc[key] = sp;
					_currentNpc = sp;
					showNpc(key);
				};
				CharacterHelper.getAvatar(name+'.swf', callback, errCallback, angle, status);
				
				var wingName:String = wingText.getText();
				var key1:String;
				var key2:String;
				if (wingName) {
					key1 = 'wl'+ wingName + status;
					key2 = 'wr'+ wingName + status;
				}
				var callbackWingLeft:Function = function(sp:CCSpriteSheet):void
				{
					_hasWing = true;
					_loadNum++;
					npc[key1] = sp;
					_currentWingLeft = sp;
					showWingLeft(key1);
				};
				var callbackWingRight:Function = function(sp:CCSpriteSheet):void
				{
					_hasWing = true;
					_loadNum++;
					npc[key2] = sp;
					_currentWingRight = sp;
					showWingRight(key2);
				};
				if (wingName) {
					CharacterHelper.getAvatar('wl'+wingName+'.swf', callbackWingLeft, errCallback, angle, status);
					CharacterHelper.getAvatar('wr'+wingName+'.swf', callbackWingRight, errCallback, angle, status);
				} else {
					_loadNum++;
					_loadNum++;
					Fun.clearChildren(_wingLeft);
					Fun.clearChildren(_wingRight);
					_currentWingLeft = null;
					_currentWingRight = null;
					tidyAll();
				}
				
				var mountName:String = mountText.getText();
				var key3:String;
				if (mountName) {
					key3 = 'mount' + mountName + status;
				}
				var callbackMount:Function = function(sp:CCSpriteSheet):void
				{
					_isOnMount = true;
					_loadNum++;
					npc[key3] = sp;
					_currentMount = sp;
					showMount(key3);
				};
				if (mountName) {
					CharacterHelper.getAvatar('mount'+mountName+'.swf', callbackMount, errCallback, angle, status);
				} else {
					_loadNum++;
					Fun.clearChildren(_mount);
					_currentMount = null;
					tidyAll();
				}
				
//				try {
//					CharacterHelper.getAvatar(name+'.swf', callback, angle, status);
//				} catch (error:Error) {
//					UiHelper.showDialog('', error.message);
//					UiHelper.showFlashAlert('不存在资源或者动作');
//				}
//			}
		}
		
		private function tidyAll():void
		{
			if (_loadNum >= 4) {
				var offsetDir:int = -1;
				if (_currentNpc && (_currentNpc.angle == 0 || _currentNpc.angle >= 4)) {
					offsetDir = 1;
				}
				
				var offsetMountX:Number;
				var offsetMountY:Number;
				var offsetWingX:Number;
				var offsetWingY:Number;
				
				if (_isOnMount) {
					if (_currentMount && _currentNpc) {
						offsetMountX = _currentMount.currentAvatarPartStatus.mx - _currentNpc.currentAvatarPartStatus.mx;
						offsetMountY = _currentMount.currentAvatarPartStatus.my - _currentNpc.currentAvatarPartStatus.my;
						_currentNpc.x += offsetMountX * offsetDir;
						_currentNpc.y += offsetMountY;
					}
					if (_currentWingLeft && _currentNpc) {
						offsetWingX = _currentNpc.currentAvatarPartStatus.wx - _currentWingLeft.currentAvatarPartStatus.wx + offsetMountX;
						offsetWingY = _currentNpc.currentAvatarPartStatus.wy - _currentWingLeft.currentAvatarPartStatus.wy + offsetMountY;
						trace('wx', offsetWingX);
						trace('wy', offsetWingY);
						_currentWingLeft.x += offsetWingX * offsetDir;
						_currentWingLeft.y += offsetWingY;
					}
					if (_currentWingRight && _currentNpc) {
						offsetWingX = _currentNpc.currentAvatarPartStatus.wx - _currentWingRight.currentAvatarPartStatus.wx + offsetMountX;
						offsetWingY = _currentNpc.currentAvatarPartStatus.wy - _currentWingRight.currentAvatarPartStatus.wy + offsetMountY;
						trace('wx', offsetWingX);
						trace('wy', offsetWingY);
						_currentWingRight.x += offsetWingX * offsetDir;
						_currentWingRight.y += offsetWingY;
					}
				} else {
					if (_currentWingLeft && _currentNpc) {
						offsetWingX = _currentNpc.currentAvatarPartStatus.wx - _currentWingLeft.currentAvatarPartStatus.wx;
						offsetWingY = _currentNpc.currentAvatarPartStatus.wy - _currentWingLeft.currentAvatarPartStatus.wy;
						trace('wx', offsetWingX);
						trace('wy', offsetWingY);
						_currentWingLeft.x += offsetWingX * offsetDir;
						_currentWingLeft.y += offsetWingY;
					}
					if (_currentWingRight && _currentNpc) {
						offsetWingX = _currentNpc.currentAvatarPartStatus.wx - _currentWingRight.currentAvatarPartStatus.wx;
						offsetWingY = _currentNpc.currentAvatarPartStatus.wy - _currentWingRight.currentAvatarPartStatus.wy;
						trace('wx', offsetWingX);
						trace('wy', offsetWingY);
						_currentWingRight.x += offsetWingX * offsetDir;
						_currentWingRight.y += offsetWingY;
					}
				}
				
				trace('tidy');
			}
		}

		private function showWingLeft(key:String):void
		{
			var sp:CCSpriteSheet = npc[key];
			sp.play();
			Fun.clearChildren(_wingLeft);
			_wingLeft.addChild(sp);
			tidyAll();
//			sp.gotoAndPlay(1);
		}

		private function showWingRight(key:String):void
		{
			var sp:CCSpriteSheet = npc[key];
			sp.play();
			Fun.clearChildren(_wingRight);
			_wingRight.addChild(sp);
			tidyAll();
//			sp.gotoAndPlay(1);
		}

		private function showMount(key:String):void
		{
			var sp:CCSpriteSheet = npc[key];
			sp.play();
			Fun.clearChildren(_mount);
			_mount.addChild(sp);
			tidyAll();
//			sp.gotoAndPlay(1);
		}

		private function showNpc(key:String):void
		{
			var sp:CCSpriteSheet = npc[key];
			sp.play();
			Fun.clearChildren(_avatar);
			_avatar.addChild(sp);
			tidyAll();
//			sp.gotoAndPlay(1);
		}

		private function __onMouseDown(event:MouseEvent):void
		{
			var target:JButton = JButton(event.target);
			switch (target) {
				case btn:
					loadNpc(CharStatusType.STAND);
					break;
				case btn2:
					loadNpc(CharStatusType.WALK);
					break;
				case btn3:
					loadNpc(CharStatusType.INJURED);
					break;
				case btn4:
					loadNpc(CharStatusType.MAGIC_ATTACK);
					break;
				case btn5:
					loadNpc(CharStatusType.STANDBY);
					break;
				case btn6:
					loadNpc(CharStatusType.ATTACK);
					break;
				case btn_a0:
					loadNpc('', 0);
					break;
				case btn_a1:
					loadNpc('', 1);
					break;
				case btn_a2:
					loadNpc('', 2);
					break;
				case btn_a3:
					loadNpc('', 3);
					break;
				case btn_a4:
					loadNpc('', 4);
					break;
				case btn_a5:
					loadNpc('', 5);
					break;
				case btn_a6:
					loadNpc('', 6);
					break;
				case btn_a7:
					loadNpc('', 7);
					break;
			}
		}
	}
}