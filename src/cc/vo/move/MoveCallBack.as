package cc.vo.move
{
    public class MoveCallBack
	{
        public var onMoveReady:Function;
        public var onMoveThrough:Function;
        public var onMoveArrived:Function;
        public var onMoveUnable:Function;

        public function clone():MoveCallBack {
            var mb:MoveCallBack = new MoveCallBack();
            mb.onMoveReady = this.onMoveReady;
            mb.onMoveThrough = this.onMoveThrough;
            mb.onMoveArrived = this.onMoveArrived;
            mb.onMoveUnable = this.onMoveUnable;
			
            return (mb);
        }
    }
} 