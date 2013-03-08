package wit.utils
{
	import flash.utils.ByteArray;
	import mx.utils.Base64Decoder;
	
	public class PList
	{
		public static function parse(source:XML):Object
		{
			switch (source.name().localName) {
				case 'plist':
					return parse(source.children()[0]);
				case 'dict':
					return parseDict(source);
				case 'array':
					return parseArray(source);
				case 'string':
					return parseString(source);
				case 'integer':
					return parseInteger(source);
				case 'real':
					return parseNumber(source);
//				case 'data':
//					return parseData(source);
				case 'date':
					return parseDate(source);
				case 'true': case 'false':
					return parseBoolean(source);
			}
			return null;
		}
		
		public static function parseDict(source:XML):Object
		{
			var obj:Object = {};
			var children:XMLList = source.children();
			for (var i:int = 0, cnt:int = source.children().length(); i < cnt; i += 2) {
				var key:String = children[i].text();
				obj[key] = parse(children[i+1]);
			}
			return obj;
		}
		
		public static function parseArray(source:XML):Array
		{
			var arr:Array = [];
			for each (var el:XML in source.children()) {
				arr.push(parse(el));
			}
			return arr;
		}
		
//		public static function parseData(source:XML):ByteArray
//		{
//			var decoder:Base64Decoder = new Base64Decoder();
//			var value:String = parseString(source);
//			decoder.decode(value);
//			return decoder.toByteArray();
//		}
		
		public static function parseDate(source:XML):Date
		{
			var ts:Number = Date.parse(parseString(source));
			var d:Date = new Date();
			d.setTime(ts);
			return d;
		}	
		
		public static function parseString(source:XML):String
		{
			return source.text();
		}
		
		public static function parseInteger(source:XML):int
		{
			return parseInt(parseString(source), 10);
		}
		
		public static function parseNumber(source:XML):Number
		{
			return Number(parseString(source));
		}
		
		public static function parseBoolean(source:XML):Boolean
		{
			return source.name() == 'true';
		}
	}
}