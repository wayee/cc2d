package wit.utils
{
	/**
	 * 数组工具类
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class array
	{
		public static function Each(arr:Array, operation:Function):void {
			for (var i:int=0; i<arr.length; i++) {
				operation(arr[i]);
			}
		}
		
		/**
		 * 设置一个数组的大小
		 * @param arr 数组对象
		 * @param size 新的长度值
		 */
		public static function SetSize(arr:Array, size:int):void {
			if (size < 0) size = 0;
			if (size == arr.length) {
				return;
			}
			if(size > arr.length) {
				arr[size - 1] = undefined;
			} else {
				arr.splice(size);
			}
		}
		
		/**
		 * 删除数组中第一个值等于指定对象的元素，并返回元素的索引 
		 * @param arr 数组对象
		 * @param obj 需要删除的对象
		 * @return int 索引值
		 */
		public static function RemoveFromArray(arr:Array, obj:Object):int {
			for(var i:int=0; i<arr.length; i++){
				if(arr[i] == obj){
					arr.splice(i, 1);
					return i;
				}
			}
			return -1;
		}
		
		/**
		 * 删除数组中的所有值等于指定的对象的元素 
		 * @param arr 数组对象
		 * @param obj 需要删除的对象值
		 */
		public static function RemoveAllFromArray(arr:Array, obj:Object):void {
			for (var i:int=0; i<arr.length; i++) {
				if(arr[i] == obj){
					arr.splice(i, 1);
					i--;
				}
			}
		}
		
		/**
		 * 删除数组某个索引后面的元素
		 * @param array 数组对象
		 * @param index 索引值
		 */
		public static function RemoveAllBehindSomeIndex(array:Array, index:int):void {
			if (index <= 0) {
				array.splice(0, array.length);
				return;
			}
			var arrLen:int = array.length;
			for (var i:int=index+1; i<arrLen; i++) {
				array.pop();
			}
		}
		
		/**
		 * 返回数组中的最大值 
		 * @param arr 数组对象
		 * @return number
		 */
		public static function Max(arr:Array):Number {
			var len:int = arr.length;
			var max:Number = 0;
			for (var i:int=0; i<len; i++) {
				if (i==0) {
					max = Number(arr[i]);
					continue;
				} 
				if (Number(arr[i]) > max) max = arr[i];
			}
			return max;
		}
		
		/**
		 * 返回数组中的最小值 
		 * @param arr 数组对象
		 * @return number
		 */
		public static function Min(arr:Array):Number {
			var len:int = arr.length;
			var min:Number = 0;
			for (var i:int=0; i<len; i++) {
				if (i==0) {
					min = Number(arr[i]);
					continue;
				}
				if (Number(arr[i]) < min) min = arr[i];
			}
			return min;
		}
		
		/**
		 * 克隆数组 
		 * @param arr 数组对象
		 * @return array 克隆后的数组
		 */
		public static function Clone(arr:Array):Array {
			return arr.concat();
		}
		
		/**
		 * 对象是否为数组 
		 * @param value 需要检查的对象
		 * @return bool
		 */
		public function IsArray(value:*):Boolean {
			var g:String = value.constructor.toString();
			if (g.match(/function Array()/)) {
				return true;
			}
			return false;
		}
		
		/**
		 * 对象是否为数组，参考underscore.js的实现
		 * @param value 对象
		 * @return bool
		 */
		public static function IsArray2(value:*):Boolean {
			var ObjProto:* = Object.prototype;
			var toString:Function = ObjProto.toString;
			
			return toString.call(value) == '[object Array]';
		} 
		
		public function array() {    
			throw new Error("ArrayUtil class is static class only");    
		}
		
	}
}