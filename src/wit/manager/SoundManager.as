package wit.manager
{
	import wit.cache.Cache;
	import wit.log.Log4J;
	import wit.sound.SoundData;
	import wit.sound.SoundThread;

	/**
	 * 声音管理器
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class SoundManager
	{
		public static var soundCache:Cache = CacheManager.creatNewCache("soundCache", 50);
		private static var _defaultSoundThread:SoundThread = new SoundThread();
		private static var _soundThreadArr:Array = [_defaultSoundThread];
		
		public function SoundManager()
		{
			throw new Error('This is a static class.');
		}
		
		/**
		 * 获取声音线程数量 
		 * @return int 数量
		 */
		public static function getSoundThreadsNum():int
		{
			return _soundThreadArr.length;
		}
		
		/**
		 * 获取声音数量 
		 * @return int 数量
		 */
		public static function getSoundsNum():int
		{
			var soundThread:SoundThread;
			var num:Number = 0;
			for each (soundThread in _soundThreadArr) {
				num = (num + soundThread.getSoundsNum());
			}
			return num;
		}
		
		/**
		 * 创建一个声音线程 
		 * @return sound thread
		 */		
		public static function creatNewSoundThread():SoundThread
		{
			var soundThread:SoundThread = (_soundThreadArr[_soundThreadArr.length] = new SoundThread());
			Log4J.add("SoundManager.creatNewSoundThread::_soundThreadArr.length:" + getSoundThreadsNum());
			return soundThread;
		}
		
		/**
		 * 播放声音 
		 * @param soundUrl
		 * @param startTime
		 * @param loops
		 * @param volume
		 * @param soundThread
		 * @return sound thread
		 */
		public static function playSound(soundUrl:String, startTime:Number=0, loops:int=0, 
										 volume:Number=-1, soundThread:SoundThread=null):SoundThread
		{
			var tmpSoundThread:SoundThread;
			if (soundThread != null){
				tmpSoundThread = soundThread;
				if (!hasSoundThread(tmpSoundThread)){
					_soundThreadArr.push(tmpSoundThread);
					Log4J.add(("SoundManager.playSound::_soundThreadArr.length:" + getSoundThreadsNum()));
				}
			} else {
				tmpSoundThread = _defaultSoundThread;
			}
			tmpSoundThread.playSound(soundUrl, startTime, loops, volume);
			
			return tmpSoundThread;
		}
		
		/**
		 * 设置声音 
		 * @param volume
		 */
		public static function setVolume(volume:Number):void
		{
			var soundThread:SoundThread;
			for each (soundThread in _soundThreadArr) {
				soundThread.setVolume(volume);
			}
		}
		
		/**
		 * 静音 
		 * @param b
		 */
		public static function setMute(b:Boolean):void
		{
			var soundThread:SoundThread;
			for each (soundThread in _soundThreadArr) {
				soundThread.setMute(b);
			}
		}
		
		/**
		 * 暂停 
		 * @param b
		 */
		public static function setPause(b:Boolean):void
		{
			var soundThread:SoundThread;
			for each (soundThread in _soundThreadArr) {
				soundThread.setPause(b);
			}
		}
		
		public static function getDefaultSoundThread():SoundThread
		{
			return _defaultSoundThread;
		}
		
		/**
		 * 删除所有声音线程 
		 */
		public static function removeAllSoundThreads():void
		{
			removeAllSounds();
			_soundThreadArr = [];
			Log4J.add("SoundManager.creatNewSoundThread::_soundThreadArr.length:0");
		}
		
		/**
		 * 删除所有声音 
		 */
		public static function removeAllSounds():void
		{
			var soundThread:SoundThread;
			for each (soundThread in _soundThreadArr) {
				soundThread.removeAllSounds();
			}
		}
		
		/**
		 * 删除声音线程 
		 * @param soundThread
		 */
		public static function removeSoundThread(soundThread:SoundThread):void
		{
			var tmpSoundThread:SoundThread;
			if (!soundThread){
				return;
			}
//			for each (tmpSoundThread in _tmpSoundThreadArr) {
//				if (soundThread == soundThread){
//					tmpSoundThread.removeAllSounds();
//					_soundThreadArr.splice(_soundTtmpSoundThreaddexOf(tmpSoundThread), 1);
//					ZLog.add(("SoundManager.creatNewSoundThread::_soundThreadArr.length:" + getSoundThreadsNum()));
//					break;
//				}
//			}
		}
		
		/**
		 * 删除声音 
		 * @param soundData
		 */
		public static function removeSound(soundData:SoundData):void
		{
			var soundThread:SoundThread;
			if (soundData == null){
				return;
			}
			for each (soundThread in _soundThreadArr) {
				soundThread.removeSound(soundData);
			}
		}
		
		/**
		 * 是否存在声音 线程
		 */
		public static function hasSoundThread(soundThread:SoundThread):Boolean
		{
			return _soundThreadArr.indexOf(soundThread) != -1;
		}
		
		/**
		 * 是否存在声音 
		 */
		public static function hasSound(soundData:SoundData):Boolean
		{
			var soundThread:SoundThread;
			for each (soundThread in _soundThreadArr) {
				if (soundThread.hasSound(soundData)){
					return true;
				}
			}
			return false;
		}
	}
}