package cc.tools
{
	import br.com.stimuli.loading.BulkLoader;
	
	import flash.events.Event;
	import wit.utils.Fun;
	import wit.manager.LoaderManager;

	/**
	 * 场景加载器
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class SceneLoader
	{
		public static var smallMapImgLoader:BulkLoader = LoaderManager.creatNewLoader("smallMapImgLoader", function (event:Event):void{
			Fun.doGC();
		});
		public static var mapImgLoader:BulkLoader = LoaderManager.creatNewLoader("mapImgLoader", function (event:Event):void{
			Fun.doGC();
		});
		public static var avatarXmlLoader:BulkLoader = LoaderManager.creatNewLoader("avatarXmlLoader", function (event:Event):void{
			Fun.doGC();
		});
		
//		with ({}) {
//			{}.allLoadComplete = function (event:Event):void{
//				Fun.doGC();
//			};
//		};
//		with ({}) {
//			{}.allLoadComplete = function (event:Event):void{
//				Fun.doGC();
//			};
//		};
//		with ({}) {
//			{}.allLoadComplete = function (event:Event):void{
//				Fun.doGC();
//			};
//		};
	}
}