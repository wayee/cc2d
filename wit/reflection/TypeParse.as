package wit.reflection
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * 获取类详细信息并缓存到 typeCache 对象(typeCache[className])
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class TypeParse
	{
		
		// 缓存已经反射过了的对象
		private static var typeCache:Object = new Object();
		
		public function TypeParse()
		{
			throw new Error('This is a static class.');
		}
		
		/**
		 * 获取类信息
		 * @param target 要获取的目标对象
		 * @return TypeDescriptorEntry 实例
		 */
		public static function describeType(target:*):TypeVo
		{
			
			var className:String = getQualifiedClassName(target);			
			
			// 检查缓存中是否已经有目标对象项, 如果有就返回缓存中的内容
			if (className in typeCache)
				return typeCache[className];
			
			
			// 暂存属性列表
			var propertyNames:Array = [];
			var constNames:Array = [];
			var methodNames:Array = [];
			
			// 获取类信息, 如果传入的是实例则获取实例类型的类信息
			var typeInfo:XML = flash.utils.describeType(target is Class ? target : getDefinitionByName(className) as Class);
			
			// 常量
			var consts:XMLList = typeInfo..constant;
			
			// 方法
			var methods:XMLList = typeInfo..method;
			
			// 获取类中所有的属性和访问器
			var properties:XMLList = typeInfo.factory..accessor.(@access != "writeonly") + typeInfo..variable;
			
			
			// 遍历并存放到 propertyNames 中
			for each (var propertyInfo:XML in properties)
			propertyNames.push(propertyInfo.@name);
			
			if (consts) {
				for each (var constInfo:XML in consts)
				constNames.push(constInfo.@name);
			}
			if (methods) {
				for each (var methodInfo:XML in methods)
				methodNames.push(methodInfo.@name);
			}
			
			
			// 创建 TypeDescriptorEntry 的实例并把 propertyNames 等属性丢进去
			var entry:TypeVo = new TypeVo();
			entry.name = className;
			entry.properties = propertyNames;
			entry.consts = constNames.sort();
			entry.methods = methodNames;
			entry.typeInfo = typeInfo;
			
			
			// 缓存到 typeCache 中以便下次从缓存中读取
			typeCache[className] = entry;
			
			return entry;
		}
	}
}