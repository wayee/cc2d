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
            if (Data is BitmapData) {
                (Data as BitmapData).dispose();
            } else {
                if (Data is DisplayObject) {
                    if (Data.parent && !(Data.parent is Loader)) {
                        Data.parent.removeChild(Data);
                    }
                    Fun.clearChildren(Data as DisplayObject, true);
                }
            }
            Data = null;
            Pre = null;
            Next = null;
        }
    }
}