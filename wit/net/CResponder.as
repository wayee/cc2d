package wit.net
{
	import wit.utils.Singleton;

	/**
	 * 响应管理器
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * @version $Id$
	 * 
	 */
	public class CResponder extends Singleton
	{
		public static function get instance():CResponder
		{
			return Singleton.getInstanceOrCreate(CResponder) as CResponder;
		}
		
		public function onResponse(value:Object):void
		{
			// value = {'act': String, 'param': Object}
//			trace(value.toString());
			dispatchEvent(new CNetEvent(CNetEvent.RESPONSE_TO_MODEL, value));
		}
	}
}