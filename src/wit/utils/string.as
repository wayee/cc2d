package wit.utils
{
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	
	/**
	 * 字符串工具类
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class string
	{
		/**
		 * Returns value is a string type value.
		 * with undefined or null value, false returned.
		 */
		public static function isString(value:*):Boolean
		{
			return value is String;
		}
		
		public static function castString(str:*):String
		{
			return str as String;
		}
		
		/**
		 * replace oldString with newString in targetString
		 */
		public static function replace(targetString:String , oldString:String , newString:String):String
		{
			return targetString.split(oldString).join(newString);
		}
		
		/**
		 * remove the blankspaces of left and right in targetString
		 */
		public static function trim(targetString:String):String
		{
			return trimLeft(trimRight(targetString));
		}
		
		/**
		 * remove only the blankspace on targetString's left
		 */
		public static function trimLeft(targetString:String):String
		{
			var tempIndex:int = 0;
			var tempChar:String = "";
			for(var i:int=0 ; i<targetString.length ; i++){
				tempChar = targetString.charAt(i);
				if(tempChar != " "){
					tempIndex = i;
					break;
				}
			}
			return targetString.substr(tempIndex);
		}
		
		/**
		 * remove only the blankspace on targetString's right
		 */
		public static function trimRight(targetString:String):String
		{
			var tempIndex:int = targetString.length-1;
			var tempChar:String = "";
			for(var i:int=targetString.length-1 ; i>=0 ; i--){
				tempChar = targetString.charAt(i);
				if(tempChar != " "){
					tempIndex = i;
					break;
				}
			}
			return targetString.substring(0 , tempIndex+1);
		}
		
		public static function getCharsArray(targetString:String , hasBlankSpace:Boolean):Array
		{
			var tempString:String = targetString;
			if(hasBlankSpace == false){
				tempString = trim(targetString);
			} 		
			return tempString.split("");
		}
		
		public static function startsWith(targetString:String, subString:String):Boolean
		{
			return (targetString.indexOf(subString) == 0);	
		}
		
		public static function endsWith(targetString:String, subString:String):Boolean
		{
			return (targetString.lastIndexOf(subString) == (targetString.length - subString.length));	
		}
		
		public static function isLetter(chars:String):Boolean
		{
			if(chars == null || chars == ""){
				return false;
			}
			for(var i:int=0; i<chars.length; i++){
				var code:uint = chars.charCodeAt(i);
				if(code < 65 || code > 122 || (code > 90 && code < 97)){
					return false;
				}
			}
			return true;
		}
		
		/**
		 * 将字符串的首字母转换为大写
		 * @param str
		 * @return string
		 */
		public static function ucfirst(str:String):String
		{
			return str.charAt( 0 ).toUpperCase() + str.substr( 1, str.length );
		}
		
		///////// 中文处理
		
		// 按指定格式返回字符串
		// 如: printf(fmt, arg0, arg1, arg2, ...);
		// fmt =  %d, %D, %u, %f, %s, %?, {0}, {1}, {id}, %2d, %3d, 
		public static function printf(fmt:String, ...args):String
		{
			_args = args; _argb = _argi = _argm = 0; 
			return fmt.replace(exp_printf, match_token);
		}
		
		//  fmtargs = fmt0, arg0, fmt1, arg1, ...
		// printf_every("{0}年{1}月{2}日", "%4d", year, "%2d", month+1, "%2d", day);
		public static function printf_every(fmt:String, ...fmtargs):String
		{
			var args:Array = [ fmt ];
			for(var i:int=0; i<fmtargs.length; i+=2){
				args.push( printf(fmtargs[i], fmtargs[i+1]) );
			}
			return printf.apply(null, args);
		}
		
		// args = fmt0, ...args0, fmt1, ...args1, ...
		public static function printf_batch(...args):String
		{
			_args = args;
			var fmtIndex:int = 0;
			var str:String = "";
			while(fmtIndex < args.length){
				var fmt:String = args[fmtIndex];	// 第一个, 格式化字符串
				_argb = _argi = fmtIndex + 1;		// 第二个, 参数表
				_argm = 0;
				var tmp:String = fmt.replace(exp_printf, match_token);
				fmtIndex = Math.max(_argi, _argb+_argm);	// 指向下一段格式化字符串
				str += tmp;
			}
			return str;
		}
		
		// args = fmt0, ...args0, fmt1, ...args1, ...			// args{n} = [flags, ...], 仅当 flags 有效才显示该组
		public static function printf_select(...args):String
		{
			_args = args;
			var fmtIndex:int = 0;
			var str:String = "";
			while(fmtIndex < args.length){
				var fmt:String = args[fmtIndex];
				_argb = _argi = fmtIndex + 1;
				_argm = 0;
				var flag:Object = args[_argi];
				var tmp:String = fmt.replace(exp_printf, match_token);
				fmtIndex = Math.max(_argi, _argb+_argm);
				if( (_argi!= fmtIndex+1) && ( flag==null || flag=="" || flag==false || flag==0 ) ) trace('');	// 判断flag
				else str += tmp;
			}
			
			return str;
		}
		
		// 支持: %d, %D, %u, %f, %s, %?, {0}, {1:name}, {name}, %2d, %3d 
		static private const exp_printf:RegExp = /(%[dDufse?]) | %(\d+)d | \{(\d+)(:\w+)?\} | \{([_a-zA-Z]\w+)\} /gx;
		static private var _args:Array;	// 原始数组
		static private var _argi:int;	// 当前索引号
		static private var _argb:int;	// 当前索引基地址
		static private var _argm:int;	// 当前匹配的个数
		static private function match_token(...args):String
		{
			
			var token:String = args[0];
			var i:int, s:String, n:Number, value:Object, id:String, map:Object;
			_argm ++;
			
			// %d, %D, %u, %f, %s, %e, %?
			if(args[1])
			{
				value = _args[_argi++];
				switch(token)
				{
					case "%d":	return String( int(value) );
					case "%D":	return int(value)>0 ? "+"+String(int(value)): String(int(value));
					case "%u":	return String(uint(value));
					case "%f":	return String(Number(value));
					case "%s":	return String(value);
					case "%e":	return encodeURIComponent(String(value));
					case "%?":	return "";
					default:	return token;
				}
			}
				// %2d, %3d, 
			else if (args[2])
			{
				value = _args[_argi++];
				i = int( args[2] );
				s = String( int(value) );
				while(s.length < i) s = "0" + s;
				return s; 
			}
				// {0}, {1}
			else if(args[3])
			{
				i = _argb + int(args[3]);		// 地址
				value = (_args[i]!=null? _args[i].toString(): "");
				return value.toString();
			}
				// {id}
			else if(args[5])
			{
				id = String( args[5] );
				map = _args[ _argb ];
				value = map[ id ];
				return (value? value.toString(): "");
			}
			
			// default
			return token;
		}
		
		// 返回 rep 的重复 times 次数后的值
		public static function repeat(times:int, rep:String):String
		{
			var str:String = "";
			while(times-- > 0) str += rep;
			return str;
		}
		
		// 转换 阿拉伯数字 到 中文数字, 暂不支持小数
		public static function chineseNumber(value:uint):String
		{
			// 常量
			const map_num:Array 	= ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
			const map_a:Array 		= ['千', '百', '十', ''];			// 单位a
			//const map_b:Array 		= ["兆","亿","万", ""];			// 单位b
			const map_b:Array 		= ['亿', '万', ''];			// 单位b
			const LEN:int	 		= map_a.length * map_b.length;	// 字符串最大长度
			
			// 转换 value 为字符串格式, 并前面填充 '0', 得到如 '0001'
			var buf:String = value.toString();
			buf = repeat(LEN-buf.length, "0") + buf;
			if(buf.length != LEN) return '超出上限';
			
			// 遍历每个数字
			var prev:int = 100;			// 上一个有效数字的位置
			var b:String = "";			// 单位b的名字, 在变更后才添加
			var str:String = "";		// 结果字符串
			for(var i:int=0; i<LEN; i++)
			{
				// 仅遍历有效数字
				var ch:String = buf.charAt(i);
				if(ch == '0') continue;
				
				// 单位b, 如果变动, 则添加到 str 上
				var b2:String = map_b[ int(i / 4) ];
				if(b2 != b){
					str += b;		// 添加先前的单位
					b = b2;			// 同一个单位b, 只可能添加一次
				}
				
				// 补零, 当有效数字非连续时
				if(prev < i-1){
					if( (i % 4) != 0 )		// 千位不允许
						str += map_num[0];
				} 
				prev = i;
				
				// 数字
				str += map_num[ch.charCodeAt(0) - 0x30];
				
				// 单位a
				str += map_a[ i % 4];
			}
			str += b;	// 补上单位b
			
			// 修饰
			{
				// 空串
				if(str == "") str = '零';
				
				// 以 "一十" 开始变为以 "十" 开始
				str = str.replace(new RegExp('一十', ''), '十');
			}
			
			return str;
		}
		
		// 清除 html 标签
		public static function html_removeTag(str:String):String
		{
			if(!str) return str;
			return str.replace( /<.*?>/g, "");
		}
		
		/**
		 * 把字符串 newstr 放到 oldstr 的末尾
		 * @param oldstr
		 * @param newstr
		 * @return string
		 */
		public static function stringCat(oldstr:String, newstr:String):String
		{
			if(!oldstr) oldstr = "";
			oldstr = Base64.encode( oldstr );
			return oldstr + "," + newstr;
		}

		/**
		 * 把 str中的末尾截取出来, 返回 [oldstr, newstr]
		 * @param str
		 * @return 
		 */
		public static function stringTail(str:String):Array
		{
			var index:int = str.indexOf(",");
			if(index < 0) return [ Base64.decode(str), null];
			var oldstr:String = str.substr(0, index)
			var newstr:String = str.substr(index+1);
			return [Base64.decode(oldstr), newstr];
		}
		
		/**
		 * 解码字符串到对象, "x=1&y=2&z=3" => {x:1, y:2, z:3}
		 * @param str 字符串
		 * @param join_char 连接符
		 * @param equip_char 等于符号
		 * @return object
		 */
		public static function decodeSimpleObject(str:String, join_char:String=null, equip_char:String=null):Object
		{
			join_char = join_char || "&";
			equip_char = equip_char || "=";
			var arr:Array = str.split(join_char);
			var obj:Object = {};
			for each(str in arr){
				var a:Array = str.split( equip_char );
				obj[ a[0] ] = a[1]; 
			}
			return obj;
		}
		
		/**
		 * 把数字分组表示
		 * @param value 总数
		 * @param size 每组大小
		 * @return string
		 */
		public static function splitNumber(value:int, size:int=3):String
		{
			var sign:String = "";
			if( value < 0 ) { sign = "-"; value = -value; }
			
			var arr:Array = value.toString().split("");
			var init:int = ( arr.length % size);
			if( init == 0) init = size;
			var arr2:Array = [];
			for(var i:int=0; i<arr.length; i++, init--){
				if(init == 0) { init = size; arr2.push(",") };
				arr2.push( arr[i] );
			}
			var str2:String = sign + arr2.join("");
			return str2;
		}
		
		/**
		 * 将"XXXX-XX-XX XX:XX:XX"形式的日期转化为Date类型。
		 * @param "XXXX-XX-XX XX:XX:XX"形式的字符串
		 * */
		public static function stringToDate(s:String):Date
		{
			if(s==null || s=="") return null;
			
			var Sarr:Array = s.split(" ");
			if(Sarr.length!=2) return null;
			
			var Darr:Array = (Sarr[0] as String).split("-");
			if(Darr.length!=3) return null;
			
			var Tarr:Array = (Sarr[1] as String).split(":");
			if(Tarr.length!=3) return null;
			
			var da:Date = new Date(Darr[0],(int(Darr[1])-1),Darr[2],Tarr[0],Tarr[1],Tarr[2]);
			return da;
		}
		
		/**
		 * 字符串截取 
		 * @param str 原字符串
		 * @param len 截取的长度
		 * @param suffix 后缀
		 * @param char 字符集
		 * @return 截取后的字符串
		 */
		public static function stringCuting(str:String, len:int, suffix:String='..', char:String='cn-gb'):String
		{
			var byte:ByteArray = new ByteArray();
			byte.writeMultiByte(str, char); 
			
			if(byte.length > len*2){  
				byte.position = 0;  
				str = byte.readMultiByte(len*2, char) + suffix;  
			} 
			return str;
		}
		
		/**
		 * 返回字符个数，1汉字=2字符，1大写字母、m、w=1.6字符，小写字母、数字=1.2字符
		 * @param str
		 * @return number 字符数量
		 */
		public static function getCharCount(str:String) : Number
		{
			var retval:Number = 0;
			var bytearr:ByteArray = new ByteArray;
			bytearr.writeUTF(str);
			//			trace(str);
			//			for (var j:int = 0;j < bytearr.length;j++)
			//				trace(bytearr[j]);
			
			var child_code:Number = 0;
			var offset:Number = 2;
			for (var i:int = 0;i < str.length;i++)
			{
				var child_str:String = str.charAt(i);
				offset += charsetOffset(child_code);
				child_code = bytearr[offset];
				if (child_code >= 192)
					retval += 2;
				else if ((child_code >= 65 && child_code <= 90) || child_str == 'm' || child_str == 'w')
					retval += 1.6;
				else
					retval += 1.2;
			}
			return retval;
		}
		
		private static function charsetOffset(code:Number) : Number
		{
			if (code >= 252)
				return 6;
			else if (code >= 248)
				return 5;
			else if (code >= 240)
				return 4;
			else if (code >= 224)
				return 3;
			else if (code >= 192)
				return 2;
			else if (code > 0)
				return 1;
			else
				return 0;
		}
		
		public static function isChinese(con:String):Boolean{
			var pattern:RegExp=/[\u4e00-\u9fa5]/;
			var p:Boolean = pattern.test(con);
			return p;
		}
		
		public static function print_r(o:Object):String
		{
			var str:String = '';
			trace('   =object start');
			for (var val:* in o) {
				trace('   [' + typeof(o[val]) + '] ' + val + ' => ' + o[val]);
				str += '   [' + typeof(o[val]) + '] ' + val + ' => ' + o[val];
				if (typeof(o[val]) == 'object') {
					print_r(o[val]);
				}
			}
			trace('   =object end');
			return str;
		}
		
		public static function getString(obj:Object):String
		{
			return convertToString(obj);
		}
		
		private static function convertToString( value:* ):String 
		{
			if ( value is String ) {
				return escapeString( value as String );
				
			} else if ( value is Number ) {
				return isFinite( value as Number) ? value.toString() : "null";
				
			} else if ( value is Boolean ) {
				return value ? "true" : "false";
				
			} else if ( value is Array ) {
				return arrayToString( value as Array );
				
			} else if ( value is Object && value != null ) {
				return objectToString( value );
			}
			return "null";
		}
		
		private static function escapeString( str:String ):String 
		{
			var s:String = "";
			var ch:String;
			var len:Number = str.length;
			for ( var i:int = 0; i < len; i++ ) {
				
				ch = str.charAt( i );
				switch ( ch ) {
					
					case '"':	// quotation mark
						s += "\\\"";
						break;
					
					//case '/':	// solidus
					//	s += "\\/";
					//	break;
					
					case '\\':	// reverse solidus
						s += "\\\\";
						break;
					
					case '\b':	// bell
						s += "\\b";
						break;
					
					case '\f':	// form feed
						s += "\\f";
						break;
					
					case '\n':	// newline
						s += "\\n";
						break;
					
					case '\r':	// carriage return
						s += "\\r";
						break;
					
					case '\t':	// horizontal tab
						s += "\\t";
						break;
					
					default:	// everything else
						if ( ch < ' ' ) {
							var hexCode:String = ch.charCodeAt( 0 ).toString( 16 );
							var zeroPad:String = hexCode.length == 2 ? "00" : "000";
							s += "\\u" + zeroPad + hexCode;
						} else {
							s += ch;
						}
				}	// end switch
				
			}	// end for loop
			
			return  s;
		}
		
		private static function arrayToString( a:Array ):String
		{
			var s:String = "";
			for ( var i:int = 0; i < a.length; i++ ) {
				if ( s.length > 0 ) {
					s += ","
				}
				s += convertToString( a[i] );	
			}
			return "[" + s + "]";
		}
		
		private static function objectToString( o:Object ):String
		{
			var s:String = "";
			var classInfo:XML = describeType( o );
			if ( classInfo.@name.toString() == "Object" )
			{
				var value:Object;
				for ( var key:String in o )
				{
					value = o[key];
					if ( value is Function )
					{
						continue;
					}
					if ( s.length > 0 ) {
						s += " | "
					}
					
					s += escapeString( key ) + " = " + convertToString( value );
				}
			}
			else // o is a class instance
			{
//				for each ( var v:XML in classInfo..*.( name() == "variable" || name() == "accessor" ) )
//				{
//					if ( s.length > 0 ) {
//						s += " | "
//					}
//					
//					s += escapeString( v.@name.toString() ) + " = " 
//						+ convertToString( o[ v.@name ] );
//				}
				
			}
			
			return "{" + s + "}\n";
		}
		
		public function string()
		{    
			throw new Error("StringUtils class is static class only");    
		}  
	}
}