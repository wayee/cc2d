package cc.walk
{
	import cc.CCCharacter;
	import cc.CCRender;
	import cc.define.CharAngleType;
	import cc.define.CharStatusType;
	import cc.events.CCEvent;
	import cc.events.CCEventActionWalk;
	import cc.tools.SceneCache;
	import cc.utils.CCG;
	import cc.utils.SceneUtil;
	import cc.vo.map.MapTile;
	import cc.vo.map.SceneInfo;
	import cc.vo.walk.WalkData;
	
	import flash.geom.Point;
	
	import wit.event.EventDispatchCenter;
	import wit.utils.ZMath;

	/**
	 * 运动管理器
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class WalkStep
	{
        private static const floor:Function = Math.floor;
        private static const sin:Function = Math.sin;
        private static const cos:Function = Math.cos;
        private static const sqrt:Function = Math.sqrt;
        private static const abs:Function = Math.abs;
		
        private static const MAX_DIS:Number = sqrt(SceneInfo.TILE_WIDTH * SceneInfo.TILE_WIDTH + SceneInfo.TILE_HEIGHT + SceneInfo.TILE_HEIGHT); // width平方 + height + height = 最大距离 
        private static const TO_RAD:Number = 0.0174532925199433;

		private static var _walkThroughDistance:Number = 0.0;
		
		/**
		 * 移动对象一帧时间
		 * @param sceneChar 场景对象
		 */
        public static function step(sceneChar:CCCharacter):void
		{
            var sceneEvent:CCEvent;
            var passUnit:Array;
            var lastTime:int;
            var interval:Number;	// 时间间隔
            var mapTile:MapTile;
			
			// 如果是死亡, 则清空数据
            if (sceneChar.getStatus() == CharStatusType.DEATH) {
                if (sceneChar == sceneChar.scene.mainChar) {	// 如果是主玩家
                    sceneChar.scene.hideMouseChar();			// 隐藏鼠标对象
                }
                sceneChar.Walkdata.clear();						// 清空数据
                return;
            }
            var walkData:WalkData = sceneChar.Walkdata;
			
			// 如果没有路径, 则结束移动
            if (walkData.walk_pathArr == null || walkData.walk_pathArr.length == 0) {
                if (sceneChar.getStatus() == CharStatusType.WALK) {
                    sceneChar.playTo(CharStatusType.STAND);	// 如果是移动中, 并且不是 MOUNT/NPC_FRIEND 则设置为站立
                }
                return;
            }

			// 计算移动量 frameSpeed
			// 移动速度(160) / 帧速率(24) = 6 距离/帧  => 每帧移动的单位
            var frameSpeed:Number = (walkData.walk_speed / CCG.frameRate);	 // 速度/帧频 = 移动速度/帧
            var nowTime:int = CCRender.nowTime; // 播放器运行到现在的毫秒数
            if (walkData.walk_lastTime != nowTime) { // 上次移动时间 != 当前时间	
                lastTime = walkData.walk_lastTime;
                walkData.walk_lastTime = nowTime;		// 更新 walk_lastTime 
                if (lastTime != 0) {
                    interval = ((nowTime - lastTime) / CCG.stepTime);	// 时间间隔  / 每帧时间 （上次走路时间到现在共多少帧）
                    frameSpeed = (frameSpeed * interval);	// 实际移动量 = (每帧移动量 * 时间 / 每帧时间 )
//					trace('[Log] Walking interval:', interval, 'Moved distance:', frameSpeed);
                }
            }
			
			// 得到移动信息
            var distanceObj:Object = stepDistance(sceneChar, frameSpeed);
            var currentPoint:Point = distanceObj.standPixel;			// 当前坐标点
            var throughTileArr:Array = distanceObj.throughTileArr;		// 被经过的格子
//			trace('currentPoint:', currentPoint.x, currentPoint.y);
			// 得到朝向, 并播放动画
            var angle:Number = ZMath.getTwoPointsAngle(new Point(sceneChar.PixelX, sceneChar.PixelY), currentPoint);	// 目标位置的方向
            var nearAngel:Number = ZMath.getNearAngel((angle - 90));		// 返回最近的角度
            sceneChar.playTo(CharStatusType.WALK, CharAngleType[("ANGEL_" + nearAngel)]);		// ANGEL_0(垂直向下), ANGEL_45, ANGEL_90, ...
			
			// 设置到目标坐标点
            sceneChar.setXY(currentPoint.x, currentPoint.y);
			
			// 遍历每个被经过的格子
            for each (passUnit in throughTileArr) {
				
				// 如果是主对象, 发送消息: 经过
                if (sceneChar == sceneChar.scene.mainChar) {
//                    walkData.walk_pathCutter.walkNext(passUnit[0], passUnit[1]);
                    sceneEvent = new CCEvent(CCEvent.WALK, CCEventActionWalk.THROUGH, [sceneChar, SceneUtil.GetMapTile(passUnit[0], passUnit[1])]);
                    EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
                }
				
				// 回调函数, walkData.walk_vars.onWalkThrough( sceneChar, MapTile);
                if (walkData.walk_vars != null && walkData.walk_vars.onWalkThrough != null) {
                    walkData.walk_vars.onWalkThrough(sceneChar, SceneUtil.GetMapTile(passUnit[0], passUnit[1]));
                }
            }
			
            if (walkData.walk_pathArr == null){
				clearWalkThroughDistance();
                return;
            }
			
			if (sceneChar == sceneChar.scene.mainChar) {
				_walkThroughDistance += frameSpeed;
				if (_walkThroughDistance > walkData.walk_speed) {
					if (walkData.walk_vars != null && walkData.walk_vars.onWalkThroughSecond != null) {
						walkData.walk_vars.onWalkThroughSecond(sceneChar);
					}
//					trace('[Log] Walking through distance for one second:', _walkThroughDistance);
					clearWalkThroughDistance();
					
				}
			}
			
			// 判断移动结束
            if (walkData.walk_pathArr.length == 0) {
                sceneChar.playTo(CharStatusType.STAND);			// 站立状态
                sceneChar.faceToTile(walkData.walk_targetP.x, walkData.walk_targetP.y);	// 设置方向
				
				// 主对象, 发送消息: 到达
                if (sceneChar == sceneChar.scene.mainChar) {
					var obj:Object = SceneCache.mapTiles;
                    mapTile = SceneUtil.GetMapTile(sceneChar.TileX, sceneChar.TileY);
                    sceneChar.scene.hideMouseChar();
//					ZLog.add('WalkStep.step: SceneEventAction_walk.ARRIVED');
                    sceneEvent = new CCEvent(CCEvent.WALK, CCEventActionWalk.ARRIVED, [sceneChar, mapTile]);
                    EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
					
					// 如果是传送门, 发消息: 到达传送门
                    if (mapTile && mapTile.isTransport) {
                        sceneEvent = new CCEvent(CCEvent.WALK, CCEventActionWalk.ON_TRANSPORT, [sceneChar, mapTile]);
                        EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
                    }
					
					clearWalkThroughDistance();
                }
				
				// 回调通知, walkData.walk_vars.onWalkArrived( sceneChar, mapTile) 
                if (walkData.walk_vars != null && walkData.walk_vars.onWalkArrived != null) {
                    walkData.walk_vars.onWalkArrived(sceneChar, SceneUtil.GetMapTile(sceneChar.TileX, sceneChar.TileY));
                }
                walkData.clear();
				
//				var walkArrived:Function;
//				if (walkData.walk_vars != null && walkData.walk_vars.onWalkArrived != null) {
//					walkArrived =  walkData.walk_vars.onWalkArrived;
//					//                    walkData.walk_vars.onWalkArrived(sceneChar, SceneUtil.getMapTile(sceneChar.TileX, sceneChar.TileY));
//				}
//				walkData.clear();
//				if ( walkArrived != null ) walkArrived(sceneChar, SceneUtil.getMapTile(sceneChar.TileX, sceneChar.TileY));
            }
        }
		
		private static function clearWalkThroughDistance():void
		{
			_walkThroughDistance = 0.0;
		}
		
		/**
		 * 把 sceneChar 移动 distance 距离, 并返回 对象: <br>
		 * 	<li> standPixel 新坐标点
		 * 	<li> throughTileArr 已经经过的格子数组. 该格子从 sceneChar 中的  walkData 中删除
		 */
        private static function stepDistance(sceneChar:CCCharacter, distance:Number):Object
		{
            var pathUnit:Array;
            var endPixel:Point;
            var next_distance:Number;
            var passedUnit:Array;
            var resultObj:Object = {
                standPixel:new Point(sceneChar.PixelX, sceneChar.PixelY),		// 当前坐标
                throughTileArr:[]		// 已经经过的格子数组
            };
            var walkData:WalkData = sceneChar.Walkdata;				// 移动数据
            var startPixel:Point = resultObj.standPixel;			// 当前坐标
            var want_distance:Number = distance;					// 移动距离
            var throughTileArray:Array = resultObj.throughTileArr;	// 已经经过的格子
			var tileWidth:int = SceneInfo.TILE_WIDTH;
			var tileHeight:int = SceneInfo.TILE_HEIGHT;
			
            pathUnit = walkData.walk_pathArr[0];	// walk_pathArr = [ [tx,ty], [tx,ty], ... ]
            endPixel = new Point((pathUnit[0] * tileWidth), (pathUnit[1] * tileHeight));		// 块坐标 -> 像素坐标
            next_distance = Point.distance(startPixel, endPixel);	// 到下一个格子的距离
			
			// 距离下一个格子的距离, 大于要移动的距离
            var tmpAngle:Number;
            var tmpDistance:Number;
            if (next_distance > want_distance){		
                tmpDistance = want_distance;
                want_distance = (want_distance - tmpDistance);
                tmpAngle = (ZMath.getTwoPointsAngle(startPixel, endPixel) * TO_RAD);		// 方向角度
                startPixel.x = (startPixel.x + (tmpDistance * cos(tmpAngle)));	// 在该方向上移动
                startPixel.y = (startPixel.y + (tmpDistance * sin(tmpAngle)));
                return resultObj;			// 返回移动信息
            }
			
			// 距离下一个格子的距离, 等于要移动的距离
            if (next_distance == want_distance){
                tmpDistance = want_distance;
                passedUnit = walkData.walk_pathArr.shift();	// 删除一个路径单元
                throughTileArray.push(passedUnit);						// 保存到 已经过路径 中
                want_distance = (want_distance - tmpDistance);
                startPixel.x = (passedUnit[0] * tileWidth);			// 移动到该格子的起始点
                startPixel.y = (passedUnit[1] * tileHeight);
                return resultObj;			// 返回移动信息
            }
			
			// 距离下一个格子的距离, 小于要移动的距离. 
            tmpDistance = next_distance;
            passedUnit = walkData.walk_pathArr.shift();
            throughTileArray.push(passedUnit);
            want_distance = (want_distance - tmpDistance);
            startPixel.x = (passedUnit[0] * tileWidth);
            startPixel.y = (passedUnit[1] * tileHeight);
            if (walkData.walk_pathArr.length == 0) {
                return resultObj;
            }
			return resultObj;
        }
    }
}