package wit.pool
{
	/**
	 * 可以被对象池管理的对象必须实现此接口
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public interface IPoolObject
	{
		function dispose():void;				// 释放资源
		function reset(value:Array):void;		// 重新分配资源
	}
}