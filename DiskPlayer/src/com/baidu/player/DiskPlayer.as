package com.baidu.player {
	
	import com.baidu.config.PlayerConfig;
	import com.baidu.config.PlayerConst;
	import com.baidu.ui.PlayerUI;
	import com.baidu.ui.base.SButton;
	import com.baidu.ui.controls.progressbar.ProgressBar;
	import com.baidu.ui.controls.subtitle.SubTitleButton;
	import com.baidu.ui.controls.volume.VolumeButton;
	import com.baidu.utils.AjaxUtils;
	import com.baidu.utils.CommonUtils;
	import com.baidu.utils.PlayerExternalInterface;
	
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.NetStream;
	import flash.net.SharedObject;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import org.denivip.osmf.plugins.HLSPluginInfo;
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.OSMFSettings;
	
	[SWF(backgroundColor="0x000000")]
	public class DiskPlayer extends PlayerUI {
		
		private var config:PlayerConfig;
		private var player:MediaPlayer = null;
		private var factory:DefaultMediaFactory;
		private var container:MediaContainer;
		private var hlsPluginInfo:HLSPluginInfo = null;
		private var speedArray:Array = [];
		private var speedArrayTemp:Array = [];
		
		private var flagIsLiving:Boolean = false;
		private var retryCount:Number = 0;
		private var retryTimerId:Number = -1;
		private var flagIsReload:Boolean = false;
		private var flagReloadSeek:Boolean =false;
		
		private var lastClickTime:int = 0;
		
		private var boolUserSeek:Boolean = false;
		private var boolChangeBufferTime:Boolean = false;
		private var userSeekStartTime:int = 0;
		private var bufferStartTime:int = 0;
		
		private var initErrorData:Object = null;
		
		private var playedOver:Boolean = false;
		
		private var intervalTimeId:uint = 0;
		
		private var flagSendOnReady:Boolean = false;
		private var lastPosition:Number = 0;
		
		private var storage:SharedObject = null;
		
		public function DiskPlayer() {
			if (stage) {
				init();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		private function init(e:Event = null):void {
			e && removeEventListener(Event.ADDED_TO_STAGE,init);
			var loaderParams:Object = loaderInfo.parameters;
			if (loaderParams.file) {
				config = PlayerConfig.initConfig(loaderParams);
				PlayerUI.MOVIEID = loaderParams.md5 == 'null' ? '' : loaderParams.md5;
				PlayerUI.FILENAME = loaderParams.filename == 'null' ? '' : loaderParams.filename;
				PlayerUI.ShowSubSearchPanel = config.GetShowSearch() == '1' ? true : false;
			} else {
				config = new PlayerConfig();
				config.SetAutoStart(false);
				//config.SetFile("http://zq.baidu.com:8080/static/avatar-tlrf_h480p/avatar-tlrf_h480p.m3u8");
				//config.SetFile("http://zq.baidu.com:8080/static/video.m3u8");
				//config.SetFile('http://zq.baidu.com:8080/static/avatar-tlrf_h480p/avatar-tlrf_h480p00.mp4');
				//config.SetFile("http://zq.baidu.com:8080/static/video1.m3u8");
				//config.SetResourceType('mp4');
			}
			//call onload method
			if (config.GetOnLoadFunc()) {
				ExternalInterface.call(config.GetOnLoadFunc());
			}
			OSMFSettings.enableStageVideo = false;
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenChangedHandler);
			
			//install hls plugin
			this.initHSLPlugin();
			//user interface
			this.addExternalInterface();
			//init container
			this.initPlayerContainer();
		}
		private function initPlayerContainer():void {
			
			//the simplified api controller for media
			player = new MediaPlayer();
			player.autoRewind = false;
			player.bufferTime = 1;
			player.autoPlay = false;
			player.loop = false;
			
			player.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekChange);
			player.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onPlaybackChange);
			player.addEventListener(TimeEvent.COMPLETE, onPlaybackChange);
			player.addEventListener(TimeEvent.DURATION_CHANGE, onPlaybackChange);
			player.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaLoadStateChange);
			player.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			
			container = new MediaContainer();
			initPlayer(this.width, this.height, container);
			
			loadPlayerMedia();
			resetPlayerConfig();
		}
		
		private function loadPlayerMedia(flagReload:Boolean=false):void {
			unloadResource();
			var fileUrl:String = config.GetFile() + (flagReload ? ('&t=' + Math.random()) : ''); 
			createResource(fileUrl);
			resizeVideoContainer();
		}
		private function reloadPlayerMedia():void {
			container.visible = false;
			playedOver = false;
			flagIsLiving = false;
			flagReloadSeek = false;
			flagIsReload = true;
			loadPlayerMedia(true);
		}
		private function unloadResource():void
		{
			if (player.canPlay && player.state == MediaPlayerState.PLAYING)
				player.stop();
			player.media = null;
		}
		private function createResource(url:String):void
		{
			var res:URLResource = new URLResource(url);
			if (config.GetResourceType() === 'mpeg') {
				res.addMetadataValue("content-type", "application/x-mpegURL");
			}
			var element:MediaElement = factory.createMediaElement(res);
			var elementLayout:LayoutMetadata = new LayoutMetadata();
			elementLayout.percentHeight = 100;
			elementLayout.percentWidth = 100;
			elementLayout.scaleMode = ScaleMode.LETTERBOX;
			elementLayout.layoutMode = LayoutMode.NONE;
			elementLayout.verticalAlign = VerticalAlign.MIDDLE;
			elementLayout.horizontalAlign = HorizontalAlign.CENTER;
			element.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, elementLayout);
			container.addMediaElement(element);
			player.media = element;
		}
		
		private function resetPlayerConfig():void {
			//progress bar cursor
			pBar.cursor = 0;
			//progress bar buffer
			pBar.buffer = 0;
			storage = PlayerUI.getStorage();
			//volume
			
			if (typeof storage.data[PlayerConst.CACHE_VOLUME] == 'undefined') {
				storage.data[PlayerConst.CACHE_VOLUME] = 60;
				storage.flush();
			}
			var storageVolume:int = Number(storage.data[PlayerConst.CACHE_VOLUME]); 
			vBar.volume = storageVolume;
			setVolume(storageVolume, true);
			playBtn.show();
			pauseBtn.hide();
			bigPlayBtn.hide();
			bigPauseBtn.hide();
			miniBtn.hide();
			fullBtn.show();
			loading.show();
			resizeScreen();
			//init srt
			initSrt();
			//add keybord event
			addKeyboardEvent();
			//mouse event
			addMouseEvent();
		}
		
		
		/**
		 * add user event
		 */
		private function addKeyboardEvent():void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboard);
		}
		private function addMouseEvent():void {
			bigPlayBtn.addEventListener(MouseEvent.CLICK, addMouseDbClickEvent);
			bigPauseBtn.addEventListener(MouseEvent.CLICK, addMouseDbClickEvent);
		}
		private function addMouseDbClickEvent(e:MouseEvent):void {
			if (getTimer()-lastClickTime < 350) {
				changeFullScreenState();
			}
			lastClickTime = getTimer();
		}
		
		/**
		 * user interface 
		 */
		private function addExternalInterface():void {
			PlayerExternalInterface.addEventListen('play', play);
			PlayerExternalInterface.addEventListen('seek', seek);
			PlayerExternalInterface.addEventListen('pause', pause);
			PlayerExternalInterface.addEventListen('getState', getState);
			PlayerExternalInterface.addEventListen('getVolume', getVolume);
			PlayerExternalInterface.addEventListen('setVolume', setVolume);
			PlayerExternalInterface.addEventListen('getPosition', getPosition);
			PlayerExternalInterface.addEventListen('getDuration', getDuration);
			PlayerExternalInterface.addEventListen('hideControlBar', hiddenControlBar);
		}
		private function play():void {
			if (player != null && player.canPlay) {
				var result:Boolean = true;
				if (config.GetOnBeforePlayFunc()) {
					try {
						result = Boolean(ExternalInterface.call(config.GetOnBeforePlayFunc()));
					} catch(error:Error) {
					}
				}
				if (!result) {
					return;
				}
				player.play();
				if (config.GetOnPlayFunc()) {
					ExternalInterface.call(config.GetOnPlayFunc());
				}
			}
		}
		private function hiddenControlBar():void {
			if (player != null) {
				hideControlBar();
			}
		}
		private function seek(num:Number):void {
			if (player != null && player.canSeek && player.canSeekTo(num)) {
				
				var result:Boolean = true;
				if (config.GetOnBeforeSeekFunc()) {
					try {
						result = Boolean(ExternalInterface.call(config.GetOnBeforeSeekFunc(), num, player.duration));
					} catch(error:Error) {
					}
				}
				if (!result) {
					return;
				}
				
				boolUserSeek = true;
				userSeekStartTime = getTimer();
				player.seek(num);
				
				if (config.GetOnSeekFunc()) {
					ExternalInterface.call(config.GetOnSeekFunc(), num, player.duration);
				}
			}
		}
		private function pause():void {
			if (player != null && player.canPause) {
				player.pause();
				if (config.GetOnPauseFunc()) {
					ExternalInterface.call(config.GetOnPauseFunc());
				}
			}
		}
		private function getState():String {
			if (player != null) {
				return player.state;
			}
			return '';
		}
		private function getVolume():Number {
			if (player != null) {
				return player.volume * 100;
			}
			return 0;
		}
		private function setVolume(volume:Number, flagInit:Boolean = false):void {
			if (player != null) {
				
				if (player.volume * 100 === volume && volume <= 100) {
					return;
				}
				
				var tips:String = '';
				if (volume === 100 && player.volume <= 1) {
					tips = '当前音量：100%  (按↑键继续放大音量)';
				} else if (volume > 100 && volume <= 200) {
					tips = '当前音量：' + (100 + ((volume - 100) / 25 * 100)) + '%';
				} else if (volume > 200){
					tips = '音量已调至最大';
					volume = 200;
				} else if (volume <= 0) {
					tips = '静音模式';
					volume = 0;
				} else {
					tips = '当前音量：' + volume + '%';
				}
				
				
				if (tips && !flagInit) {
					PlayerUI.showLoadingTips(tips, 3000);
				}
				
				storage.data[PlayerConst.CACHE_VOLUME] = volume;
				storage.flush();
				volume = volume / 100;
				player.volume = volume;
			}
		}
		private function getPosition():Number {
			if (player != null) {
				return player.currentTime;
			}
			return 0;
		}
		private function getDuration():Number {
			if (player != null) {
				return player.duration;
			}
			return 0;
		}
		
		
		/**
		 * error method 
		 */
		private function callBrowserError(data:Object):void{
			if (config.GetOnPlayerErrorFunc()) {
				if (initErrorData != null && data == null) {
					return;
				}
				initErrorData = data;
				ExternalInterface.call(config.GetOnPlayerErrorFunc(), data);
			}
		}
		private function callErrorFunc(obj:Object):void {
			if (obj && typeof obj.islive == 'boolean') {
				flagIsLiving = obj.islive;
				return;
			}
			if (obj != null && obj.analytics) {
				obj.fsid = config.GetFsid();
			}
			if (obj == null || (obj && obj.httpstatus && obj.httpstatus != 404)) {
				retryCount ++;
				if (retryCount > 4) {
					callBrowserError(obj);
				} else {
					clearTimeout(retryTimerId);
					retryTimerId = setTimeout(function():void {
						loadPlayerMedia();
					}, 3000);
				}
			} else {
				callBrowserError(obj);
			}
		}
		
		
		
		/**
		 * player event
		 */
		protected function onMediaLoadStateChange(event:MediaPlayerStateChangeEvent):void {
			switch ( event.state ) {
				case MediaPlayerState.BUFFERING :
					if (!boolChangeBufferTime && !boolUserSeek) {
						bufferStartTime = getTimer();
						boolChangeBufferTime = true;
					}
					
					loading.show();
					playBtn.hide();
					bigPlayBtn.hide();
					bigPauseBtn.hide();
					pauseBtn.show();
					if (flagIsLiving && (getDuration() - getPosition()) < 5) {
						PlayerUI.showLoadingTips('视频正在转码，播放过程中可能稍有卡顿', 5000);
					}
					
					break;
				case MediaPlayerState.PLAYBACK_ERROR :
					callErrorFunc(null);
					break;
				case MediaPlayerState.PLAYING :
					if (flagIsReload && lastPosition > 0 && flagReloadSeek == false) {
						seek(lastPosition);
						flagReloadSeek = true;
					}
					if (!flagSendOnReady) {
						flagSendOnReady = true;
						if (config.GetOnReadyFunc()) {
							ExternalInterface.call(config.GetOnReadyFunc());
						}
					}
					if(boolUserSeek) {
						//send user seek buffer time
						sendReport('seekVideoBufferTime', getTimer() - userSeekStartTime);
					} else if (boolChangeBufferTime) {
						//send buffer time
						sendReport('videoBufferTime', getTimer() - bufferStartTime);
					}
					boolChangeBufferTime = false;
					boolUserSeek = false;
					
					if (flagIsReload) {
						loading.show();
						playBtn.hide();
						bigPlayBtn.hide();
						bigPauseBtn.hide();
						pauseBtn.show();
					} else {
						loading.hide();
						playBtn.hide();
						bigPlayBtn.hide();
						bigPauseBtn.show();
						pauseBtn.show();
					}
					
					break;
				case MediaPlayerState.PAUSED :
					loading.hide();
					playBtn.show();
					bigPlayBtn.show();
					bigPauseBtn.hide();
					pauseBtn.hide();
					break;
				case MediaPlayerState.READY :
					if (!playedOver) {
						if (config.GetAutoStart()) {
							play();
						} else {
							loading.hide();
							playBtn.show();
							bigPlayBtn.show();
							bigPauseBtn.hide();
							pauseBtn.hide();
						}
					}else {
						if (config.GetOnPlayOverFunc()) {
//							if (!flagIsLiving) {
								ExternalInterface.call(config.GetOnPlayOverFunc());
//							} else {
//								PlayerUI.showLoadingTips('视频正在转码，播放过程中可能稍有卡顿', 3000);
//							}
						}
						
//						if (flagIsLiving) {
//							loading.show();
//							playBtn.hide();
//							bigPlayBtn.hide();
//							bigPauseBtn.hide();
//							pauseBtn.show();
//							lastPosition = getPosition() - 2;
//							reloadPlayerMedia();
//						} else {
						
							player.stop();
							
							loading.hide();
							playBtn.show();
							bigPlayBtn.show();
							bigPauseBtn.hide();
							pauseBtn.hide();
							pBar.cursor = 0;
							//seek(0);
							//pause();
							//cancel full screen
							if(stage.displayState == StageDisplayState.FULL_SCREEN) {
								stage.displayState = StageDisplayState.NORMAL;
							}
						//}
					}
					break;
			}
		}
		protected function onPlaybackChange( event:TimeEvent ):void {
			switch ( event.type ) {
				case TimeEvent.CURRENT_TIME_CHANGE :
					if (event.time > player.duration) {
						break;
					}
					if (flagIsReload && lastPosition != 0 && event.time >= lastPosition && container.visible == false && flagReloadSeek) {
						flagIsReload = false;
						flagReloadSeek = false;
						container.visible = true;
						lastPosition = 0;
					}
					tBar.time = CommonUtils.format(event.time);
					pBar.cursor = Number(event.time / player.duration * 100);
					
					//trace('=============================', player.bufferLength);
					
					subTitleBar.setPlayTime(event.time);
					if (event.time != 0 && event.time >= player.duration -3) {
						playedOver = true;
					}
					if (flagSendOnReady && config.GetOnTimeFunc()) {
						ExternalInterface.call(config.GetOnTimeFunc(), event.time, player.duration);
					}
					sendReportSpeed();
					break;
				case TimeEvent.DURATION_CHANGE :
					if (player.duration > 0) {
						tBar.total = CommonUtils.format(player.duration);
						pBar.setDurationTime(player.duration);
					}
					break;
			}
		}
		private function onLoadStateChange(e:LoadEvent):void
		{
			if (e.loadState == LoadState.READY)
			{
				var nsLoadTrait:NetStreamLoadTrait = player.media.getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
				var stream:NetStream = nsLoadTrait.netStream;
				stream.addEventListener(HTTPStreamingEvent.DOWNLOAD_COMPLETE, onDownloadComplete);
			}
		}
		
		
		private function onDownloadComplete(event:HTTPStreamingEvent):void
		{
			if (event.downloader.downloadBytesCount <= 0) {
				return;
			}
			
			//pBar.buffer = Number((player.currentTime + player.bufferLength) / player.duration * 100);
			
			//trace('=============================== buffer Time: ', player.bufferTime, '   buffer Length:', player.bufferLength);
			
			var speedObj:Object = {"url": event.url, bytes: event.downloader.downloadBytesCount, secs: event.downloader.downloadDuration};
			speedArray.push(speedObj);
			speedArrayTemp.push(speedObj);
		}
		private function fullScreenChangedHandler(evt:FullScreenEvent):void {
			if (player) {
				//需要等到全屏状态真正结束后进行resize， so 添加setTimeout延迟
				setTimeout(function():void {
					resizeScreen();
					pBar.cursor = Number(player.currentTime / player.duration * 100);
				}, 1000);
			}
		}
		
		
		/**
		 * analytis
		 */
		private function sendReport(type:String, time:int):void {
			
			var reportMsg:Object = {analytics: true, m3uLoadType: type, bufferTime: time},
				flagBugger:Boolean = type == 'videoBufferTime';
			
			if (flagBugger) {
				reportMsg.speedArray = speedArrayTemp;
			}
			callErrorFunc(reportMsg);
			
			if (flagBugger) {
				speedArrayTemp.length = 0;
			}
		}
		
		private function sendReportSpeed():void {
			intervalTimeId++;
			if (intervalTimeId > 20) {
				intervalTimeId = 0;
				var reportMsg:Object = {analytics: true, analyticsSpeed: true, speedArray: speedArray};
				callErrorFunc(reportMsg);
			}
		}
		
		/**
		 * user event 
		 */
		override public function onPlayerEvent(code:String,param:*=null):void{
			switch (code) {
				case VolumeButton.VOLUME :
					if (getVolume() >= 100 && param === 100) {
						return;
					}
					vBar.volume = param;
					setVolume(param);
					break;
				case ProgressBar.PROGRESS :
					pBar.cursor = param;
					pBar.buffer = 0;
					seek(param*player.duration/100);
					play();
					break;
				case SButton.BIGPLAY :
					playBtn.hide();
					bigPlayBtn.hide();
					bigPauseBtn.show();
					pauseBtn.show();
					play();
					break;
				case SButton.BIGPAUSE :
					playBtn.show();
					bigPlayBtn.show();
					bigPauseBtn.hide();
					pauseBtn.hide();
					pause();
					break;
				case SButton.PLAY :
					playBtn.hide();
					bigPlayBtn.hide();
					bigPauseBtn.show();
					pauseBtn.show();
					play();
					break;
				case SButton.PAUSE :
					playBtn.show();
					bigPlayBtn.show();
					bigPauseBtn.hide();
					pauseBtn.hide();
					pause();
					break;
				case SButton.FULLSCREEN :
					changeFullScreenState();
					break;
				case SButton.MINISCREEN :
					changeFullScreenState();
					break;
				case StageDisplayState.FULL_SCREEN :
					miniBtn.show();
					fullBtn.hide();
					break;
				case StageDisplayState.NORMAL :
					miniBtn.hide();
					fullBtn.show();
					break;
				case SubTitleButton.SUBSEARCH :
					if (config.GetSearchSrtFunc()) {
						PlayerExternalInterface.eval(config.GetSearchSrtFunc());
					}
					break;
			}
		}
		protected function onSeekChange(event:SeekEvent):void {
			if (!isNaN(event.time)) {
				tBar.time = CommonUtils.format(event.time);
			}
		}
		protected function changeFullScreenState():void {
			
			if (!flagSendOnReady)
				return;
			var state:String = stage.displayState;
			if(state == StageDisplayState.NORMAL) {
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}else {
				stage.displayState = StageDisplayState.NORMAL;
			}
		}
		private function onKeyboard(e:KeyboardEvent):void {
			
			var keyValue:int = 0;
			switch(e.keyCode) 
			{
				case 37:
					keyValue = getPosition() - 22;
					seek(keyValue <= 0 ? 0 : keyValue);
					break;					
				case 39:
					keyValue = getPosition() + 22;
					if (keyValue < getDuration()) {
						seek(keyValue);
					}
					break;
				case 38: 
					keyValue = getVolume();
					if (keyValue >= 100) {
						keyValue = keyValue + 25;
					} else {
						keyValue = keyValue + 10;
						if (keyValue > 100 && keyValue < 110) {
							keyValue = 100;
						}
					}
					setVolume(keyValue);
					vBar.volume = getVolume();
					break;
				case 40:
					keyValue = getVolume();
					if (keyValue > 100) {
						keyValue = keyValue - 25;
					} else {
						keyValue = keyValue - 10;
					}
					if(keyValue >= 200) {
						setVolume(200);
					} else if (keyValue < 0) {
						setVolume(0);
					} else {
						setVolume(keyValue);
					}
					vBar.volume = getVolume();
					break;
				case 32:
					var state:String = player.state;
					if(state == 'playing') {
						pause();
					}else if(state == 'paused') {
						play();
					}
					break;	
			}
		}
		
		/**
		 * srt methods
		 */
		private function initSrt():void {
			if (this.config.GetSrturl()) {
				new AjaxUtils(this.config.GetSrturl(), 'get', null, function(e:Event):void {
					var data:Object = JSON.parse(e.target.data.toString());
					if (data.errno == 0 && data.records && data.records.length > 0) {;
						showSrt(data.records, false);
					} else {
						stBtn.updateSrtTips();
					}
				});
			} else {
				stBtn.updateSrtTips();
			}
		}
		private function showSrt(srcDataList:Array, fromSearch:Boolean):void {
			var tmpObj:Object;
			var srtList:Array = new Array();
			for (var i:int = 0, len:int = srcDataList.length; i < len; i++) {
				tmpObj = srcDataList[i];
				srtList.push(CommonUtils.srtFormat(tmpObj));
			}
			stBtn.addSrtData(srtList, fromSearch);
		}
		
		/**
		 * hls mehods
		 */
		private function initHSLPlugin():void {
			factory = new DefaultMediaFactory();
			factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, handlePluginLoad);
			factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, handlePluginLoadError);
			
			HLSPluginInfo.errorFunc = callErrorFunc;
			hlsPluginInfo = new HLSPluginInfo();
			
			factory.loadPlugin(new PluginInfoResource(hlsPluginInfo));
		}
		private function handlePluginLoad(event:MediaFactoryEvent):void {}
		private function handlePluginLoadError(event:MediaFactoryEvent):void {}
	}
}