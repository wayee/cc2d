package cc.helper
{
	import cc.CCCharacter;
	import cc.define.CharStatusType;
	import cc.events.CCEvent;
	import cc.events.CCEventActionWalk;
	import cc.tools.SceneCache;
	import cc.utils.SceneUtil;
	import cc.utils.Transformer;
	import cc.vo.map.MapTile;
	import cc.utils.AStar;
	import cc.walk.Jump;
	
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import wit.event.EventDispatchCenter;

	/**
	 * 走路帮助类 
	 */
	public class WalkHelper
	{
		/**
		 * 停止走路 
		 * @param p_char 角色对象
		 * @param b 是否站立
		 */
		public static function stopWalk(p_char:CCCharacter, b:Boolean=true):void
		{
			p_char.Walkdata.clear();
			if (p_char == p_char.scene.mainChar) {
				p_char.scene.hideMouseChar();
			}
			
			if (b) p_char.setStatus(CharStatusType.STAND);
		}
		
		/**
		 * 反转路径 
		 * @param p_char
		 */
		public static function reviseWalkPath(p_char:CCCharacter):void
		{
			if (p_char == p_char.scene.mainChar) { // 主角
				if (p_char.avatar.status == CharStatusType.WALK) { // 正在走路
					if (p_char.Walkdata.walk_targetP != null) { // 目标点不为空
						walk(p_char, p_char.Walkdata.walk_targetP, -1, 
							p_char.Walkdata.walk_standDis, p_char.Walkdata.walk_vars);
					} else {
						p_char.Walkdata.clear();
					}
				}
			} else {
				p_char.Walkdata.clear();
			}
		}

		/**
		 * 走路 
		 * @param p_char 角色对象
		 * @param targetTilePoint 目标点, tx, ty
		 * @param walkSpeed
		 * @param error 当前位置到目标点可接受的误差值
		 * @param walkVars 回调onWalkArrived, onWalkThrough, onWalkUnable
		 */
		public static function walk(p_char:CCCharacter, targetTilePoint:Point, 
									walkSpeed:Number=-1, error:Number=0, walkVars:Object=null):void
		{
			var sceneEvent:CCEvent;
			
			// 不可到达的点
			var mapTile:MapTile = SceneCache.mapTiles[targetTilePoint.x + "_" + targetTilePoint.y];
			if (mapTile == null) {
				if (p_char.isMainChar()) {
					p_char.scene.hideMouseChar();
					sceneEvent = new CCEvent(CCEvent.WALK, CCEventActionWalk.UNABLE, [p_char, mapTile]);
					EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
				}
				if (walkVars != null && walkVars.onWalkUnable != null) { // “不可到达”回调
					walkVars.onWalkUnable(p_char, mapTile);
				}
				return;
			}
			p_char.Walkdata.clear();
			
			// 已经到达目标点
			if (p_char.TileX == targetTilePoint.x && p_char.TileY == targetTilePoint.y) {
				if (p_char == p_char.scene.mainChar) {
					p_char.scene.hideMouseChar();
					sceneEvent = new CCEvent(CCEvent.WALK, CCEventActionWalk.ARRIVED, [p_char, mapTile]);
					EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
				}
				if (walkVars != null && walkVars.onWalkArrived != null) { // “到达”回调
					walkVars.onWalkArrived(p_char, mapTile);
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
						p_char.scene.hideMouseChar();
						mapTile = SceneCache.mapTiles[p_char.TileX + "_" + p_char.TileY];
						sceneEvent = new CCEvent(CCEvent.WALK, CCEventActionWalk.ARRIVED, [p_char, mapTile]);
						EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
					}
					if (walkVars != null && walkVars.onWalkArrived != null) {
						walkVars.onWalkArrived(p_char, mapTile);
					}
					return;
				}
			}
			
			// 角色当前位置是不可到达
			var currentPosTile:MapTile = SceneCache.mapTiles[p_char.TileX + "_" + p_char.TileY];
			mapTile = SceneUtil.GetRoundMapTile(currentPosTile, mapTile);
			if (mapTile == null) {
				p_char.faceToTile(targetTilePoint.x, targetTilePoint.y);
				if (p_char == p_char.scene.mainChar) {
					p_char.scene.hideMouseChar();
					sceneEvent = new CCEvent(CCEvent.WALK, CCEventActionWalk.UNABLE, [p_char, mapTile]);
					EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
				}
				if (walkVars != null && walkVars.onWalkUnable != null) {
					walkVars.onWalkUnable(p_char, mapTile);
				}
				return;
			}
			
			
			var walkPaths:Array = [];
			var isIsland:Boolean = mapTile.isIsland;
			if (isIsland) { // 目标点是孤立的
				walkPaths = AStar.search(SceneCache.mapSolids, mapTile.TileX, mapTile.TileY, p_char.TileX, p_char.TileY);
			} else {
				walkPaths = AStar.search(SceneCache.mapSolids, p_char.TileX, p_char.TileY, mapTile.TileX, mapTile.TileY);
			}
			
			if (walkPaths == null || walkPaths.length < 2) { // 目标点就在当前位置
				p_char.faceToTile(targetTilePoint.x, targetTilePoint.y);
				if (p_char == p_char.scene.mainChar) {
					p_char.scene.hideMouseChar();
					sceneEvent = new CCEvent(CCEvent.WALK, CCEventActionWalk.UNABLE, [p_char, mapTile]);
					EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
				}
				if (walkVars != null && walkVars.onWalkUnable != null) {
					walkVars.onWalkUnable(p_char, mapTile);
				}
				return;
			}
			
			if (!isIsland) { // 非孤立的
				walkPaths = walkPaths.reverse(); // 路径反转
			}
			
			var tilePoint:Array;
			var lastTilePoint:Array = walkPaths[walkPaths.length - 1];
			var pixelPoint:Point;
			if (error != 0) {
				for each (tilePoint in walkPaths) { // tilePoint[0] = tx, tilePoint[1] = ty
					// 转换为像素点
					pixelPoint = Transformer.transTilePoint2PixelPoint(new Point(tilePoint[0], tilePoint[1]));
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
			walk0(p_char, walkPaths, targetTilePoint, walkSpeed, error, walkVars);
		}
		
		/**
		 * 这个才是真正的计算好所有走路的数据，然后更新到SceneCharacter.Walkdata
		 * 在WalkStep.step()及根据Walkdata来执行走路 
		 * @param p_char 场景角色
		 * @param walkPaths A* 计算后的路径数据 [[tx, ty], [tx, ty], ...]
		 * @param targetTilePoint 目标, tx, ty
		 * @param walkSpeed 走路速度
		 * @param error 误差
		 * @param walkVars 回调函数表 onWalkArrived/onWalkThrough
		 */
		public static function walk0(p_char:CCCharacter, walkPaths:Array, 
									 targetTilePoint:Point=null, walkSpeed:Number=-1, 
									 error:Number=0, walkVars:Object=null):void
		{
			var sceneEvent:CCEvent;
			
			if (walkPaths.length < 1) {	// < 2表示包括现在位置， < 1则不包括
				return;
			}
			var pathData:Array = walkPaths;
			p_char.Walkdata.clear();
			
			if (p_char == p_char.scene.mainChar) {
				// 移动优化
//				if (p_char.Walkdata.walk_pathCutter == null){
//					p_char.Walkdata.walk_pathCutter = new PathCutter(p_char);
//				}
//				p_char.Walkdata.walk_pathCutter.cutMovePath(pathData);
//				p_char.Walkdata.walk_pathCutter.walkNext(-1, -1);
			}
			
			// 设置走路速度
			if (walkSpeed >= 0) {
				p_char.setSpeed(walkSpeed);
			}
			
			// 设置目标点
			var lastPoint:Array;
			if (targetTilePoint != null) {
				p_char.Walkdata.walk_targetP = targetTilePoint;
			} else { // 没设定就使用走路路径的最后一点
				lastPoint = pathData[pathData.length - 1];
				p_char.Walkdata.walk_targetP = new Point(lastPoint[0], lastPoint[1]);
			}
			
			p_char.Walkdata.walk_standDis = error;
			p_char.Walkdata.walk_vars = walkVars;
			
			// 删除起点
//			var firstPoint:Array = pathData.shift();
//			if (p_char.TileX != firstPoint[0]) {
//				p_char.TileX = firstPoint[0];
//			}
//			if (p_char.TileY != firstPoint[1]) {
//				p_char.TileY = firstPoint[1];
//			}
			p_char.Walkdata.walk_pathArr = pathData;
			
			var lastPoint2:Array = pathData[pathData.length - 1];
			var lastPointMapTile:MapTile = SceneCache.mapTiles[lastPoint2[0] + "_" + lastPoint2[1]];
			if (p_char.isMainChar()) {
				p_char.scene.showMouseChar(lastPoint2[0], lastPoint2[1]);
				sceneEvent = new CCEvent(CCEvent.WALK, CCEventActionWalk.READY, [p_char, lastPointMapTile, pathData]);
				EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
			}
			if (walkVars != null && walkVars.onWalkReady != null) {
				walkVars.onWalkReady(p_char, lastPointMapTile);
			}
		}
		
		public static function walk1(p_char:CCCharacter, pathByteData:ByteArray, targetTilePoint:Point=null, walkSpeed:Number=-1, error:Number=0, walkVars:Object=null):void
		{
//			var arr:Array = PathConverter.convertToPoint(pathByteData);
//			walk0(p_char, arr, targetTilePoint, walkSpeed, error, walkVars);
		}
		
		public static function jump(p_char:CCCharacter, p_pos:Point, p_speed:Number=-1, p_max_dis:Number=-1, p_vars:Object=null):void {
			Jump.jump(p_char, p_pos, p_speed, p_max_dis, p_vars);
		}
		
		public static function lineTo(p_char:CCCharacter, p_pos:Point, p_speed:Number, p_is_pet:Boolean=false, p_vars:Object=null):void {
			Jump.lineTo(p_char, p_pos, p_speed, p_is_pet, p_vars);
		}
		
		public static function lineToPixel(p_char:CCCharacter, p_pos:Point, p_speed:Number, p_callback:Function=null):void {
			Jump.lineToPixel(p_char, p_pos, p_speed, p_callback);
		}
	}
}