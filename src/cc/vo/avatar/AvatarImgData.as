package cc.vo.avatar
{
	import flash.display.BitmapData;

    public class AvatarImgData
	{
        public var dir07654:BitmapData;			// 正像 angle => 0 4567  2: <-  6: ->
        public var dir123:BitmapData;			// 镜像 angle => 123
//        public var _dir123:BitmapData;			// 镜像 angle => 123
        public var useNum:int;
		public var only1Angle:Boolean;

        public function AvatarImgData(positive:BitmapData, negative:BitmapData=null, num:int=1/*, p_only1Angle:Boolean=false*/) {
            dir07654 = positive;
            dir123 = negative;
//			only1Angle = p_only1Angle;
            useNum = num;
        }
		
//		public function get dir123():BitmapData
//		{
//			if (_dir123) return _dir123;
//			
//			var bm1:BitmapData;
//			var width:Number;
//			var height:Number;
//			var matrix:Matrix;
//			
//			if (dir07654 != null){
//				width = dir07654.width;
//				height = dir07654.height;
//				if (!only1Angle) {
//					bm1 = new BitmapData(width, ((height * 3) / 5), true, 0);	// 镜像的高度 = 正向的3/5，就是中间的三个方向做镜像
//					bm1.copyPixels(dir07654, new Rectangle(0, (height / 5), width, ((height * 3) / 5)), new Point(0, 0));
//				} else {
//					bm1 = new BitmapData(width, height, true, 0);
//					bm1.copyPixels(dir07654, new Rectangle(0, 0, width, height), new Point(0, 0));
//				}
//				matrix = new Matrix(); // 镜像（水平翻转）
//				matrix.scale(-1, 1);
//				matrix.translate(bm1.width, 0);
//				_dir123 = new BitmapData(bm1.width, bm1.height, true, 0);
//				_dir123.draw(bm1, matrix);
//				bm1.dispose();
//				
//				return _dir123;
//			}
//			return null;
//		}
    }
}