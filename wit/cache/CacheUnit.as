package wit.cache
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	
	import wit.utils.LNode;
	import wit.utils.Fun;

    public class CacheUnit extends LNode
	{
        public function CacheUnit(value:Object, id:String)
		{
            super(value, id);
        }
        
		public function dispose():void
		{
            if (data is BitmapData) {
                (data as BitmapData).dispose();
            } else {
                if (data is DisplayObject) {
                    if (data.parent && !(data.parent is Loader)) {
                        data.parent.removeChild(data);
                    }
                    Fun.clearChildren(data as DisplayObject, true);
                }
            }
            data = null;
            pre = null;
            next = null;
        }
    }
}