package wit.reflection
{
	/**
	 * 反射 VO
	 * 反射后存储分析后的数据，如常量、属性、方法等。
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class TypeVo
	{
		
		// 类的属性列表, 包括访问器 (accessor) 和变量 (variable)
		public var properties:Array; /* [String, ...] */
		
		// 静态属性
		public var proertiesStatic:Array;
		
		// 类常量
		public var consts:Array;
		
		// 方法
		public var methods:Array;
		
		// 类名
		public var name:String;
		
		// 由 flash.utils.describeType() 获取的原始 XML 数据
		public var typeInfo:XML;
		
		
		public function TypeVo()
		{
		}
		public function echo():void
		{
			trace('typedescription');
		}
	}
}