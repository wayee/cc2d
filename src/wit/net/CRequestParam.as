package wit.net
{
	/**
	 * 请求服务器和服务器响应的通用参数
	 * 所有请求的参数对象 Vo 都可以继承此类
	 * act 与  param 是必须的参数
	 *  
	 * @author Andy Cai
	 * @version $Id$
	 * 
	 */
	public class CRequestParam
	{
		public var act:String;			// 请求的服务器方法
		public var param:Object;		// 请求携带的参数对象
		public var url:Object;			// 支持 http 请求
		
		/**
		 * 还原为默认值 
		 */
		public function reset():void
		{
			this.act = '';
			this.param = null;
			this.url = null;
		}
	}
}