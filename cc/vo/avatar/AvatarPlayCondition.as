package cc.vo.avatar
{
	/**
	 * 播放方式
	 * 	<li> 是否初始为播放状态
	 * 	<li> 是否停留在末尾
	 * 	<li> 是否显示末尾
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class AvatarPlayCondition
	{
        private var playAtBegin:Boolean;
        private var stayAtEnd:Boolean;
        private var showEnd:Boolean;

        public function AvatarPlayCondition(p_playAtBegin:Boolean=false, p_stayAtEnd:Boolean=false, 
											p_showEnd:Boolean=false) {
            this.playAtBegin = p_playAtBegin;
			this.stayAtEnd = p_stayAtEnd;
			this.showEnd = p_showEnd;
        }
		
		public function get ShowEnd():Boolean {
			return showEnd;
		}

		public function set ShowEnd(value:Boolean):void {
			showEnd = value;
		}

		public function get StayAtEnd():Boolean {
			return stayAtEnd;
		}

		public function set StayAtEnd(value:Boolean):void {
			stayAtEnd = value;
		}

		public function get PlayAtBegin():Boolean {
			return playAtBegin;
		}

		public function set PlayAtBegin(value:Boolean):void {
			playAtBegin = value;
		}

        public function clone():AvatarPlayCondition {
            var cond:AvatarPlayCondition = new AvatarPlayCondition(playAtBegin, stayAtEnd, showEnd);
            return cond;
        }
    }
}