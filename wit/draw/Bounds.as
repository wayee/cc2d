package wit.draw
{
	import flash.geom.Rectangle;

	/**
	 * 类似一个 Rectangle 对象
	 */
    public class Bounds 
	{

        private static const max:Function = Math.max;
        private static const min:Function = Math.min;

        public var left:Number;
        public var right:Number;
        public var top:Number;
        public var bottom:Number;
		
		/**
		 * 宽度 
		 */
		public function get width():Number
		{
			return right - left;
		}
		
		/**
		 * 高度 
		 */
		public function get height():Number
		{
			return bottom - top;
		}

        public function Bounds(left:Number=0, right:Number=0, top:Number=0, bottom:Number=0)
		{
            this.left = left;
            this.right = right;
            this.top = top;
            this.bottom = bottom;
        }
		
		/**
		 * Bounds to Rectangle 
		 */
        public static function toRectangle(bound:Bounds):Rectangle
		{
            return new Rectangle(bound.left, bound.top, bound.right - bound.left, bound.bottom - bound.top);
        }
		
		/**
		 * Rectangle to Bounds 
		 */
        public static function fromRectangle(rect:Rectangle):Bounds
		{
            return new Bounds(rect.left, rect.right, rect.top, rect.bottom);
        }

		/**
		 * 是一条线
		 */
        public function isLine():Boolean
		{
            return this.right == this.left || this.bottom == this.top;
        }
		
		/**
		 * 是一个点
		 */
        public function isPoint():Boolean
		{
            return this.right == this.left && this.bottom == this.top;
        }
		
		/**
		 * 面积 
		 */
        public function areaSize():Number
		{
            return ((this.right - this.left) + 1) * ((this.bottom - this.top) + 1);
        }
		
        public function contains(bound:Bounds):Boolean
		{
            return bound.left >= this.left && bound.right <= this.right && 
				bound.top >= this.top && bound.bottom <= this.bottom;
        }
		
        public function equals(bound:Bounds):Boolean
		{
            return bound.left == this.left && bound.right == this.right && 
				bound.top == this.top && bound.bottom == this.bottom;
        }
		
        public function intersects(bound:Bounds):Boolean
		{
            var left1:Number = max(this.left, bound.left);
            var right1:Number = min(this.right, bound.right);
            var top1:Number = max(this.top, bound.top);
            var bottom1:Number = min(this.bottom, bound.bottom);
            if (left1 <= right1 && top1 <= bottom1) {
                return true;
            }
            return false;
        }
		
        public function intersection(bound:Bounds):Bounds
		{
            var left1:Number = max(this.left, bound.left);
            var right1:Number = min(this.right, bound.right);
            var top1:Number = max(this.top, bound.top);
            var bottom1:Number = min(this.bottom, bound.bottom);
            if (left1 <= right1 && top1 <= bottom1) {
                return new Bounds(left1, right1, top1, bottom1);
            }
            return null;
        }
		
        public function union(bound:Bounds):Bounds
		{
            var left1:Number = min(this.left, bound.left);
            var right1:Number = max(this.right, bound.right);
            var top1:Number = min(this.top, bound.top);
            var bottom1:Number = max(this.bottom, bound.bottom);
            return new Bounds(left1, right1, top1, bottom1);
        }
		
        public function extend(bound:Bounds):void
		{
            this.left = min(this.left, bound.left);
            this.right = max(this.right, bound.right);
            this.top = min(this.top, bound.top);
            this.bottom = max(this.bottom, bound.bottom);
        }
    }
}