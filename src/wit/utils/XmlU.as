package wit.utils
{
	import flash.utils.describeType;

	/**
	 * XML 工具类
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class XmlU
	{
		public static function xmlDataToVO(xmllist:XMLList, vo:Object):void
		{
			for each (var child:XML in xmllist)
			{
				//trace(child.name() + child);
				if (vo.hasOwnProperty(child.name()))
					vo[child.name()] = child;
			}
		}
		
		/**
		 * 把 xml 中的属性赋予 obj 对象, 返回是否完全匹配
		 * @param xml		xml 内容
		 * @param obj		目标对象
		 * @param checkPM	是否检测 xml 与 obj 的完全匹配性
		 * @return			返回是否成功匹配
		 */
		public static function xmlToObject(xml:XML, obj:Object, checkPM:Boolean=true):Boolean
		{
			var key:Array = new Array;
			var value:Array = new Array;
			
			// 从 xml 中读取数据到 key/value 数组中
			for each(var node:XML in xml.*)
			{
				key.push( String(node.name()) );
				value.push( node );
			}
			
			// 设置对象值, 并返回匹配结果
			return setObjectValue(key, value, obj, checkPM);
		}
		
		/**
		 * 从 obj 中建立属性的 xml 描述
		 * @param obj		被建立的对象
		 * @param nodeName	xml的根节点
		 * @return			返回 xml 描述
		 */
		public static function xmlFromObject(obj : Object, nodeName:String="object"):XML
		{
			// 建立 xml
			var xml:XML = new XML("<" + nodeName + "/>");
			
			// 添加对象 obj 的每个属性到 xml 中
			var desc:XML = describeType(obj);
			for each( var node:XML in desc["variable"])
			{
				var name:String = node.@name;
				var value:Object = obj[ name ];
				
				//
				xml[name] = value;
			}
			
			//
			return xml;
		}
		
		// 从 obj 中建立 URI 编码(encodeURIComponent), 如: "x=3&y=4&name=my%20name"
		// 如果有数组,则以 array_name[0]=value&array_name[1]=value, 数组中仅支持基本类型
		// ignoreDefault 	是否忽略默认值属性
		public static function encodeObject(obj:Object, ignoreDefault:Boolean=false, join_char:String=null):String
		{
			var arr:Array = new Array;		
			var desc:XML = describeType(obj);
			for each( var node:XML in desc["variable"])
			{
				var name:String = node.@name;
				var type:String = node.@type;
				var value:Object = obj[name];
				if(value == null) continue;
				
				var str:String;
				switch(type)
				{
					case "int":
					case "uint":
						if(!ignoreDefault || (value != 0) )
						{
							str = encodeURIComponent( String(value) );
							arr.push( name + "=" + str );
						}
						break;
					
					case "Number":
						if(!ignoreDefault || !isNaN(value as Number) )
						{
							str = encodeURIComponent( String(value) );
							arr.push( name + "=" + str );
						}
						break;
					
					case "String":
						if(!ignoreDefault || value!= null)
						{
							str = encodeURIComponent( String(value) );
							arr.push( name + "=" + str );
						}
						break;
					
					case "Array":
						if(!ignoreDefault || value!=null)
						{
							str = encodeArraySimple(name, value as Array);
							arr.push(str);
						}
						break;
				}
			}
			
			if(join_char == null) join_char = "&";
			return arr.join( join_char );
		}
		
		// 编码基本类型数组
		public static function encodeArraySimple(name:String, array:Array):String
		{
			var arr:Array = new Array;
			const fmt:String = "%s[%d]=%s";
			for(var i:int=0; i<array.length; i++)
			{
				var str:String = encodeURIComponent( String(array[i]) );
//				str = StringTool.printf(fmt, name, i, str);
				arr.push( str );
			}
			return arr.join("&");
		}
		
		
		/**
		 * 从 URI 中解码对象 
		 * @param uri		URI 字符串
		 * @param obj		输出的对象
		 * @param checkPM	是否检测 key 与 obj 的完全匹配性
		 * @return			返回是否成功匹配
		 */
		public static function decodeObject(uri:String, obj:Object, checkPM:Boolean=true):Boolean
		{
			
			var key:Array = new Array;
			var value:Array = new Array;
			
			// 从 uri 中分析数据到 key/value 数组中
			var exp:RegExp = /(.*?)=(.*?)($|&)/g;
			var arr:Array = exp.exec(uri);
			while(arr != null)
			{
				key.push( arr[1] );
				value.push( arr[2] );
				
				arr = exp.exec(uri);
			}
			
			// 设置对象值, 并检测匹配
			return setObjectValue(key, value, obj, checkPM, true);
		}
		
		
		/**
		 * 设置对象的属性
		 * @param key		关键字表
		 * @param value		值表
		 * @param obj		目标对象
		 * @param checkPM	是否检测 key 与 obj 的完全匹配性
		 * @param decode	是否使用 decodeURIComponent 解码字符串类型的值
		 * @return			返回是否成功匹配
		 */
		static private function setObjectValue(key:Array, value:Array, obj:Object, checkPM:Boolean, decode:Boolean=false):Boolean
		{
			var result:Boolean = true;
			
			// 遍历每个 key/value 到 obj 中
			if(key.length != value.length){
				throw new Error('');
				return false;
			}
			
			//
			var num:uint = key.length;
			for(var i:uint=0; i<num; i++)
			{
				var k:String = key[i];
				var v:Object = value[i];
				
				//
				if(obj.hasOwnProperty( k ) )
				{
					// 解码
					if(decode && v is String){
						v = decodeURIComponent(String(v));
					}
					
					// 赋值
					obj[k] = v;
				}
				else if(checkPM)
				{
					trace(XmlU, '', k, '');
					result = false;
				}
			}
			
			// 检测 obj 中的每个属性是否都被设置了
			if(checkPM)
			{
				var desc:XML = describeType( obj );
				for each(var node:XML in desc["variable"])
				{
					k = node.@name;
					if(key.indexOf( k ) < 0)
					{
						trace(XmlU, '', k, '');
						result = false;
					}
				}
			}
			
			return result;
		}
		
		public function XmlU()
		{    
			throw new Error("XMLUtil class is static class only");    
		}  
	}
}