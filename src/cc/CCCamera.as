package cc
{
	import cc.CCCharacter;
	import cc.utils.SceneUtil;
	
	import flash.geom.Point;

    public class CCCamera extends CCNode
	{
        private const LIMEN_RATIO:Number = 0.05;				// 阀值率
        private const TWEEN_SPEED:Number = 0.4;

        private var x_limen:int = 200;
        private var y_limen:int = 116;
        private var scene:CCScene;								// 当前场景
        private var followCharacter:CCCharacter;				// 跟随的角色对象
        private var isLocked:Boolean = false;
        private var tileRangeXY:Point;							// 可见块范围
		private var zoneRangeXY:Point;							// 可见族范围

        public function CCCamera(p_scene:CCScene) {
            scene = p_scene;
            UpdateRangeXY();
        }
		
        public function Lock():void {
            isLocked = true;
        }
		
        public function Unlock():void {
            isLocked = false;
        }
		
		public function get TileRangeXY():Point	{
			return tileRangeXY;
		}
		
		public function get ZoneRangeXY():Point {
			return zoneRangeXY;
		}
		
        public function UpdateRangeXY():void {
            tileRangeXY = SceneUtil.GetViewTileRangeXY(scene);
			zoneRangeXY = SceneUtil.GetViewZoneRangeXY(scene);
            x_limen = scene.sceneConfig.width * LIMEN_RATIO;
            y_limen = scene.sceneConfig.height * LIMEN_RATIO;
        }
		
		/**
		 * 对象能被摄像机看到
		 * TileX, TileY是地图中点的位置
		 * tileRangXY是场景内地中点位置
		 */
        public function CanSee(sceneChar:CCCharacter):Boolean {
            return sceneChar.TileX > (TileX - tileRangeXY.x) && 
				sceneChar.TileX < (TileX + tileRangeXY.x) && 
				sceneChar.TileY > (TileY - tileRangeXY.y) && 
				sceneChar.TileY < (TileY + tileRangeXY.y);
        }
		
        public function LookAt(sceneChar:CCCharacter, b:Boolean=false):void {
            followCharacter = sceneChar;
            Run(b);
        }
		
        public function Run(b:Boolean=true):void {
            if (isLocked) {						// 锁定
                return;
            }
            if (followCharacter == null) {			// 无跟随
                return;
            }

			// 将 point 对象从显示对象的（本地）坐标转换为舞台（全局）坐标
            var dstPoint:Point = new Point(followCharacter.PixelX, followCharacter.PixelY);
            dstPoint = scene.localToGlobal(dstPoint);		// scrollRect
			
			var halfWidth:Number = 0;
			var widthDif:Number = 0; 	// 宽度差值
			var xResult:Number = 0;		// 场景的x坐标
			var xDifAvatar:Number = 0;
			var xLimenDif:Number = 0; 
			
			// 地图宽度 > 场景宽度
            if (scene.mapConfig.width > scene.sceneConfig.width) {
                halfWidth = scene.sceneConfig.width * 0.5; 						// 场景宽度的一半
                widthDif = scene.sceneConfig.width - scene.mapConfig.width; 	// 场景宽度-地图宽度
                
				xDifAvatar = halfWidth - dstPoint.x;							// 场景宽度一半 - 角色全局坐标x
				
                if (xDifAvatar > x_limen) {										// 主角在屏幕左侧，而且超过阀值
                    xLimenDif = xDifAvatar - x_limen;							// 正数
                } else {
                    if (xDifAvatar < -x_limen){
                        xLimenDif = xDifAvatar + x_limen;						// 负数
                    }
                }
                xResult = scene.x + xLimenDif;									// 场景CCScene新的 x 位置
                if (xResult < widthDif) {										// 已经到达地图右边界了
                    xResult = widthDif;
                }
                if (xResult > 0){												// 已经到达地图左边界了
                    xResult = 0;
                }
                xDifAvatar = xResult - scene.x;									// 新的偏移值
                if (xDifAvatar != 0) {
                    if (!b) {
                        scene.x = scene.x + xDifAvatar;
                    } else {
                        scene.x = (scene.x + (xDifAvatar * TWEEN_SPEED));		// 地图移动缓冲处理
                    }
                }
            } else {
				// 场景比地图大，地图就直接显示在中间
                halfWidth = scene.mapConfig.width * 0.5;	// 地图宽度的一半
                xResult = (scene.sceneConfig.width - scene.mapConfig.width) / 2;
                if (scene.x != xResult) {
                    scene.x = xResult;
                }
            }
			
			var halfHeight:Number = 0;
			var heightDif:Number = 0;
			var yResult:Number = 0;		// 场景的y坐标
			var yDifAvatar:Number = 0;
			var yLimenDif:Number = 0; 
			// 地图高度 > 场景高度
            if (scene.mapConfig.height > scene.sceneConfig.height) {
                halfHeight = scene.sceneConfig.height * 0.5;
                heightDif = scene.sceneConfig.height - scene.mapConfig.height;
				
                yDifAvatar = halfHeight - dstPoint.y; // 
				
                if (yDifAvatar > y_limen) {
                    yLimenDif = yDifAvatar - y_limen;
                } else {
                    if (yDifAvatar < -y_limen) {
                        yLimenDif = (yDifAvatar + y_limen);
                    }
                }
                yResult = scene.y + yLimenDif;
                if (yResult < heightDif) {
                    yResult = heightDif;
                }
                if (yResult > 0) {
                    yResult = 0;
                }
                yDifAvatar = yResult - scene.y;
                if (yDifAvatar != 0) {
                    if (!b){
                        scene.y = (scene.y + yDifAvatar);
                    } else {
                        scene.y = (scene.y + (yDifAvatar * TWEEN_SPEED));
                    }
                }
            } else {
				// 场景比地图大，地图就直接显示在中间
                halfHeight = scene.mapConfig.height * 0.5;
                yResult = (scene.sceneConfig.height - scene.mapConfig.height) / 2;
                if (scene.y != yResult) {
                    scene.y = yResult;
                }
            }
			
			// 地图或者场景的尺寸的一半做为 pixel坐标，方便计算角色位置是否在摄像机内，see canSee()
            var halfPoint:Point = new Point(halfWidth, halfHeight);
            halfPoint = scene.globalToLocal(halfPoint);
            PixelX = halfPoint.x;		// 必须是 PixelX 公开接口
            PixelY = halfPoint.y;
        }
    }
}