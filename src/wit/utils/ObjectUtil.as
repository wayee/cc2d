package wit.utils
{
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * 对象工具类
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class ObjectUtil
	{
		public static function newSibling(sourceObj:Object):*
		{
			if(sourceObj) {
				var objSibling:*;
				try {
					var classOfSourceObj:Class = getDefinitionByName(getQualifiedClassName(sourceObj)) as Class;
					objSibling = new classOfSourceObj();
				}
				catch(e:Object) {}
				
				return objSibling;
			}
			return null;
		}
		
		public static function clone(source:Object):Object
		{
			var clone:Object;
			if(source) {
				clone = newSibling(source);
				
				if(clone) {
					copyData(source, clone);
				}
			}
			
			return clone;
		}
		
		public static function copyData(source:Object, destination:Object):void
		{
			//copies data from commonly named properties and getter/setter pairs
			if(source && destination) {
				try {
					var sourceInfo:XML = describeType(source);
					var prop:XML;
					
					for each(prop in sourceInfo.variable) {
						if(destination.hasOwnProperty(prop.@name)) {
							destination[prop.@name] = source[prop.@name];
						}
					}
					
					for each(prop in sourceInfo.accessor) {
						if(prop.@access == "readwrite") {
							if(destination.hasOwnProperty(prop.@name)) {
								destination[prop.@name] = source[prop.@name];
							}
						}
					}
				}
				catch (err:Error) {
				}
			}
		}
		
		/**
		 * Deep clone object using thiswind@gmail.com 's solution
		 */
		public static function baseClone(source:*):*
		{
			var typeName:String = getQualifiedClassName(source);
			var packageName:String = typeName.split("::")[1];
			var type:Class = Class(getDefinitionByName(typeName));
			
			registerClassAlias(packageName, type);
			
			var copier:ByteArray = new ByteArray();
			copier.writeObject(source);
			copier.position = 0;
			return copier.readObject();
		}
		
		/**
		 * Checks wherever passed-in value is <code>String</code>.
		 */
		public static function isString(value:*):Boolean
		{
			return ( typeof(value) == "string" || value is String );
		}
		
		/**
		 * Checks wherever passed-in value is <code>Number</code>.
		 */
		public static function isNumber(value:*):Boolean
		{
			return ( typeof(value) == "number" || value is Number );
		}
		
		/**
		 * Checks wherever passed-in value is <code>Boolean</code>.
		 */
		public static function isBoolean(value:*):Boolean
		{
			return ( typeof(value) == "boolean" || value is Boolean );
		}
		
		/**
		 * Checks wherever passed-in value is <code>Function</code>.
		 */
		public static function isFunction(value:*):Boolean
		{
			return ( typeof(value) == "function" || value is Function );
		}
		
		public function ObjectUtil()
		{    
			throw new Error("ObjectUtils class is static class only");    
		}  
	}
}