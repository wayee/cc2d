package wit.utils
{
	import com.adobe.serialization.json.JSON;
	
	import flash.system.ApplicationDomain;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	import wit.reflection.Reflection;
	
	/**
	 * JSON, XML 解析器
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class ObjectParser
	{
		public static const NAME:String = "ObjectParser";
		
		public static const classMap:Object = {};
		
		public static function loopObjectVals(obj:Object):void{
			for(var i:Object in obj){
//				trace("propName:"+i+", type:"+typeof(obj[i])+", value:"+obj[i]);
				if(typeof(obj[i])=='object') {
					loopObjectVals(obj[i]);
				}
				
			}
			
		}
		/**
		 * 将对象列表转换为对象的数组列表
		 *  
		 * @param json
		 * @param vo
		 * @param members
		 * @param strict
		 * @return array
		 * 
		 */
		public static function parseJSONToVoList(json:Object, voClass:Class, members:Object=null, strict:Boolean=false):Array
		{
			var list:Array = new Array;
			
			for each (var value:Object in json) {
				list.push(parseJSONToVo(value, voClass, strict));
			}
			
			return list;
		}
		
		/**
		 * JSON 对象转换为具体的  VO
		 * 
		 * @param json object
		 * @param vo Class
		 * @param members array(Class, ...) 成员里面还有其他vo
		 * @param strict
		 * @return object
		 * 
		 */
		public static function parseJSONToVo(json:Object, voClass:Class, strict:Boolean=false, jsonDecodeObj:Boolean=true):Object
		{
			var obj:Object = new (voClass);
			
			var desc:XMLList = describeType( obj )["variable"];
			
			for each(var prop:XML in desc)
			{
				var propName:String = prop.@name;			// 变量名
				var propType:String = prop.@type;			// 变量类型
				var vClass:Class;
				
				if ( !json.hasOwnProperty(propName) ) continue;
				
				switch(propType)
				{
					case "Boolean":
					case "int":
					case "uint":
					case "String":
					case "Number":
						obj[propName] = json[propName];
						break;
					
					case "Array":
						if ( !obj['memberMap'] || typeof(obj['memberMap']) != 'object') {
							throw new Error(I18n.get(obj + 'must contain a property memberMap.'));
						}
						vClass = obj['memberMap'][propName];
						if (vClass) {
							var arr:Array = parseJSONToVoList(json[propName], vClass, obj['memberMap']);
							obj[propName] = arr;
						} else {
							obj[propName] = json[propName]; 
						}
						break;
					
					// 对象
					default:
						vClass = getVoClass(propType);
						if(vClass != null)
							obj[propName] = parseJSONToVo(json[propName], vClass);
						else
							if( jsonDecodeObj ){
								if (json[propName]) {
									obj[propName] = JSON.decode(json[propName]);
								}
							}
							else{
								obj[propName] = json[propName];
							}
						break;
				}
			}
			return obj;
		}
		
		/**
		 * 直接根据 descibeType 中的 @name 做反射获取Class对象 
		 * @param className
		 * @return 反射后的 Class
		 * 
		 */
		private static function getVoClass(className:String):Class
		{
			if (className === 'Object') return null;
			
			var tClass:Class = Reflection.getClass(className);
			if (tClass == null) {
				throw new Error('ObjectParser.getVoClass: class '+className+'couldn\'t be found.');
			}
			
			return tClass;
		}
		
		/**
		 * 从 XMLList 中解析数组, 数组元素类型为 tClass(其中只能包含基本数据类型的字段)
		 * 
		 * @param xml			xml 源
		 * @param tClass		数组元素的数据类型, 支持: int, uint, String
		 * @param strictMode	严格模式, 当 xml 中不包含对应的字段时, 返回 null
		 * @return				由 tClass 实例构成的对象列表
		 */
		public static function parseList(xml:XMLList, tClass:Object, strictMode:Boolean=false):Array
		{
						
			// 得到属性描述
			var desc:XMLList = describeType(new (tClass))["variable"];
			var list:XMLList;
			const LEN:int = xml.length();
						
			// 建立对象数组 arr
			var arr:Array = new Array;
			for each(var key:XML in desc)
			{
				// 设置属性名 name 上的值
				var name:String = key.@name;
				var type:String = key.@type;
				
				// 得到该属性名对应的 xml 值列表
				list = xml[name];
				if(list == null){
					if(strictMode) return null;		// 严格模式, 错误	
					else continue;					// 忽略
				}
				if(list.length() != LEN){
					trace();
				}
				
				// 根据类型设置值
				switch(type)
				{
					case "int":
					case "uint":
					case "String":
					{
						// 遍历值列表, 设置到每个数组元素的name属性上
						var len:uint = list.length();
						for(var i:int=0; i<len; i++)
						{
							// 首次设置时建立对象
							if(arr[i] == null) arr[i] = new tClass;
							
							// 设置 name 属性值
							arr[i][name] = list[i];
						}
					}
					break;
					
					case "Object":
					break;
					
					case "Array":
					break;
				}
				
				continue;
			}
			
			return arr;
		}
		
		
		
		/**
		 * 从 XMLList 中解析对象, 对象可以包含 Array 成员
		 * 
		 * @param xml			xml 源
		 * @param tClass		vo 的数据类型, 支持: int, uint, String, Array
		 * @param strictMode	严格模式, 当 xml 中不包含对应的字段时, 返回 null
		 * @param arrClassMap	当 tClass 中包含 Array 属性时, 表示从 变量名 到 类型 的映射
		 * @param arrNameMap	当 tClass 中包含 Array 属性时, 表示从 变量名 到 xml节点名 的映射
		 * @return				tClass 实例
		 */
		public static function parseObject(xml:XMLList, tClass:Class, strictMode:Boolean=false, arrClassMap:Object=null, arrNameMap:Object=null):Object
		{
			
			// 得到属性描述
			var obj:Object = new tClass;
			var desc:XMLList = describeType(obj)["variable"];
			var list:XMLList;
						
			// 设置 obj 的每个属性
			for each(var key:XML in desc)
			{
				// 设置属性名 name 上的值
				var name:String = key.@name;
				var type:String = key.@type;
				
				// 得到该属性名对应的 xml 值列表
				list = xml[name];
				if(list == null){
					if(strictMode) return null;		// 严格模式, 错误	
					else continue;					// 忽略
				}
				
				// 根据类型设置值
				switch(type)
				{
					case "int":
					case "uint":
					case "String":
					{
						obj[name] = list;
					}
					break;
										
					case "Array":
					{
						// 得到节点名 nodeName, 当数组数据位于 xml 的 .. 层次时
						var nodeName:String = (arrNameMap!=null? arrNameMap[name]: null);
						var t:XMLList = (nodeName!=null? list[nodeName]: list);		// 进入子层次
						
						// 得到类型
						var tClass:Class = (arrClassMap!=null? arrClassMap[name]: null);
						
						if(tClass!=null && t!=null){
							obj[name] = parseList(t, tClass, strictMode);
						}
					}
					break;
				}
				
				continue;
			}
			
			return obj;
		}

		/**
		 * 解析单个对象
		 * ignoreProps = 忽略的属性名列表
		 * 
		 * @param xml
		 * @param tClass
		 * @param ignoreProps
		 * @return Object
		 * 
		 */
		public static function parseUniObject(xml:Object, tClass:Class, ignoreProps:Array=null):Object
		{
			if(xml is XMLList) xml = xml[0];		// 调整到子结点
			if(xml == null) return null;
//			if(! (xml is XML) ) return null;
			
			var obj:Object = new (tClass);
			var desc:XMLList = flash.utils.describeType( obj )["variable"];
						
			// 设置 obj 的每个属性 prop
			for each(var prop:XML in desc)
			{
				var propName:String = prop.@name;			// 变量名
				var propType:String = prop.@type;			// 变量类型
				
				// 忽略了
				if(ignoreProps && ignoreProps.indexOf(propName)>=0) continue;
				
				var list:XMLList = xml.child(propName);
				
				switch(propType)
				{
					// 基本类型
					case "Boolean":
					case "int":
					case "uint":
					case "String":
					case "Number":
					{
						obj[propName] = list;;		// 变量名 和 xml节点名 必须相同 
					}
					break;
					
					// 数组
					case "Array":
					{
						var arr:Array = parseUniList( list, null );
						if(arr && arr.length) obj[propName]=arr;		// 如果长度为0, 则设置为null  
					}
					break;
					
					// 对象
					default:
					{
						tClass = getClassByName(propType, null);
						if(tClass != null)
							obj[propName] = parseUniObject( list[0], tClass);
					}
					break;
				}
			}
			
			return obj;
		}
		
		/**
		 * 解析对象数组
		 * 利用 registerClassByName() 注册类映射关系, 对象从数组中自动解析. 如果映射失败, 则使用 defaultClass 类型
		 * <characters>
		 *   <character>...</character>
		 *   ...
		 * </characters>
		 * 
		 * @param xmlList
		 * @param defaultClass
		 * @param ignoreProps
		 * @return array(object, ...)
		 * 
		 */
		public static function parseUniList(xmlList:XMLList, defaultClass:Class=null, ignoreProps:Array=null):Array
		{
			if(xmlList==null) return null;
			xmlList = xmlList.children();
			
			var arr:Array = new Array;
			for each(var xml:XML in xmlList)
			{
				var className:String = xml.name();
				var tClass:Class = getClassByName( className, defaultClass );
				var obj:Object = parseUniObject(xml, tClass, ignoreProps);
				arr.push( obj ); 
			}
			
			return arr;
		}
		
		// 解析标准数组, xml.ret.node, xml.ret.node => xml.ret.node
		public static function parseUniListFilter(xmllist:XMLList, defaultClass:Class=null, ignoreProps:Array=null):Array{
			var xml:XML = new XML(<xml/>);
			xml.appendChild(<nodes/>);
			xml.nodes.appendChild(xmllist);
			return parseUniList(xml.nodes, defaultClass, ignoreProps);
		}
		
		public static function fillObject(obj:Object, xmlList:XMLList):void
		{
			for each(var xml:XML in xmlList.children())
			{
				var propName:String = xml.name();	
				if(obj.hasOwnProperty(propName))
				{
					obj[propName] = xml;		
				}
			}
		}
		
		/**
		 * 私有方法 
		 */		
		
		// 获得一个类, name 可以包含包路径, 如 name="flash.display::Sprite"
		// 或者, name 也可以为绝对名, 如 name="Sprite"
		private static function getClassByName(name:String, defaultClass:Class):Class{
			
			if(name == "Object") return null;
			
			// 获取末尾名字
			var tailName:String;
			var tailIndex:int = name.lastIndexOf("::");
			if(tailIndex >= 0) tailName = name.substr(tailIndex + 2);		// "::" 之后的名字
			else tailName = name;
			
			// 1, 从映射表中获取 
			var tClass:Class = classMap[tailName];
			
			// 2, 从当前应用程序域中获取, 要求名字完全匹配(否则使用第1/3方案)
			if(tClass == null)
			{
				// 获取包路径名, 如 fullName="flash.display.Sprite"
				var fullName:String; 
				if(tailIndex >= 0) 	fullName = name.replace("::", ".");
				//				else				fullName = "magin.vo." + tailName;	// 默认包路径为 "game.model.vo"
				
				// 从当前应用程序域中获取类
				if(ApplicationDomain.currentDomain.hasDefinition(fullName))
				{
					// 注意: 如果类从来没有被使用过, 则没有被 flex 编译进工程, 则无法被获取
					tClass = ApplicationDomain.currentDomain.getDefinition(fullName) as Class;
				}
			}
			
			// 3, 使用默认类型
			if(tClass == null)
			{
				tClass = defaultClass;
			}
			
			// 4), 失败, 错误
			if(tClass == null){
				var msg:String = printf('class %s couldn\'t be found',  name );
				throw new Error(msg);
			}
			return tClass;
		}
		
		public function ObjectParser()
		{    
			throw new Error(I18n.get('ObjectParser class is static class only'));    
		}  
	}
}