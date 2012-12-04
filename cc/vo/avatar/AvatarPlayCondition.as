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
        private var _playAtBegin:Boolean;
        private var _stayAtEnd:Boolean;
        private var _showEnd:Boolean;

        public function AvatarPlayCondition(PplayAtBegin:Boolean=false, PstayAtEnd:Boolean=false, PshowEnd:Boolean=false)
		{
            this._playAtBegin = PplayAtBegin;
			this._stayAtEnd = PstayAtEnd;
			this._showEnd = PshowEnd;
        }
		
		public function get showEnd():Boolean
		{
			return _showEnd;
		}

		public function set showEnd(value:Boolean):void
		{
			_showEnd = value;
		}

		public function get stayAtEnd():Boolean
		{
			return _stayAtEnd;
		}

		public function set stayAtEnd(value:Boolean):void
		{
			_stayAtEnd = value;
		}

		public function get playAtBegin():Boolean
		{
			return _playAtBegin;
		}

		public function set playAtBegin(value:Boolean):void
		{
			_playAtBegin = value;
		}

        public function clone():AvatarPlayCondition
		{
            var cond:AvatarPlayCondition = new AvatarPlayCondition(_playAtBegin, _stayAtEnd, _showEnd);
            return cond;
        }
    }
}