package wit.utils
{
	/**
	 * 多语言版本管理
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class I18n
	{
		public static var lang:String			= 'zh-cn';			// target language: en-us, es-es, zh-cn, etc
		public static var table:Object;								// cache of loaded languages
		
		public function I18n() {
			throw new Error("I18n class is static class only");
		}
		
		public static function getLang(lang:String = ''):String {
			if (lang)
			{
				// Normalize the language
				lang.replace('_', '-');
				lang.replace(' ', '-');
				I18n.lang = lang.toLowerCase();
			}
			
			return I18n.lang;
		}
		
		public static function get(text:String, lang:String=''):String {
			var l:Object;
			if (I18n.table == null) I18n.table = {};
			if (lang != '') {
				// Use the global target language
				l = I18n.table[lang];
			} else {
				l = I18n.table[I18n.lang];
			}
			
			if ( !(l && l[text]) ) {
//				trace("failure for:", text);
			}
			
			// Return the translated string if it exists
			return l && l[text] ? l[text] : text; 
		}
		
		public static function __(text:String, lang:String=''):String {
			text = text.replace(/\n\n/g, "\\n\\n"); // double \n
			text = text.replace(/\t\n\n/g, "\\t\\n\\n");
			text = text.replace(/\n/g, "\\n");
			text = text.replace(/\t\t/g, "\\t\\t"); // double \t
			text = text.replace(/\t/g, "\\t");
			
			text = get(text, lang);
			
			text = text.replace(/\\t\\n\\n/g, "\t\n\n");
			text = text.replace(/\\n\\n/g, "\n\n");
			text = text.replace(/\\n/g, "\n");
			text = text.replace(/\\t\\t/g, "\t\t");
			text = text.replace(/\\t/g, "\t");
			
			return text;
		}
	}
}