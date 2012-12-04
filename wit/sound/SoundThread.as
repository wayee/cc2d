package wit.sound
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import wit.manager.RslLoaderManager;
	import wit.manager.SoundManager;

	/**
	 * 声音线程
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class SoundThread
	{
        private var _soundArr:Array;
        private var _mute:Boolean = false;
        private var _pause:Boolean = false;
        private var _volume:Number = 1;

        public function SoundThread()
		{
            this._soundArr = [];
            super();
        }
		
		/**
		 * 声音数量 
		 */
        public function getSoundsNum():int
		{
            return this._soundArr.length;
        }
		
		/**
		 * 音量 
		 */
        public function getVolume():Number
		{
            return this._volume;
        }
		
		/**
		 * 设置音量 
		 */
        public function setVolume(volume:Number):void
		{
            var soundData:SoundData;
            if (volume < 0){
                volume = 0;
            }
            if (volume > 1){
                volume = 1;
            }
            if (this._volume != volume) {
                this._volume = volume;
                for each (soundData in this._soundArr) {
                    soundData.setVolume(this._volume);
                }
            }
        }
		
		/**
		 * 获取静音状态 
		 */
        public function getMute():Boolean
		{
            return this._mute;
        }
		
		/**
		 * 静音 
		 */
        public function setMute(b:Boolean):void
		{
            var soundData:SoundData;
            if (this._mute != b){
                this._mute = b;
                for each (soundData in this._soundArr) {
                    soundData.setMute(this._mute);
                }
            }
        }
        
		/**
		 * 获取暂停状态 
		 */
		public function getPause():Boolean
		{
            return this._pause;
        }
		
		/**
		 * 暂停 
		 */
        public function setPause(b:Boolean):void
		{
            var soundData:SoundData;
            if (this._pause != b) {
                this._pause = b;
                for each (soundData in this._soundArr) {
                    soundData.setPause(this._pause);
                }
            }
        }
		
		/**
		 * 是否存在声音 
		 * @param data
		 * @return bool
		 */
        public function hasSound(data:SoundData):Boolean
		{
            return this._soundArr.indexOf(data) != -1;
        }
		
		/**
		 * 删除声音 
		 * @param data
		 */
        public function removeSound(data:SoundData):void
		{
            var soundData:SoundData;
            for each (soundData in this._soundArr) {
                if (soundData == data){
                    soundData.removeEventListener(SoundData.LOOP_COMPLETE, this.soundLoopCompleteHandler);
                    soundData.stopAndDispose();
                    this._soundArr.splice(this._soundArr.indexOf(soundData), 1);
                    break;
                }
            }
        }
		
		/**
		 * 删除所有声音 
		 */
        public function removeAllSounds():void
		{
            var soundData:SoundData;
            for each (soundData in this._soundArr) {
                soundData.removeEventListener(SoundData.LOOP_COMPLETE, this.soundLoopCompleteHandler);
                soundData.stopAndDispose();
            }
            this._soundArr = [];
        }
		
		/**
		 * 播放声音 
		 * @param soundUrl 声音路径
		 * @param startTime 开始时间
		 * @param loops 循环
		 * @param volume 音量
		 * @return sound data
		 */
        public function playSound(soundUrl:String, startTime:Number=0, loops:int=0, volume:Number=-1):SoundData
		{
            var sd:SoundData = null;
            var sound:Sound = null;
            var re1:RegExp = null;
            var re2:RegExp = null;
            var str1True:Boolean = false;
            var str2True:Boolean = false;
            var selfVolume:Number;
            var nowSoundTransform:SoundTransform = null;
            var channel:SoundChannel = null;
			
			// 缓存中获取
            if (SoundManager.soundCache.has(soundUrl)) {
                sound = (SoundManager.soundCache.get(soundUrl) as Sound);
            } else {
                sound = (RslLoaderManager.getInstance(soundUrl) as Sound);
                if (sound){
                    SoundManager.soundCache.push(sound, soundUrl);
                } else {
                    soundUrl = soundUrl.toLowerCase();
                    re1 = new RegExp("^.+.mp3$");
                    re2 = new RegExp("^.+.wmv$");
                    str1True = re1.test(soundUrl);
                    str2True = re2.test(soundUrl);
                    if (str1True || str2True) {
                        sound = new Sound();
                        sound.addEventListener(Event.COMPLETE, this.soundLoadHandler);
                        sound.addEventListener(IOErrorEvent.IO_ERROR, this.soundLoadHandler);
                        sound.load(new URLRequest(soundUrl));
                    }
                }
            }
			
            if (sound == null){
                return sd;
            }
            try {
                selfVolume = volume >= 0 && volume <= 1 ? volume : this._volume;
                nowSoundTransform = new SoundTransform(selfVolume);
                channel = sound.play(startTime, 0, nowSoundTransform);
				
                if (channel != null) {
                    sd = new SoundData(sound, channel, (loops - 1));
                    sd.addEventListener(SoundData.LOOP_COMPLETE, this.soundLoopCompleteHandler);
                    this._soundArr.push(sd);
                    if (this._mute){
                        sd.setMute(true);
                    }
                    if (this._mute){
                        sd.setPause(true);
                    }
                }
            } catch(e:Error) {
            }
            return (sd);
        }
		
		/**
		 * 私有方法 
		 */		
		
        private function soundLoadHandler(event:Event):void
		{
            var tmpSoundData:SoundData;
            var sound:Sound = Sound(event.currentTarget);
            switch (event.type){
                case Event.COMPLETE:
                    SoundManager.soundCache.push(sound, sound.url);
                    break;
                case IOErrorEvent.IO_ERROR:
                    for each (tmpSoundData in this._soundArr) {
                        if (tmpSoundData.sound == sound){
                            tmpSoundData.removeEventListener(SoundData.LOOP_COMPLETE, this.soundLoopCompleteHandler);
                            tmpSoundData.stopAndDispose();
                            this._soundArr.splice(this._soundArr.indexOf(tmpSoundData), 1);
                        }
                    }
                    break;
            }
        }
		
        private function soundLoopCompleteHandler(event:Event):void
		{
            var tmpSoundData:SoundData;
            var soundData:SoundData = (event.currentTarget as SoundData);
            for each (tmpSoundData in this._soundArr) {
                if (tmpSoundData == soundData){
                    tmpSoundData.removeEventListener(SoundData.LOOP_COMPLETE, this.soundLoopCompleteHandler);
                    tmpSoundData.stopAndDispose();
                    this._soundArr.splice(this._soundArr.indexOf(tmpSoundData), 1);
                    break;
                }
            }
        }
    }
}