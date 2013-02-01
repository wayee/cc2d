package wit.utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;

	/**
	 * 数学计算辅助
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class math
	{
        private static var abs:Function = Math.abs;
        private static var sin:Function = Math.sin;
        private static var cos:Function = Math.cos;
        private static var sqrt:Function = Math.sqrt;
        private static var PI:Number = Math.PI;
        public static var toDeg:Number = (180 / PI); // 角度 degree
        public static var toRad:Number = (PI / 180); // 弧度 radian

		/**
		 * 获取两个数间的随机数 
		 */
        public static function getRandomNumber(min:Number, max:Number):Number
		{
            return Math.floor((Math.random() * (max - min) + 1) + min);
        }
		
		/**
		 * 获取两点间的距离平方值 
		 */
        public static function getDistanceSquare(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
            return (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2);
        }
		
        public static function getRotPoint(pos1:Point, pos2:Point, angle:Number):Point
		{
            angle = angle * math.toRad;
            var target:Point = new Point();
            target.x = Math.cos(angle) * (pos1.x - pos2.x) - Math.sin(angle) * (pos1.y - pos2.y) + pos2.x;
            target.y = Math.sin(angle) * (pos1.x - pos2.x) + Math.cos(angle) * (pos1.y - pos2.y) + pos2.y;
            
			return target;
        }
		
		public static function getOffsetRange(w:Number, h:Number, rotation:Number):Point
		{
			var offsetX:Number = 0;
			var offsetY:Number = 0;
			
			if (rotation < 0) rotation = 360 - (-rotation) % 360;
			if (rotation > 360) rotation = rotation % 360;
			
			var radian:Number = rotation * Math.PI / 180; // 弧度
			
			if (rotation >= 0 && rotation <= 90) {
				offsetX = Math.sin(radian) * h;
			} else if (rotation > 90 && rotation <= 180) {
				offsetX = Math.abs(Math.sin(radian)) * h + Math.abs(Math.cos(radian)) * w;
				offsetY = Math.cos(radian) * h;
			} else if (rotation > 180 && rotation <= 270) {
				offsetX = Math.cos(radian) * w;
				var c:Number = w / Math.abs(Math.tan(radian));
				offsetY = w / Math.abs(Math.sin(radian)) + (h-c) * Math.abs(Math.cos(radian));
			} else if (rotation > 270 && rotation <= 360) {
				offsetY = Math.sin(radian) * w;
			}
//			trace("rotation, offsetX, offsetY", rotation, offsetX, offsetY);
			return new Point(Math.abs(offsetX), Math.abs(offsetY));
		}
		
		/**
		 * 返回两点间的角度, 角度值
		 */
        public static function getTwoPointsAngle(pt1:Point, pt2:Point):Number
		{
            var angle:Number = Math.atan2(pt2.y - pt1.y, pt2.x - pt1.x);
            if (angle < 0) {
                angle = angle + (2 * Math.PI);
            }
            return (angle * 180) / Math.PI;
        }
		
		/**
		 * 得到最近的角度
		 * @param angle 输入角度
		 * @param num 圆周划分角度的个数, 例如划分为8个, 则每个角度45度, 则最近角度必须是45度的倍数
		 * @return 返回 0, 45, 90 等最近角度
		 */
        public static function getNearAngel(angle:Number, num:int=8):int
		{
            angle = (angle % 360 + 360) % 360;
            var unit:Number = (360 / num);
            var pos:int = Math.floor(angle / unit);
            var targetPos:Number = (pos * unit);
            var nextPos:Number = ((pos + 1) * unit);
            return (angle - targetPos) <= (nextPos - angle) ? targetPos : nextPos % 360;
        }
		
		/**
		 * 将数值限制在一个区间内
		 * 
		 * @param v	数值
		 * @param min	最大值
		 * @param max	最小值
		 * 
		 */		
		public static function limitIn(v:Number, min:Number, max:Number):Number
		{
			return Math.min(Math.max(v, min), max);
		}
		
		/**
		 * 返回的是数学意义上的atan（坐标系与Math.atan2上下颠倒）
		 * 
		 * @param dx
		 * @param dy
		 * @return 
		 * 
		 */
		public static function atan2(dx:Number, dy:Number):Number
		{
			var a:Number;
			if (dx == 0) 
				a = Math.PI/2;
			else if (dx > 0) 
				a = Math.atan(Math.abs(dy/dx));
			else
				a = Math.PI - Math.atan(Math.abs(dy/dx));
			
			if (dy >= 0) 
				return a;
			else 
				return -a;
			
		}
		
		/**
		 * 求和
		 * 
		 * @param arr
		 * @return 
		 * 
		 */
		public static function sum(arr:Array):Number
		{
			var result:Number = 0.0;
			for each (var num:Number in arr)
			result += num;
			return result;
		}
		
		/**
		 * 平均值
		 *  
		 * @param arr
		 * @return 
		 * 
		 */
		public static function avg(arr:Array):Number
		{
			return sum(arr)/arr.length;
		}
		
		/**
		 * 最大值
		 * 
		 * @param arr
		 * @return 
		 * 
		 */
		public static function max(arr:Array):Number
		{
			var result:Number = NaN;
			for (var i:int = 0;i < arr.length;i++)
			{
				if (isNaN(result) || arr[i] > result)
					result = arr[i];
			}
			return result;
		}
		
		/**
		 * 最小值
		 * 
		 * @param arr
		 * @return 
		 * 
		 */
		public static function min(arr:Array):Number
		{
			var result:Number = NaN;
			for (var i:int = 0;i < arr.length;i++)
			{
				if (isNaN(result) || arr[i] < result)
					result = arr[i];
			}
			return result;
		}
    }
}