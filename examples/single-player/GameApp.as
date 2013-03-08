package
{
	import cc.CCApplication;
	import cc.CCCharacter;
	import cc.CCDirector;
	import cc.CCScene;
	import cc.define.AvatarPartType;
	import cc.define.CharAngleType;
	import cc.define.CharStatusType;
	import cc.define.CharType;
	import cc.events.CCEvent;
	import cc.events.CCEventActionInteractive;
	import cc.graphics.avatar.CCAvatarPart;
	import cc.helper.MagicHelper;
	import cc.utils.CCG;
	import cc.utils.PathFind;
	import cc.utils.Transformer;
	import cc.vo.avatar.AvatarParamData;
	import cc.vo.map.MapTile;
	import cc.vo.move.MoveCallBack;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import wit.event.BaseEvent;
	import wit.log.SWFProfiler;
	import wit.manager.EventManager;
	import wit.manager.HandlerManager;
	import wit.manager.TimerManager;
	import wit.utils.Fun;
	import wit.utils.number;
	
	import xy.meditor.Comp;
	import xy.meditor.MEditor;

	public class GameApp extends CCApplication
	{
		private var scene:CCScene;
		private var mainChar:CCCharacter;
		private var editor:MEditor;
		private var characters:Vector.<CCCharacter>;
		private static const MAX_CHARACTERS:int = 100;
		
		public function GameApp() {
		}
		
		public function Startup():void {
			SWFProfiler.init(this.stage, this);
			
			CCDirector.Init('res/', 24);
			
			if (scene == null) {
				scene = new CCScene(1440, 900);
				addChild(scene);
			}
			
			Fun.setStartTime();
			
			characters = new Vector.<CCCharacter>;
			EnterScene();
			EventManager.addEvent(CCEvent.INTERACTIVE, __onMouseDownEvent, CCScene.eventCenter);
			
			
//			_triggerFighting();
			
//			if (stage) {
//				stage.addEventListener(Event.RESIZE, __onResize);
//			}
			
//			editor = new MEditor;
//			addChild(editor);
//			editor.init();
//			editor.addEventListener(MEditor.EVENT_SHOW_NPC, __onEditorHandler);
//			editor.addEventListener(MEditor.EVENT_SHOW_MAGICS, __onEditorHandler);
		}

		/**
		 * 进入场景 
		 */
		public function EnterScene():void {
			// TODO: 先清理上一个场景的资源 
			
			var shadowApd:AvatarParamData = new AvatarParamData(CCG.GetResPath('share/shadow.swf'));
			scene.SetShadowAvatarParamData(shadowApd);
			
			var blankApd:AvatarParamData = new AvatarParamData(CCG.GetResPath('share/blank.swf'));
			scene.SetBlankAvatarParamData(blankApd);
			
			var mouseChar:CCCharacter = scene.CreateSceneCharacter(CharType.DUMMY, 0, 0);
			mouseChar.loadAvatarPart(new AvatarParamData(CCG.GetResPath('share/mousechar.swf'), AvatarPartType.MAGIC));
			scene.SetMouseChar(mouseChar);
			scene.HideMouseChar();
			
			var apd:AvatarParamData;
			if (mainChar == null) {
				apd = new AvatarParamData(CCG.GetResPath('hero/hero4.swf'));
				//				apd.rotation = 45;
				//				apd.scaleX = 2;
				//				apd.scaleY = 2;
				//				mainChar = scene.CreateSceneCharacter(CharType.PLAYER, 28, 24);
				mainChar = scene.CreateSceneCharacter(CharType.PLAYER, 68, 68);
				mainChar.loadAvatarPart(apd);
				//				mainChar.loadAvatarPart(new AvatarParamData(CCG.GetResPath('npc/npc101211.swf')));
				//				mainChar.loadAvatarPart(new AvatarParamData(CCG.GetResPath('npc/npc101011.swf')));
				//				mainChar.loadAvatarPart(new AvatarParamData(CCG.GetResPath('npc/npc100521.swf')));
				//				mainChar.loadAvatarPart(new AvatarParamData(CCG.GetResPath('npc/npc100011.swf')));
				
				scene.SetMainChar(mainChar);
				
				mainChar.setHeadFaceNickName('逆风上磡');
				mainChar.setHeadFaceCustomTitleHtmlText('胡莱西游');
				mainChar.setHeadFaceTalkText('你好，真名！');
				mainChar.setHeadFaceBar(80, 100);
				//				scene.SetMouseOnCharacter(mainChar);
			}
			
			// 切换场景
			scene.SwitchScene(11, 11, onEnteredScene);
			
		}
		
		///////////////////////////////////
		// private methods
		///////////////////////////////////
		
		private function updateCharacterWalkPath():void
		{
			var path:Array;
			var moveXDist:Number;
			var moveYDist:Number;
			var startPos:int;
			var endPos:int;
			var paths:Array;
			var char:CCCharacter
			var i:uint = characters.length;
			
			Fun.traceElapsingTimeIf("[start] update moving path ", 0.1);
			
			while ( --i > -1 ) {
				char = characters[i];
				if ( !char.inViewDistance() ) {
					scene.RemoveCharacter(char);
					characters.splice(i, 1);
					continue;
				}
				
				if (char.moveData.walk_pathArr != null && char.moveData.walk_pathArr.length > 0) {
					continue;
				}
				
				moveXDist = char.TileX + number.randRange(-20, 20);
				moveYDist = char.TileY + number.randRange(-20, 20);
				startPos = Transformer.TransTilePoint2Id(new Point(char.TileX, char.TileY), scene.mapConfig.mapGridX, scene.mapConfig.mapGridY);
				endPos   = Transformer.TransTilePoint2Id(new Point(moveXDist, moveYDist), scene.mapConfig.mapGridX, scene.mapConfig.mapGridY);	
				
//				Fun.getTimerDiff();
//				paths = PathFind.getRealPath(startPos, endPos, scene.mapConfig.mapData, true);
//				Fun.traceElapsingTimeIf("[end] PathFind.getRealPath " + paths.toString() + " pos" + moveXDist + ", " + moveYDist, 0.05);
				path = Transformer.TransIds2TilePoints([startPos, endPos], scene.mapConfig.mapGridX, scene.mapConfig.mapGridY);
				Fun.traceElapsingTimeIf("[end] Transformer.TransIds2TilePoints " + path.toString(), 0.05);
				
				char.walk0(path);
			}
			
			var n:int = 0;
			while (characters.length < MAX_CHARACTERS) {
				characters.push(createCharacter(68, 68));
				n++;
			}
		}
		
		private function updateMainCharacter(data:Array):void
		{
			if (data) {
				//
			}
		}
		
		private var _characters:Array;
		private function _handlerShowFighting():void
		{
			var sceneChar:CCCharacter;
			var toApd:AvatarParamData;
			
			trace(number.randRange(0, 2));
			
//			for (var i:int=0; i<10; i++) {
//				var r:int = number.randRange(0, 59);
//				sceneChar = _characters[r];
//				
//				sceneChar.setStatus(CharStatusType.MAGIC_ATTACK);
//				toApd = new AvatarParamData(CCG.GetResPath("effect/effect303.swf"), AvatarPartType.MAGIC);
//				MagicHelper.showMagic(sceneChar, [sceneChar], null, toApd);
//			}
			
//			for each (sceneChar in _characters) {
//				sceneChar.setStatus(CharStatusType.MAGIC_ATTACK);
//				toApd = new AvatarParamData(CCG.GetResPath("effect/effect303.swf"), AvatarPartType.MAGIC);
//				MagicHelper.showMagic(sceneChar, [sceneChar], null, toApd);
//			}
		}
		
		private function _triggerFighting():void
		{
			if ( !TimerManager.hasGlobalHandler(_handlerShowFighting, 2)) {
				TimerManager.createGlobalTimer(_handlerShowFighting, null, 2, 999);
			}
		}
		
		private function createCompoudMagic():void
		{
			var completeHandler:Function = function(char:CCCharacter, part:CCAvatarPart):void
			{
			};
			var playMagic:Function = function(p_apd:AvatarParamData):void
			{
				MagicHelper.showMagic(mainChar, [mainChar], p_apd);
			};
			
			var dict:Dictionary = editor.magicBar.voDict;
			var toApd:AvatarParamData;
			var dir:Boolean = editor.magicBar.getDirection();
			var offset_x:Number = 0;
			for each (var c:Comp in dict) {
				if (c && c.magicName && c.magicId) {
					if (dir) offset_x = -c.offsetX - (300 * c.scaleX - 300);
					else offset_x = c.offsetX;
					toApd = createParamData(c.magicId, offset_x, c.offsetY, c.scaleX, c.scaleY, c.rotation);
					if (c.delay > 0) {
						HandlerManager.executeThread(playMagic, [toApd], c.delay * 1000);
					} else {
						MagicHelper.showMagic(mainChar, [mainChar], toApd);
					}
				}
			}
		}
		
		private function createCharacter(tx:Number, ty:Number, sx:Number=1, sy:Number=1, rot:Number=0):CCCharacter
		{
			var npc:CCCharacter;
			var apd:AvatarParamData;
			apd = new AvatarParamData(CCG.GetResPath('hero/hero'+number.randRange(1, 30)+'.swf'));
//			apd = new AvatarParamData(CCG.GetResPath('hero/hero4.swf'));
			apd.scaleX = sx;
			apd.scaleY = sy;
			apd.rotation = rot;
			npc = scene.CreateSceneCharacter(CharType.PLAYER, tx, ty);
			npc.loadAvatarPart(apd);
			npc.setHeadFaceNickName('我是守卫');
			
			if (_characters == null) {
				_characters = [];
			}
			_characters.push(npc);
			
			return npc;
		}
		
		/**
		 * 加载地图完成 
		 */
		private function onEnteredScene():void {
			
			//			createCharacter(66, 60);
			//			createCharacter(66, 60, 1.2, 1.2, -50);
			//			createCharacter(60, 60, 1.6, 1.6);
			//			createCharacter(54, 60, 2, 2);
			//			createCharacter(48, 60, 3, 3);
			
			var tx:Number, ty:Number;
			var char:CCCharacter;
			for (var i:int=0; i<MAX_CHARACTERS; i++) {
				tx = ty = 68;
				
				//				tx = number.randRange(40, 100);
				//				ty = number.randRange(30, 80);
				char = createCharacter(tx, ty)
				characters.push(char);
			}
			
			TimerManager.createGlobalTimer(updateCharacterWalkPath, null, 1, 9999);
			updateCharacterWalkPath();
			
			// 清理上一场景的走路信息
			mainChar.stopWalk(true);
			
			mainChar.playTo(CharStatusType.STAND, CharAngleType.ANGEL_0);
		}
		
		private function jumpTo(tx:Number, ty:Number):void {
			if (mainChar != null) {
				mainChar.jump(new Point(tx, ty), 120);
			}
		}
		
		private function moveTo(tx:Number, ty:Number):void {
			var currentX:int = mainChar.TileX;
			var currentY:int = mainChar.TileY;
			var startPos:int = Transformer.TransTilePoint2Id(new Point(currentX, currentY), scene.mapConfig.mapGridX, scene.mapConfig.mapGridY);
			var endPos:int   = Transformer.TransTilePoint2Id(new Point(tx, ty), scene.mapConfig.mapGridX, scene.mapConfig.mapGridY);	
			var paths:Array = PathFind.getRealPath(startPos, endPos, scene.mapConfig.mapData, true);
			var path:Array = Transformer.TransIds2TilePoints(paths, scene.mapConfig.mapGridX, scene.mapConfig.mapGridY);
//			Log4J.Debug('first point: ' + path[0][0] + path[0][1]);
			if (mainChar != null) {
				mainChar.walk0(path, null, -1, 0, new MoveCallBack);
			}
		}
		
		private function createParamData(id:String, ox:Number=0, oy:Number=0, sx:Number=1, sy:Number=1, rot:Number=0):AvatarParamData
		{
			var toApd:AvatarParamData = new AvatarParamData(CCG.GetResPath("effect/effect"+id+".swf"), AvatarPartType.MAGIC);
			toApd.offsetX = ox;
			toApd.offsetY = oy;
			toApd.scaleX = sx;
			toApd.scaleY = sy;
			toApd.rotation = rot;
			
			return toApd;
		}
		
		private function __onEditorHandler(event:BaseEvent):void
		{
			if (event.type == MEditor.EVENT_SHOW_NPC) {
				updateMainCharacter(event.data as Array);
			} else if (event.type == MEditor.EVENT_SHOW_MAGICS) {
				createCompoudMagic();
			}
		}
		
//		private function __onResize(event:Event):void
//			scene.Resize(stage.stageWidth, stage.stageHeight);
//			
//			editor.x = (stage.stageWidth - 1200)/2;
//			editor.y = stage.stageHeight - 800;
//		}
		public function ResizeStage(sw:Number, sh:Number):void
		{
			scene.Resize(sw, sh);
			
//			editor.x = (sw - 1200)/2;
//			editor.y = sh - 800;
		}
		
		private function __onMouseDownEvent(event:CCEvent):void {
			var arr:Array = event.Data as Array;
			var sceneChar:CCCharacter = arr[1];
			var targetMapTile:MapTile = arr[2];
			var m:Point = arr[3];
			var target:Point;
			
			// 鼠标点击
			if (event.Action == CCEventActionInteractive.MOUSE_DOWN) {
				// 选中场景对象
				if (sceneChar ) {
					// 点击场景中的其他玩家
					if (sceneChar.type == CharType.PLAYER) {
						if ( !sceneChar.isMainChar() ) {
						}
					}
					
					// 点击场景中的NPC
					if (sceneChar.type == CharType.NPC) {
					}
					
					// 点击场景中的怪物
					if (sceneChar.type == CharType.MONSTER) {
					}
					
					// 点击场景中的传送点
					if (sceneChar.type == CharType.TRANSPORT) {
					}
				} else {
					if (m) {
						target = Transformer.TransPixelPoint2TilePoint(m);
						if (mainChar != null) {
//							Log4J.Debug("click point (pixelX: " + m.x + " pixelY: " + m.y + " tileX: " + target.x + " tileY: " + target.y + ') in the scene.');
							moveTo(target.x, target.y);
//							jumpTo(target.x, target.y);
//							createCompoudMagic();
						}
					}
				}
			}
		}
	}
}