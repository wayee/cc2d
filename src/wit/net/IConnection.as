package wit.net
{
	public interface IConnection
	{
		function request(obj:Object, compress:Boolean = true):void;
		
		function set onConnect(value:Function):void;
		function set onResponse(value:Function):void;
	}
}