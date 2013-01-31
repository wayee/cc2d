package cc.vo.avatar
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

    public class AvatarFaceData
	{
        public var id:String;
        public var type:String;
        public var cutRect:Rectangle;
        public var sourcePoint:Point;
        public var sourceBitmapData:BitmapData;

        public function AvatarFaceData(p_cutRect:Rectangle=null, p_sourcePoint:Point=null, p_sourceBitmapData:BitmapData=null) {
            cutRect = p_cutRect;
            sourcePoint = p_sourcePoint;
            sourceBitmapData = p_sourceBitmapData;
        }
        public function isGood():Boolean {
            return cutRect != null && sourcePoint != null && sourceBitmapData != null;
        }
    }
}