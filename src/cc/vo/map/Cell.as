package cc.vo.map
{
	import flash.geom.Point;

    public class Cell
	{
        public var zIndex:Number;
        public var i:Number;
        public var j:Number;
        public var k:Number;
		
        public var x:Number;			// x/y 坐标
        public var y:Number;
        public var z:Number;
        public var p:Point;				// x/y 点
		
        public var solid:Boolean = false;
        public var A:Boolean = false;
        public var B:Boolean = false;
        public var C:Boolean = false;
        public var D:Boolean = false;
        public var from:int = 1;
        public var up:Boolean = false;
        public var down:Boolean = false;
        public var left:Boolean = false;
        public var right:Boolean = false;
        public var hasNode:Boolean = false;
        public var path:Object;
        public var npc:String = "";
		
        public var g:Number = 0;				// 已有代价
        public var heuristic:Number = 0;		// 剩余代价
        public var parent:Cell;					// 父节点, 寻径
        public var cost:Number = 0;				// 自身的代价, 如障碍物有较高代价, 不容易被寻径

        public function Cell():void {
            this.path = {};
            super();
        }

		public function get totalScore():Number {
            return this.g + this.heuristic;
        }
    }
}