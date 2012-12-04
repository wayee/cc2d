package wit.net
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import wit.log.Log4J;

	/**
	 * 网络层
	 */
    public class ZSocket extends Socket
	{
        private static var BUFFER_MAX_LENGTH:int = 10000;		// 缓冲区, 避免每次重新建立
        private static var MSG_HEAD_MARK:uint = 127;

        public var host:String = null;
        public var port:uint = 0;
        private var socketDataFun:Function;			// 执行函数, function( id, ba );		// id=ba[0]
        private var msgHead:ByteArray;				// 数据头, 固定2字节
        private var bufferByteArray:ByteArray;		// 数据体

        public function ZSocket(fn:Function, host:String=null, port:int=0, head_mask:uint=127)
		{
            msgHead = new ByteArray();
            bufferByteArray = new ByteArray();
            MSG_HEAD_MARK = head_mask;
            msgHead.writeShort(MSG_HEAD_MARK);
            socketDataFun = fn;
            addListeners();
            if (host != null){
                super();
                zConnect(host, port);
            }
        }
		
        public function zConnect(host:String, port:int=0):void
		{
            host = host;
            port = port;
            connect(host, port);
        }
		
		/**
		 * 发送数据
		 */
        public function zSend(code:uint, data:ByteArray):void
		{
            var $msgCode:* = code;
            var $dataArr:* = data;
            var sendBytes:* = new ByteArray();
            writeMsgHead((((2 + 2) + 4) + $dataArr.length));		// 尺寸 = 8 + 数据尺寸
            sendBytes.writeBytes(msgHead);		// 2
            sendBytes.writeInt($msgCode);			// 4
            sendBytes.writeBytes($dataArr);
            try {
                writeBytes(sendBytes);
                flush();
            } catch(e:IOError) {
                Log4J.add(e.toString());
            }
        }
		
		/**
		 * 写数据头
		 * @param length 数据体尺寸
		 */
        private function writeMsgHead(length:uint):void
		{
            msgHead.position = 2;
            msgHead.writeShort(length);
        }
		
        private function addListeners():void
		{
            if (!hasEventListener(Event.CLOSE)){
                addEventListener(Event.CLOSE, closeHandler);
                addEventListener(Event.CONNECT, connectHandler);
                addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
                addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
                addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
            }
        }
		
        private function closeHandler(event:Event):void
		{
            var socketEvent:ZSocketEvent = new ZSocketEvent(ZSocketEvent.CLOSE);
            dispatchEvent(socketEvent);
        }
		
        private function connectHandler(event:Event):void
		{
            var socketEvent:ZSocketEvent = new ZSocketEvent(ZSocketEvent.LOGIN_SUCCESS);
            dispatchEvent(socketEvent);
        }
		
        private function ioErrorHandler(event:IOErrorEvent):void
		{
            var socketEvent:ZSocketEvent = new ZSocketEvent(ZSocketEvent.LOGIN_FAILURE);
            dispatchEvent(socketEvent);
        }
		
        private function securityErrorHandler(event:SecurityErrorEvent):void
		{
            var socketEvent:ZSocketEvent = new ZSocketEvent(ZSocketEvent.LOGIN_FAILURE);
            dispatchEvent(socketEvent);
        }
		
		/**
		 * 接收数据
		 */
        private function socketDataHandler(event:ProgressEvent):void
		{
            var byteArray:ByteArray;
            readBytes(bufferByteArray, bufferByteArray.length, bytesAvailable);		// 读入并保存到末尾
            if (bufferByteArray.length > BUFFER_MAX_LENGTH){		// 超过最大值
                byteArray = new ByteArray();
                bufferByteArray.readBytes(byteArray, 0, bufferByteArray.bytesAvailable);	// 保存最新数据(pos-end)到 local2
                bufferByteArray.position = 0;
                bufferByteArray.length = 0;
                byteArray.readBytes(bufferByteArray, 0, byteArray.bytesAvailable);	// 重新保存到 bufferByteArray, 其中仅有原先 (pos-end) 
            }
            readSocketData();
        }
		
        private function readSocketData():void
		{
            var _local1:int;
            var _local2:int;
            var _local3:int;
            var byteArray:ByteArray;
            while (bufferByteArray.bytesAvailable > 4) {
                _local1 = bufferByteArray.position;			// 当前位置
                _local2 = bufferByteArray.readShort();			// 掩码
                if (_local2 == MSG_HEAD_MARK){
                    _local3 = bufferByteArray.readShort();		// local3 = 长度
                    if ((_local3 - 4) > bufferByteArray.bytesAvailable){		// 还没有读完
                        bufferByteArray.position = _local1;	// 恢复位置, 返回
                        return;
                    }
                    byteArray = new ByteArray();
                    bufferByteArray.readBytes(byteArray, 0, (_local3 - 4));		// 读入数据到 local4
                    socketDataFun(byteArray.readInt(), byteArray);					// 执行函数
                }
            }
        }
    }
}