package cc.helper
{
	import cc.CCCharacter;
	import cc.define.CharStatusType;
	import cc.events.CCEvent;
	import cc.events.CCEventActionWalk;
	import cc.move.Jump;
	import cc.tools.SceneCache;
	import cc.utils.AStar;
	import cc.utils.SceneUtil;
	import cc.utils.Transformer;
	import cc.vo.map.MapTile;
	import cc.vo.move.MoveCallBack;
	
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import wit.event.EventDispatchCenter;

	public class MoveHelper
	{
		public static function stopWalk(p_char:CCCharacter, is_stand:Boolean=true):void {
			p_char.moveData.clear();
			if (p_char == p_char.scene.mainChar) {
				p_char.scene.HideMouseChar();
			}
			
			if (is_stand) p_char.setStatus(CharStatusType.STAND);
		}
		
		public static function reviseWalkPath(p_char:CCCharacter):void {
			if (p_char == p_char.scene.mainChar) {
				if (p_char.avatar.status == CharStatusType.WALK) { // 正在走路
					if (p_char.moveData.walk_targetP != null) { // 目标点不为空
						walk(p_char, p_char.moveData.walk_targetP, -1, 
							p_char.moveData.walk_standDis, p_char.moveData.walk_MoveCallBack);
					} else {
						p_char.moveData.clear();
					}
				}
			} else {
				p_char.moveData.clear();
			}
		}

		/**
		 * @param error 当前位置到目标点可接受的误差值
		 * @param walkVars 回调onWalkArrived, onWalkThrough, onWalkUnable
		 */
		public static function walk(p_char:CCCharacter, targetTilePoint:Point, 
									walkSpeed:Number=-1, error:Number=0, moveCallBack:MoveCallBack=null):void {
			var sceneEvent:CCEvent;
			
			if ( p_char.isJumping() ) {
				return;
			}
			
			// 不可到达的点
			var mapTile:MapTile = SceneCache.MapTiles[targetTilePoint.x + "_" + targetTilePoint.y];
			if (mapTile == null) {
				if (p_char.isMainChar()) {
					p_char.scene.HideMouseChar();
					sceneEvent = new CCEvent(CCEvent.WALK, CCEventActionWalk.UNABLE, [p_char, mapTile]);
					EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
				}
				if (moveCallBack != null && moveCallBack.onMoveUnable != null) { // “不可到达”回调
					moveCallBack.onMoveUnable(p_char, mapTile);
				}
				return;
			}
			p_char.moveData.clear();
			
			// 已经到达目标点
			if (p_char.TileX == targetTilePoint.x && p_char.TileY == targetTilePoint.y) {
				if (p_char == p_char.scene.mainChar) {
					p_char.scene.HideMouseChar();
					sceneEvent = new CCEvent(CCEvent.WALK, CCEventActionWalk.ARRIVED, [p_char, mapTile]);
					EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
				}
				if (moveCallBack != null && moveCallBack.onMoveArrived != null) { // “到达”回调
					moveCallBack.onMoveArrived(p_char, mapTile);
				}
				return;
			}
			
			// 在误差范围内可算到达目标
			var pixelP:Point = new Point(mapTile.PixelX, mapTile.PixelY);
			var distance:Number;
			if (error != 0) {
				// 角色当前位置与目标点的直线距离的平方
				distance = (p_char.PixelX - mapTile.PixelX) * (p_char.PixelX - mapTile.PixelX) + (p_char.PixelY - mapTile.PixelY) * (p_char.PixelY - mapTile.PixelY);
				if (distance <= (error * error)) { // 距离小于一个“误差值”，可以算到达目标
					p_char.faceToTile(targetTilePoint.x, targetTilePoint.y); // 面向目标点
					if (p_char == p_char.scene.mainChar) {
						p_char.scene.HideMouseChar();
						mapTile = SceneCache.MapTiles[p_char.TileX + "_" + p_char.TileY];
						sceneEvent = new CCEvent(CCEvent.WALK, CCEventActionWalk.ARRIVED, [p_char, mapTile]);
						EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
					}
					if (moveCallBack != null && moveCallBack.onMoveArrived != null) {
						moveCallBack.onMoveArrived(p_char, mapTile);
					}
					return;
				}
			}
			
			// 角色当前位置是不可到达
			var currentPosTile:MapTile = SceneCache.MapTiles[p_char.TileX + "_" + p_char.TileY];
			mapTile = SceneUtil.GetRoundMapTile(currentPosTile, mapTile);
			if (mapTile == null) {
				p_char.faceToTile(targetTilePoint.x, targetTilePoint.y);
				if (p_char == p_char.scene.mainChar) {
					p_char.scene.HideMouseChar();
					sceneEvent = new CCEvent(CCEvent.WALK, CCEventActionWalk.UNABLE, [p_char, mapTile]);
					EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
				}
				if (moveCallBack != null && moveCallBack.onMoveUnable != null) {
					moveCallBack.onMoveUnable(p_char, mapTile);
				}
				return;
			}
			
			
			var walkPaths:Array = [];
			var isIsland:Boolean = mapTile.isIsland;
			if (isIsland) { // 目标点是孤立的
				walkPaths = AStar.search(SceneCache.MapSolids, mapTile.TileX, mapTile.TileY, p_char.TileX, p_char.TileY);
			} else {
				walkPaths = AStar.search(SceneCache.MapSolids, p_char.TileX, p_char.TileY, mapTile.TileX, mapTile.TileY);
			}
			
			if (walkPaths == null || walkPaths.length < 2) { // 目标点就在当前位置
				p_char.faceToTile(targetTilePoint.x, targetTilePoint.y);
				if (p_char == p_char.scene.mainChar) {
					p_char.scene.HideMouseChar();
					sceneEvent = new CCEvent(CCEvent.WALK, CCEventActionWalk.UNABLE, [p_char, mapTile]);
					EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
				}
				if (moveCallBack != null && moveCallBack.onMoveUnable != null) {
					moveCallBack.onMoveUnable(p_char, mapTile);
				}
				return;
			}
			
			if (!isIsland) { // 非孤立的
				walkPaths = walkPaths.reverse(); // 路径反转
			}
			
			var tilePoint:Point;
			var lastTilePoint:Point = walkPaths[walkPaths.length - 1];
			var pixelPoint:Point;
			if (error != 0) {
				for each (tilePoint in walkPaths) { // tilePoint[0] = tx, tilePoint[1] = ty
					// 转换为像素点
					pixelPoint = Transformer.TransTilePoint2PixelPoint(new Point(tilePoint.x, tilePoint.y));
					// 两点直线距离小于误差，算达到目标
					if (((pixelPoint.x - pixelP.x) * (pixelPoint.x - pixelP.x) + (pixelPoint.y - pixelP.y) * (pixelPoint.y - pixelP.y)) <= (error * error)) {
						// 删除后面的路径
						walkPaths = walkPaths.slice(0, (walkPaths.indexOf(tilePoint) + 1));
						break;
					}
				}
			} else {
				tilePoint = lastTilePoint; // tilePoint没有使用，意欲何为
			}
			walk0(p_char, walkPaths, targetTilePoint, walkSpeed, error, moveCallBack);
		}
		
		/**
		 * WalkStep.step()根据moveData来执行走路 
		 * @param walkPaths A* 计算后的路径数据 [[tx, ty], [tx, ty], ...]
		 * @param walkPaths A* 计算后的路径数据 [Point(tx, ty), ...]
		 */
		public static function walk0(p_char:CCCharacter, walkPaths:Array, 
									 targetTilePoint:Point=null, walkSpeed:Number=-1, 
									 error:Number=0, moveCallBack:MoveCallBack=null):void {
			var sceneEvent:CCEvent;
			
			if (walkPaths.length < 1) {	// < 2表示包括现在位置， < 1则不包括
				return;
			}
			var pathData:Array = walkPaths;
			p_char.moveData.clear();
			
			if (p_char == p_char.scene.mainChar) {
				// 移动优化
//				if (p_char.moveData.walk_pathCutter == null){
//					p_char.moveData.walk_pathCutter = new PathCutter(p_char);
//				}
//				p_char.moveData.walk_pathCutter.cutMovePath(pathData);
//				p_char.moveData.walk_pathCutter.walkNext(-1, -1);
			}
			
			// 设置走路速度
			if (walkSpeed >= 0) {
				p_char.setSpeed(walkSpeed);
			}
			
			// 设置目标点
			var lastPoint:Point;
			if (targetTilePoint != null) {
				p_char.moveData.walk_targetP = targetTilePoint;
			} else { // 没设定就使用走路路径的最后一点
				lastPoint = pathData[pathData.length - 1] as Point;
				p_char.moveData.walk_targetP = new Point(lastPoint.x, lastPoint.y);
			}
			
			p_char.moveData.walk_standDis = error;
			p_char.moveData.walk_MoveCallBack = moveCallBack;
			
			// 删除起点
//			var firstPoint:Array = pathData.shift();
//			if (p_char.TileX != firstPoint[0]) {
//				p_char.TileX = firstPoint[0];
//			}
//			if (p_char.TileY != firstPoint[1]) {
//				p_char.TileY = firstPoint[1];
//			}
			p_char.moveData.walk_pathArr = pathData;
			
			var lastPoint2:Point = pathData[pathData.length - 1] as Point;
			var lastPointMapTile:MapTile = SceneCache.MapTiles[lastPoint2.x + "_" + lastPoint2.y];
			if (p_char.isMainChar()) {
				p_char.scene.ShowMouseChar(lastPoint2.x, lastPoint2.y);
				sceneEvent = new CCEvent(CCEvent.WALK, CCEventActionWalk.READY, [p_char, lastPointMapTile, pathData]);
				EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
			}
			if (moveCallBack != null && moveCallBack.onMoveReady != null) {
				moveCallBack.onMoveReady(p_char, lastPointMapTile);
			}
		}
		
		public static function walk1(p_char:CCCharacter, pathByteData:ByteArray, 
									 targetTilePoint:Point=null, walkSpeed:Number=-1, 
									 error:Number=0, moveCallBack:MoveCallBack=null):void {
//			var arr:Array = PathConverter.convertToPoint(pathByteData);
//			walk0(p_char, arr, targetTilePoint, walkSpeed, error, moveCallBack);
		}
		
		public static function jump(p_char:CCCharacter, p_pos:Point, p_speed:Number=-1, 
									p_max_dis:Number=-1, p_vars:Object=null):void {
			Jump.jump(p_char, p_pos, p_speed, p_max_dis, p_vars);
		}
		
		public static function lineTo(p_char:CCCharacter, p_pos:Point, p_speed:Number, 
									  p_is_pet:Boolean=false, p_vars:Object=null):void {
			Jump.lineTo(p_char, p_pos, p_speed, p_is_pet, p_vars);
		}
		
		public static function lineToPixel(p_char:CCCharacter, p_pos:Point, p_speed:Number, 
										   p_callback:Function=null):void {
			Jump.lineToPixel(p_char, p_pos, p_speed, p_callback);
		}
	}
}