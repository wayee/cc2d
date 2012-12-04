package wit.sound
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;

	/**
	 * 声音数据
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class SoundData extends EventDispatcher
	{
		public static const LOOP_COMPLETE:String = "SoundData.LOOP_COMPLETE";
		
		public var _sound:Sound;
		private var _channel:SoundChannel;
		private var _leftLoops:int;
		private var _mute:Boolean = false;
		private var _pause:Boolean = false;
		private var _volume:Number = 1;
		
		public function SoundData(sound:Sound, channel:SoundChannel, leftLoops:int=0)
		{
			_sound = sound;
			_channel = channel;
			_leftLoops = leftLoops;
			_volume = _channel.soundTransform.volume;
			_channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
		}
		
		/**
		 * 获取音量 
		 */		
		public function getVolume():Number
		{
			return _volume;
		}
		
		/**
		 * 音量设置 
		 */
		public function setVolume(volume:Number):void
		{
			_volume = volume;
			_channel.soundTransform = new SoundTransform(_volume);
		}
		
		/**
		 * 获取静音状态 
		 */
		public function getMute():Boolean
		{
			return _mute;
		}
		
		/**
		 * 静音 
		 */
		public function setMute(b:Boolean):void
		{
			_mute = b;
			if (_mute) {
				_channel.soundTransform = new SoundTransform(0);
			} else {
				setVolume(getVolume());
			}
		}
		
		/**
		 * 获取暂停状态 
		 * @return 
		 * 
		 */
		public function getPause():Boolean
		{
			return _pause;
		}
		
		/**
		 * 暂停 
		 */
		public function setPause(b:Boolean):void
		{
			var pos:Number;
			_pause = b;
			if (_pause) {
				pos = _channel.position;
				_channel.stop();
			} else {
				_channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
				_channel = sound.play(_channel.position, 0, _channel.soundTransform);
				_channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			}
		}
		
		/**
		 * 停止并清理 
		 */
		public function stopAndDispose():void
		{
			_channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			_channel.stop();
			_leftLoops = 0;
		}
		
		public function get sound():Sound
		{
			return _sound;
		}
		
		/**
		 * 私有方法 
		 */		
		
		private function soundCompleteHandler(event:Event):void
		{
			_channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			if (_leftLoops > 0){
				_leftLoops--;
				_channel = sound.play(0, 0, _channel.soundTransform);
				_channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			} else {
				dispatchEvent(new Event(LOOP_COMPLETE));
			}
		}
	}
}