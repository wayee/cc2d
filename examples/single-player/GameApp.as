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
	import cc.helper.WalkHelper;
	import cc.utils.CCG;
	import cc.utils.SceneUtil;
	import cc.utils.Transformer;
	import cc.vo.avatar.AvatarParamData;
	import cc.vo.map.MapTile;
	
	import flash.geom.Point;
	
	import wit.log.Log4J;
	import wit.manager.EventManager;
	import cc.utils.PathFind;

	public class GameApp extends CCApplication
	{
		private var scene:CCScene;
		private var mainChar:CCCharacter;
		
		public function GameApp() {
		}
		
		public function Startup():void {
			CCDirector.Init('res', 30);
			
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
			
			var shadowApd:AvatarParamData = new AvatarParamData(CCG.GetSharePath('shadow'));
			scene.setShadowAvatarParamData(shadowApd);
			
			var blankApd:AvatarParamData = new AvatarParamData(CCG.GetSharePath('blank'));
			scene.setBlankAvatarParamData(blankApd);
			
			var mouseChar:CCCharacter = scene.createSceneCharacter(CharType.DUMMY, 0, 0);
			mouseChar.loadAvatarPart(new AvatarParamData(CCG.GetSharePath('mousechar'), AvatarPartType.MAGIC));
			scene.setMouseChar(mouseChar);
			scene.hideMouseChar();
			
			// 切换场景
			scene.switchScene(30, 30, onEnteredScene);
			
			if (mainChar == null) {
				mainChar = scene.createSceneCharacter(CharType.PLAYER, 66, 60);
				mainChar.loadAvatarPart(new AvatarParamData(CCG.GetHeroPath('3')));
				
				scene.setMainChar(mainChar);
				
				mainChar.setHeadFaceNickName('逆风上磡');
				mainChar.setHeadFaceCustomTitleHtmlText('胡莱西游');
				mainChar.setHeadFaceTalkText('你好，真名！');
				mainChar.setHeadFaceBar(80, 100);
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
		
		private function moveTo(tx:Number, ty:Number):void {
			var currentX:int = mainChar.TileX;
			var currentY:int = mainChar.TileY;
			
			var startPos:int = SceneUtil.ConvertTileToId([currentX, currentY], scene.mapConfig.mapGridX, scene.mapConfig.mapGridY);
			var endPos:int   = SceneUtil.ConvertTileToId([tx, ty], scene.mapConfig.mapGridX, scene.mapConfig.mapGridY);	
			
			var paths:Array = PathFind.getRealPath(startPos, endPos, scene.mapConfig.mapData, true);
			
			var path:Array = SceneUtil.ConvertIdsToTile(paths, scene.mapConfig.mapGridX, scene.mapConfig.mapGridY);
			
			Log4J.Debug('first point: ' + path[0][0] + path[0][1]);
			if (mainChar != null) {
				WalkHelper.walk0(mainChar, path, null, -1, 0, {'onWalkThrough':null});
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
						target = Transformer.transPixelPoint2TilePoint(m);
						if (mainChar != null) {
							Log4J.Debug("click point (pixelX: " + m.x + " pixelY: " + m.y + " tileX: " + target.x + " tileY: " + target.y + ') in the scene.');
							moveTo(target.x, target.y);
						}
					}
				}
			}
		}
	}
}