package wit.log
{
	import flash.text.TextField;
	
	import wit.handler.HandlerThread;
	import wit.manager.HandlerManager;

	/**
	 * 日志信息很重要，请善用此工具，参考 Log4J
	 * 
	 * OFF、FATAL、ERROR、WARN、INFO、DEBUG、ALL
	 * Log4j建议只使用四个级别，优先级从高到低分别是ERROR、WARN、INFO、DEBUG
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class Log4J
	{
		private static const logHT:HandlerThread = HandlerManager.creatNewHandlerThread();
		
		public static var IsDebug:Boolean = true;
		public static var IsInfo:Boolean = true;
		public static var IsFatal:Boolean = true;
		
		private static var enableLog:Boolean = true;
		private static var enableTrace:Boolean = true;
		private static var enableShowInLogArea:Boolean = false;
		private static var maxLogNum:Number;
		private static var logContainer:TextField;
		private static var logNum:Number;
		
		/**
		 * 初始化
		 * @param logArea 文本控件
		 * @param max_num 最大数量
		 * @param bTrace 是否 trace 出信息
		 * @param bArea 是否添加到容器
		 */
		public static function Init(logArea:TextField=null, max_num:int=1000, 
									bTrace:Boolean=true, bArea:Boolean=false):void {
			enableLog = true;
			maxLogNum = max_num;
			enableTrace = bTrace;
			enableShowInLogArea = bArea;
			logContainer = logArea;
			if (logContainer) {
				logContainer.text = "";
			}
			logNum = 0;
		}
		
		public static function Debug(log:*):void {
			if ( !IsDebug ) return;
			add(log, '[DEBUG]');
		}
		
		public static function Info(log:*):void {
			if ( !IsInfo ) return;
			add(log);
		}
		
		public static function Fatal(log:*):void {
			if ( !IsFatal ) return;
			add(log, '[FATAL]');
		}
		
		/**
		 * 添加一条日志 
		 * @param log * 可以是字符串或者数组
		 */
		private static function add(log:*, type:String='[INFO]'):void {
			if (!enableLog) {
				return;
			}
			
			var logString:String = (log is Array && log.length > 0) ? log.join(" ") : log;
			if (enableTrace) {
				trace(type, logString);
			}
			if (enableShowInLogArea && logContainer != null) {
				logHT.push(doAdd, [type+' '+logString], 10);		// 延时10 之后??
			}
		}
		
		private static function doAdd(log:*):void
		{
			var index:int;
			if (enableShowInLogArea && logContainer != null) {
				logContainer.appendText(log + "\n");
				logNum++;
				
				while (logNum > maxLogNum) {
					index = logContainer.text.indexOf("\r");
					
					// 使用 newText 参数的内容替换 beginIndex 和 endIndex 参数指定的字符范围
					logContainer.replaceText(0, index != -1 ? index + 1 : 0, "");
					logNum--;
				}
			}
		}
	}
}