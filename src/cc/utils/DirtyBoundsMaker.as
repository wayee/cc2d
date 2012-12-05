package cc.utils
{
	import wit.draw.Bounds;
	import wit.utils.LNode;

	/**
	 * 这是一个脏矩形管理器.
	 * 
	 * 		. 这里的算法, 当发现2个矩形时, 只是简单的合并他们. 该算法可以优化, 并测试前后性能.
	 * 
	 */
    public class DirtyBoundsMaker
	{
        private var first:LNode;			// .data = Bounds
        private var last:LNode;
        private var beginLN:LNode;

		/**
		 * 清空重绘区, 初始化
		 */
        public function clear():void
		{
            this.first = null;
            this.last = null;
            this.beginLN = null;
        }
		
		/**
		 * 添加重绘区
		 */
        public function addBounds(bounds:Bounds, bFirst:Boolean=false):void
		{
            var prev_bound:Bounds;
            var intsec_bound:Bounds;
            var union_bound:Bounds;
			
			// 从 beginLN 开始
            var node:LNode = (bFirst) ? this.first : ((this.beginLN) || (this.first));		// beginLN || first
			
            if (node != null){
				
				
                while (node != null) {
                    prev_bound = (node.Data as Bounds);
					
					// 如果 prev_bound 在 bounds 上面, 则继续搜索下一个 node
                    if (prev_bound.bottom < bounds.top){
                        node = node.Next;
                    } 
					else {
						// prev_bound 在 bounds 的下面, 则 bounds 不和现有的矩形同行, 因此直接添加新矩形
                        if (prev_bound.top > bounds.bottom){
//                            this.add(new LNode(bounds), node.pre);
                            this.add(new LNode(bounds), node);
                            return;
                        }
						
						// 判断是否相交
                        if (prev_bound.intersects(bounds)){
                            intsec_bound = prev_bound.intersection(bounds);	// 取交集
							
							// 如果 交集 == bounds, 则  bounds <= prev_bound , 可以忽略.
                            if (intsec_bound.equals(bounds)){
                            } else {
								
								// 如果 交集 == prev_bound, 则  prev_bound <= bounds, 替换 prev_bound, 增加  bounds
                                if (intsec_bound.equals(prev_bound)){
									
									// 删除当前的 node, 增加新的 bounds, 它会继续吞并其它 node
                                    this.remove(node);				// 之后, beginLN = node.Next
                                    if (this.beginLN != null){		// node.Next 非空, 则继续添加, 继续合并
                                        this.addBounds(bounds);
                                    } else {
                                        this.add(new LNode(bounds), this.last);		// 否则添加到末尾
                                    }
                                }
								// 否则, 取并集		=>> 这种结果, 在绘图元素稍微多一点时, 立刻会扩大到整个屏幕需要重绘!
								else {
                                    union_bound = prev_bound.union(bounds);
                                    this.remove(node);
                                    this.beginLN = this.first;		// 从第一个开始
                                    if (this.beginLN != null){
                                        this.addBounds(union_bound);
                                    } else {
                                        this.add(new LNode(union_bound), this.last);
                                    }
                                }
                            }
                            return;
                        }
						
						// 不想交, 继续搜索下一个
                        node = node.Next;
                    }
                }

				// 新增唯一一个 
                if (node == null){
                    this.add(new LNode(bounds), this.last);
                }
            }
			// 新增一个
			else {
                this.add(new LNode(bounds), null);
            }
        }
		
		// 这是尝试, 但未实现的功能?   分解2个 Bounds 为多个 Bounds, 但,,,带来的计算量, 反而不如简单合并?
//        private function cutTwoIntersectedBounds(_arg1:Bounds, _arg2:Bounds):Array{
//            var _local6:Number;
//            var _local7:Number;
//            var _local8:Number;
//            var _local9:Number;
//            var _local10:Number;
//            var _local11:Number;
//            var _local3:Array = [];
//            var _local4:Array = [_arg1.top, _arg1.bottom, _arg2.top, _arg2.bottom].sort(Array.NUMERIC);
//            var _local5:Array = [_arg1.left, _arg1.right, _arg2.left, _arg2.right].sort(Array.NUMERIC);
//            var _local12:Bounds = ((_arg1.top)<=_arg2.top) ? _arg1 : _arg2;
//            _local6 = _local12.left;
//            _local7 = _local12.right;
//            _local8 = _local5[0];
//            _local9 = _local5[3];
//            _local12 = ((_arg1.bottom)>=_arg2.bottom) ? _arg1 : _arg2;
//            _local10 = _local12.left;
//            _local11 = _local12.right;
//            return ([new Bounds(_local6, _local7, _local4[0], _local4[1]), new Bounds(_local8, _local9, _local4[1], _local4[2]), new Bounds(_local10, _local11, _local4[2], _local4[3])]);
//        }
		
		/**
		 * 获得重绘区列表
		 */
        public function getBoundsArr():Array
		{
            var ret:Array = [];
            var _local2:LNode = this.first;
            while (_local2 != null) {
                ret.push(_local2.Data);
                _local2 = _local2.Next;
            }
            return (ret);
        }
		
		/**
		 * 添加新节点
		 * @param prev 如果为null, 则成为唯一1个节点
		 */
        private function add(node:LNode, prev:LNode=null):void
		{
			
			// 成为唯一1个节点
            if (prev == null){
                this.first = node;
                this.first.Pre = null;
                this.first.Next = null;
                this.last = node;
                this.last.Pre = null;
                this.last.Next = null;
            } else {
				// 添加到末尾
                if (prev == this.last) {
                    this.last.Next = node;
                    node.Pre = this.last;
                    this.last = node;
                }
				// 添加到中间
				else {
                    node.Pre = prev;
                    node.Next = prev.Next;
                    node.Pre.Next = node;
                    node.Next.Pre = node;
                }
            }
        }
		
        private function remove(node:LNode):void
		{
            if (node == this.first) {
                if (node == this.last) {
                    this.first = null;
                    this.last = null;
                } else {
                    this.first = node.Next;
                    this.first.Pre = null;
                }
            } else {
                if (node == this.last) {
                    this.last = this.last.Pre;
                    this.last.Next = null;
                } else {
                    node.Pre.Next = node.Next;
                    node.Next.Pre = node.Pre;
                }
            }
            this.beginLN = node.Next;
        }
    }
}