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
	import cc.utils.CCG;
	import cc.utils.PathFind;
	import cc.utils.SceneUtil;
	import cc.utils.Transformer;
	import cc.vo.avatar.AvatarParamData;
	import cc.vo.map.MapTile;
	
	import flash.geom.Point;
	
	import wit.manager.EventManager;
	import wit.utils.NumberU;

	public class GameApp extends CCApplication
	{
		private var scene:CCScene;
		private var mainChar:CCCharacter;
		
		public function GameApp() {
		}
		
		public function Startup():void {
			CCDirector.Init('res/', 30);
			
			if (scene == null) {
				scene = new CCScene(1200, 650);
				addChild(scene);
			}
			
			EnterScene();
			
			EventManager.addEvent(CCEvent.INTERACTIVE, onMouseDownEvent, CCScene.eventCenter);
		}
		
		/**
		 * 进入场景 
		 */
		public function EnterScene():void {
			// TODO: 先清理上一个场景的资源 
			
			var shadowApd:AvatarParamData = new AvatarParamData(CCG.GetResPath('share/shadow.swf'));
			scene.setShadowAvatarParamData(shadowApd);
			
			var blankApd:AvatarParamData = new AvatarParamData(CCG.GetResPath('share/blank.swf'));
			scene.setBlankAvatarParamData(blankApd);
			
			var mouseChar:CCCharacter = scene.createSceneCharacter(CharType.DUMMY, 0, 0);
			mouseChar.loadAvatarPart(new AvatarParamData(CCG.GetResPath('share/mousechar.swf'), AvatarPartType.MAGIC));
			scene.setMouseChar(mouseChar);
			scene.hideMouseChar();
			
			// 切换场景
			scene.switchScene(30, 30, onEnteredScene);
			
			if (mainChar == null) {
				mainChar = scene.createSceneCharacter(CharType.PLAYER, 66, 60);
				mainChar.loadAvatarPart(new AvatarParamData(CCG.GetResPath('hero/hero3.swf')));
				
				scene.setMainChar(mainChar);
				
				mainChar.setHeadFaceNickName('逆风上磡');
				mainChar.setHeadFaceCustomTitleHtmlText('胡莱西游');
				mainChar.setHeadFaceTalkText('你好，真名！');
				mainChar.setHeadFaceBar(80, 100);
			}
			
			var tx:int, ty:int, npc:CCCharacter;
			for (var i:int=0; i<40; i++) {
				tx = NumberU.randRange(40, 100);
				ty = NumberU.randRange(30, 80);
				
				npc = scene.createSceneCharacter(CharType.NPC_FRIEND, tx, ty);
				npc.loadAvatarPart(new AvatarParamData(CCG.GetResPath('hero/hero3.swf')));
				npc.setHeadFaceNickName('');
			}
			
			// 清理上一场景的走路信息
			mainChar.stopWalk(true);
			
			mainChar.playTo(CharStatusType.STAND, CharAngleType.ANGEL_0);
			
		}
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		/**
		 * 加载地图完成 
		 */
		private function onEnteredScene():void {
			//
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
				mainChar.walk0(path, null, -1, 0, {'onWalkThrough':null});
			}
		}
		
		private function onMouseDownEvent(event:CCEvent):void {
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
						}
					}
				}
			}
		}
	}
}