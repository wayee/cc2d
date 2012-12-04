package cc.graphics.layers
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import cc.CCScene;
	import cc.CCCharacter;
	import cc.graphics.avatar.CCAvatarPart;
	import wit.draw.Bounds;
	import wit.utils.DirtyBoundsMaker;
	import wit.utils.Fun;
	

	/**
	 * 人物层
	 * <li>Bitmap 作为 children 来添加, 并保存  BitmpData 列表到 _avatarBDDict
	 * <li>位图尺寸, 和地图像素尺寸一样大小(或更大)
	 */
    public class SceneAvatarLayer extends Sprite
	{
        public static const MAX_AVATARBD_WIDTH:Number = 2880;			// 最大子位图尺寸, 该数值是 BitmapData 单次可建立的最大位图尺寸
        public static const MAX_AVATARBD_HEIGHT:Number = 2880;
        private static const floor:Function = Math.floor;

        private var _scene:CCScene;
		
		// 子位图
        private var _avatarBDDict:Dictionary;			// [ y_x ] = BitmapData, 相同数量的 Bitmap 被添加为自己的孩子
        private var _cutXCount:int;						// 纵横个数. 场景大图, 被按照 WIDTH/HEIGHT 划分为多个子位图, 这里是子位图的个数
        private var _cutYCount:int;
        private var _mapWidth:Number;					// 像素尺寸
        private var _mapHeight:Number;
		
		// 重绘区管理
        public var removeBoundsArr:Array;			// 被删除的对象的矩形列表, AvatarPart.clearMe 中清除时添加
        public var clearBoundsArr:Array;			// 对象的修改矩形列表, AvatarPart.run 中添加 cur/old 2个矩形位置
        public var restingAvatarPartArr:Array;		// 不需要重绘的 AvatarPart 数组, AvatarPart.run 中添加
        private var _dirtyBoundsMaker:DirtyBoundsMaker;

		/**
		 * 初始化
		 * @param scene 场景
		 */
        public function SceneAvatarLayer(scene:CCScene)
		{
            super();
			
            this._scene = scene;
            this._avatarBDDict = new Dictionary();
			
            this.removeBoundsArr = [];
            this.clearBoundsArr = [];
            this.restingAvatarPartArr = [];
            this._dirtyBoundsMaker = new DirtyBoundsMaker();
			
            mouseEnabled = false;
            mouseChildren = false;
        }
		
		/**
		 * 获取某个位置的位图
		 */
        public function getAvatarBD(x:int, y:int):BitmapData
		{
            return this._avatarBDDict[y + "_" + x];
        }
		
		// 释放资源
        public function dispose():void
		{
            this.removeAllAvatarBD();
			
            this.removeBoundsArr = [];
            this.clearBoundsArr = [];
            this.restingAvatarPartArr = [];
            this._dirtyBoundsMaker.clear();
        }
		
		/**
		 * 建立位图, 尺寸和当前场景相同. 
		 * 因为 BitmapData 有 2880 的最大尺寸限制, 因此这里使用 子位图 的方式
		 * @call Scene.switchScene
		 */
        public function creatAllAvatarBD():void
		{
            var i:* = 0;
            var j:* = 0;
            var xx:* = 0;
            var yy:* = 0;
            var ww:* = NaN;
            var hh:* = NaN;
            var bm:* = null;
            var bd:* = null;
            this.removeAllAvatarBD();		// 释放位图
            this._mapWidth = this._scene.mapConfig.width;			// 像素宽度
            this._mapHeight = this._scene.mapConfig.height;			// 像素高度
			
			// 把场景大图, 划分为多个子位图
            var mH:Number = (this._mapWidth % MAX_AVATARBD_WIDTH);			// modle horz
            var mV:Number = (this._mapHeight % MAX_AVATARBD_HEIGHT);		// modle vert
            var dH:Number = floor((this._mapWidth / MAX_AVATARBD_WIDTH));	// div horz - 1
            var dV:Number = floor((this._mapHeight / MAX_AVATARBD_HEIGHT));	// div vert - 1
            if (mH == 0){
                dH = (dH - 1);			// 横向个数 -1
            }
            if (mV == 0){
                dV = (dV - 1);			// 纵向个数 -1
            }
            this._cutXCount = (dH + 1);			// 纵横 子位图 个数
            this._cutYCount = (dV + 1);	
			
            j = 0;
            while (j <= dV) {
				// 当前 Y坐标 yy , 和高度 hh 
                yy = (j * MAX_AVATARBD_HEIGHT);		// yy = [0, dV]
                hh = (j < dV || mV == 0) ? MAX_AVATARBD_HEIGHT : mV;		// 高度, 如果是最下面, 则可缩小
				
                i = 0;
                while (i <= dH) {
					// 当前 x 坐标 xx, 和宽度 ww
                    xx = (i * MAX_AVATARBD_WIDTH);	// xx = [0, dH]
                    ww = (i < dH || mH == 0) ? MAX_AVATARBD_WIDTH : mH;	// 宽度, 如果是最右边, 可缩短
					
					// 建立 ww/hh 的位图, 透明, 黑色填充
                    try {
                        bd = new BitmapData(ww, hh, true, 0);			// 建立位图, OMG, 原来如此!!
                    } catch(e:Error) {
//                        ZLog.add("内存不足，无法创建地图！");
                        throw (new Error("内存不足，无法创建地图！"));
                    }
					
					// 保存到 j_i 中, 这里的 i/j 是纵横的子位图序号
                    this._avatarBDDict[((j + "_") + i)] = bd;		// [ y_x ] = BitmapData 
                    bm = new Bitmap(bd);
                    bm.x = xx;
                    bm.y = yy;
                    this.addChild(bm);
                    i = (i + 1);
                }
                j = (j + 1);
            }
        }
		
		/**
		 * 释放所有孩子, 和 _avatarBDDict
		 */
        private function removeAllAvatarBD():void
		{
            var avatar:BitmapData;
            var key:String;
            Fun.clearChildren(this);					// 清空 Bitmap
//            Fun.clearChildren(this, false, false);					// MovieClip 不删除子元素
			
            for (key in this._avatarBDDict) {
                avatar = this._avatarBDDict[key];
                avatar.dispose();						// 释放 BitmapData
                delete this._avatarBDDict[key];
            }
        }
		
		// 锁定位图, 使得修改  BitmapData 时, Bitmap 不会触发重绘
        private function lock():void
		{
            var avatarBitmapData:BitmapData;
            for each (avatarBitmapData in this._avatarBDDict) {
				avatarBitmapData.lock();
            }
        }
        private function unlock():void
		{
            var avatarBitmapData:BitmapData;
            for each (avatarBitmapData in this._avatarBDDict) {
				avatarBitmapData.unlock();
            }
        }
		
		/**
		 * 清空矩形列表
		 * @param bound_list = [ Bounds ]
		 */
        private function clear(bound_list:Array):void
		{
            var bound:Bounds;
            var rc:Rectangle;
            for each (bound in bound_list) {
                rc = Bounds.toRectangle(bound);
                this.copyImage(
					null,							// 清空 
					0, 0, rc.width, rc.height, 		// 源范围, 无
					rc.x, rc.y);					// 目标位置, 自身的坐标
            }
        }
		
		/**
		 * 复制位图, 因为使用了子位图, 所以要为每个子位图进行复制操作 <br>
		 * 使用 copyPixels 或者 fillRect 来复制/清空<br>
		 * 从 src 的 sx/sy/width/height 位置开始, 复制到自己的 left/top 位置处. 可以跨越多个 bitmap 整列进行绘制 <br>
		 * @param src 源位图, 为单一位图
		 */
        public function copyImage(src:BitmapData, sx:int, sy:int, width:int, height:int, left:int, top:int):void
		{
            var x_div:int;
            var y_div:int;
            var tmpOffsetX:Number;
            var tmpOffsetY:Number;
            var copyPixel_x:Number;
            var copyPixel_y:Number;
            var blt_weight:Number;
            var blt_height:Number;
            var fillX:int;
            var fillY:int;
            var targetAvatarBD:BitmapData;
            var fillColor:uint;
			
				// 左侧剪裁
            if (left < 0) {
                if (-(left) > width) {		// 太靠左边, 不可见
                    return;
                }
                sx = (sx - left);			// 增加开始复制的位置
                width = (width + left);		// 减少宽度
                left = 0;					// 左侧从0开始
            }
				// 顶部剪裁
            if (top < 0) {	
                if (-(top) > height) {		// 太靠上, 不可见
                    return;
                }
                sy = (sy - top);			// 增加开始复制的位置
                height = (height + top);	// 减少高度
                top = 0;					// 从0行开始
            }
				// 右侧剪裁
            if ((left + width) > this._mapWidth) {
                if (left > this._mapWidth) {
                    return;
                }
                width = (width - ((left + width) - this._mapWidth));
            }
				// 底部剪裁
            if ((top + height) > this._mapHeight) {
                if (top > this._mapHeight) {
                    return;
                }
                height = (height - ((top + height) - this._mapHeight));
            }
			
            var left_modle:Number = (left % MAX_AVATARBD_WIDTH);				// left_modle
            var top_modle:Number = (top % MAX_AVATARBD_HEIGHT);					// top_modle
            var right_modle:Number = ((left + width) % MAX_AVATARBD_WIDTH);		// right_modle
            var bottom_modle:Number = ((top + height) % MAX_AVATARBD_HEIGHT);	// bottom_modle
            var left_div:int = floor((left / MAX_AVATARBD_WIDTH));				// left_div
            var top_div:int = floor((top / MAX_AVATARBD_HEIGHT));				// top_dif
            var right_div:int = floor(((left + width) / MAX_AVATARBD_WIDTH));	// right_div
            var bottom_div:int = floor(((top + height) / MAX_AVATARBD_HEIGHT));	// bottom_div
            if (right_modle == 0) {
                right_div--;			// 右侧缩减
            }
            if (bottom_modle == 0) {
                bottom_div--;			// 底部缩减
            }
            tmpOffsetY = 0;
            y_div = top_div;
            while (y_div <= bottom_div) {
				
				// 计算  blt_height
                copyPixel_y = (sy + tmpOffsetY);
                if (top_div == bottom_div){		// 只有一个
                    blt_height = height;
                } else {
                    if (y_div == top_div){		// 第一个
                        blt_height = (MAX_AVATARBD_HEIGHT - top_modle);
                    } else {					// 最后一个
                        if (y_div == bottom_div && bottom_modle != 0) {
                            blt_height = bottom_modle;
                        } else {				// 中间
                            blt_height = MAX_AVATARBD_HEIGHT;
                        }
                    }
                }
				
                tmpOffsetY = (tmpOffsetY + blt_height);
                fillY = y_div==top_div ? top_modle : 0;
                tmpOffsetX = 0;
                x_div = left_div;
                while (x_div <= right_div) {
                    copyPixel_x = (sx + tmpOffsetX);
                    if (left_div == right_div) {			// 只有1列
                        blt_weight = width;
                    } else {
                        if (x_div == left_div) {			// 最左列
                            blt_weight = MAX_AVATARBD_WIDTH - left_modle;
                        } else {						// 最右列
                            if (x_div == right_div && right_modle != 0) {
                                blt_weight = right_modle;
                            } else {					// 中间列
                                blt_weight = MAX_AVATARBD_WIDTH;
                            }
                        }
                    }
                    tmpOffsetX = tmpOffsetX + blt_weight;
                    fillX = x_div==left_div ? left_modle : 0;
                    targetAvatarBD = this._avatarBDDict[y_div + "_" + x_div];		// 目标位图
                    if (src != null) {
                        targetAvatarBD.copyPixels(src, new Rectangle(copyPixel_x, copyPixel_y, blt_weight, blt_height), 
											new Point(fillX, fillY), null, null, true);
                    } else {
                        targetAvatarBD.fillRect(new Rectangle(fillX, fillY, blt_weight, blt_height), fillColor);
                    }
                    x_div++;
                }
                y_div++;
            }
        }
		
		/**
		 * 绘制
		 */
        public function run():void
		{
            var char:CCCharacter;
            var dirty_bound_list:Array;
			var bound:Bounds;
			var part:CCAvatarPart;
			var bound2:Bounds;
			var rect:Rectangle;
			
			// 清空矩形管理器内容
            this.clearBoundsArr.length = 0;
            this.restingAvatarPartArr.length = 0;
            this._dirtyBoundsMaker.clear();

			// 更新每个动画, 获得 clearBoundsArr, restingAvatarPartArr 
            var char_list:Array = this._scene.renderCharacters;		// 需要渲染的对象数组
            char_list.sortOn(["showIndex", "PixelY", "PixelX", "logicAnglePRI", "id"], [Array.NUMERIC, Array.NUMERIC, Array.NUMERIC, Array.NUMERIC, Array.NUMERIC]);
            for each (char in char_list) {
                char.runAvatar();				// 更新一帧, 将调用  run 来更新重绘区
            }
			
			// 添加重绘区到 _dirtyBoundsMaker
            this.clearBoundsArr = this.clearBoundsArr.concat(this.removeBoundsArr);
            this.clearBoundsArr.sortOn("top", Array.NUMERIC);
            for each (bound in this.clearBoundsArr) {
                if (!bound.isLine()){
                    this._dirtyBoundsMaker.addBounds(bound);
                }
            }
            this.removeBoundsArr.length = 0;
			
			// 获得重绘区列表, 要求各矩形是不相交的, 否则无法保证效率
            dirty_bound_list = this._dirtyBoundsMaker.getBoundsArr();
			
			// 如果是脏的部位, 则必然重绘全部. 这里处理 静止 的部位, 把矩形添加到他们的 renderRectArr 列表中
			for each (part in this.restingAvatarPartArr) {
				for each (bound in dirty_bound_list) {
					bound2 = Bounds.fromRectangle(part.cutRect);
					if (bound2.intersects(bound)) {
						rect = Bounds.toRectangle(bound2.intersection(bound));
						part.needRender = true;
						part.renderRectArr.push(rect);		// 对于静止对象, 添加矩形列表
					}
				}
			}
			
			// 清空重绘区，使用BitmapData.fillRect或者BitmapData.copyPixels
            this.clear(dirty_bound_list);
			
			// 绘制角色列表
			var len:int = 0;
            for each (char in char_list) {
                char.drawAvatar(this);		// 遍历每个 part.renderRectArr 绘制位图
            }
        }
    }
}