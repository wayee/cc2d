package cc.vo.walk
{
	import flash.geom.Point;
	
	import cc.vo.map.MapTile;
	import cc.walk.PathCutter;

    public class WalkData 
	{
		private static const J:Number = 450;
		private static const crossX:Number = 320;
		private static const crossY:Number = 350;
		private static const K:Number = -41142.8571428571;
		
        public var walk_speed:Number = 140;			// 移动速度, 像素/秒
        public var walk_pathArr:Array;				// 路径数组
        public var walk_targetP:Point;				// 目标点
        public var walk_lastTime:int = 0;			// 上次移动时间点
        public var walk_nextStep:MapTile;			// 下一个块坐标
        public var walk_radian:Number = 0;
        public var walk_standDis:Number = 0;		// 与目标点误差距离
        public var walk_pathCutter:PathCutter;		// 碰撞检测
        public var walk_vars:Object = null;			// 走路参数, 包含: onWalkArrived/onWalkThrough 回调函数
		
		public var jump_maxDis:Number = 625;
		public var jump_targetP:Point;
		public var jump_vars:Object = null;			// 跳跃回调参数
		public var isJumping:Boolean;
		
		public function get jump_speed():Number {
			return (J + (K / (this.walk_speed - (K / J))));
		}
		
        public function clear():void {
            walk_pathArr = null;
            walk_targetP = null;
            walk_lastTime = 0;
            walk_nextStep = null;
            walk_radian = 0;
            walk_standDis = 0;
            if (walk_pathCutter) {
                walk_pathCutter.clear();
            }
            walk_vars = null;
        }
    }
}