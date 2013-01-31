package cc.vo.avatar
{
    public class AvatarPlayCallBack
	{
        public var onPlayBeforeStart:Function;
        public var onPlayStart:Function;
        public var onPlayUpdate:Function;
        public var onPlayComplete:Function;
        public var onAdd:Function;
        public var onRemove:Function;

        public function clone():AvatarPlayCallBack {
            var apcb:AvatarPlayCallBack = new AvatarPlayCallBack();
            apcb.onPlayBeforeStart = this.onPlayBeforeStart;
            apcb.onPlayStart = this.onPlayStart;
            apcb.onPlayUpdate = this.onPlayUpdate;
            apcb.onPlayComplete = this.onPlayComplete;
            apcb.onAdd = this.onAdd;
            apcb.onRemove = this.onRemove;
            
			return apcb;
        }
    }
}