package com.baidu.ui {
	import com.baidu.ui.base.SButton;
	import com.baidu.ui.controls.loadingbar.LoadingBar;
	import com.baidu.ui.controls.loadingbar.LoadingTips;
	import com.baidu.ui.controls.progressbar.ProgressBar;
	import com.baidu.ui.controls.progressbar.ProgressBarTip;
	import com.baidu.ui.controls.res.Bar;
	import com.baidu.ui.controls.res.VideoLightBar;
	import com.baidu.ui.controls.sbutton.*;
	import com.baidu.ui.controls.subtitle.*;
	import com.baidu.ui.controls.subtitle.SubTitleBar;
	import com.baidu.ui.controls.subtitle.SubTitleButton;
	import com.baidu.ui.controls.timebar.TimeBar;
	import com.baidu.ui.controls.volume.VolumeButton;
	import com.baidu.ui.controls.volume.VolumePanel;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Mouse;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import transitions.Tweener;

	public class PlayerUI extends Sprite {

		//初始化屏幕宽
		private var iw:int;
		//初始化屏幕高
		private var ih:int;
		//当前屏幕宽
		private var cw:int;
		//当前屏幕高
		private var ch:int;
		//事件临时句柄
		private var setTimeoutId:uint;

		private var pTip:ProgressBarTip;

		private var vTip:VolumePanel;

		private var bar:Bar;

		private var controlContainer:Sprite;
		
		private var videoContainer:Sprite;

		private var videoLightBar:VideoLightBar;
		
		public var loading:LoadingBar;

		public var pBar:ProgressBar;

		public var vBar:VolumeButton;

		public var tBar:TimeBar;

		public var bigPlayBtn:BigPlayButton;

		public var bigPauseBtn:BigPauseButton;

		public var playBtn:PlayButton;

		public var pauseBtn:PauseButton;

		public var stBtn:SubTitleButton;

		public var miniBtn:MiniscreenButton;

		public var fullBtn:FullscreenButton;

		public var subTitleBar:SubTitleBar;

		public static var loadingTips:LoadingTips;
		
		private var bSeparator1:ButtonSeparator;
		private var bSeparator2:ButtonSeparator;
		
		public function PlayerUI() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			initRightMouseMenu();
			//testInitApp();
		}
		public function initPlayer(w:int=600,h:int=400,vc:Sprite=null):void {
			iw = w;
			ih = h;
			initElement(vc);
			resizeScreen();
			initEvent();
		}
		
		public function resizeVideoContainer():void {
			if (videoContainer) {
				videoContainer.x = 0;
				videoContainer.y = 0;
				videoContainer.width = stage.stageWidth;
				videoContainer.height = stage.stageHeight;
			}
		}
		
		private function initElement(vc:Sprite=null):void {

			//添加视频容器
			addChild(videoContainer=vc);
			
			//增加亮度调节面板
			videoLightBar = new VideoLightBar;
			videoLightBar.alpha=0;
			addChild(videoLightBar);
			
			//添加字幕
			subTitleBar=new SubTitleBar;
			addChild(subTitleBar);
			
			//loading
			loading = new LoadingBar  ;
			loading.visible = false;
			addChild(loading);
			
			//添加进度条的提示TIP到大容器;
			pTip = new ProgressBarTip  ;
			addChild(pTip);
			
			//添加中央播放按钮
			bigPlayBtn = new BigPlayButton();
			bigPlayBtn.register(SButton.BIGPLAY,onPlayerEvent);
			addChild(bigPlayBtn);

			//添加中央暂停按钮
			bigPauseBtn = new BigPauseButton  ;
			bigPauseBtn.register(SButton.BIGPAUSE,onPlayerEvent);
			addChild(bigPauseBtn);

			//添加控制栏容器
			controlContainer = new Sprite;
			addChild(controlContainer);

			//添加通栏背景
			bar = new Bar;
			controlContainer.addChild(bar);

			//添加音量条;
			vBar = new VolumeButton(this);
			vBar.register(VolumeButton.VOLUME,onPlayerEvent);
			controlContainer.addChild(vBar);

			//分隔符
			bSeparator1 = new ButtonSeparator;
			controlContainer.addChild(bSeparator1);
			
			//添加字幕按钮;
			stBtn = new SubTitleButton(this, FILENAME);
			stBtn.register(SubTitleButton.SUBSEARCH,onPlayerEvent);
			stBtn.setSubTitleBar(subTitleBar);
			controlContainer.addChild(stBtn);
			
			//分隔符
			bSeparator2 = new ButtonSeparator;
			controlContainer.addChild(bSeparator2);

			//添加全屏恢复按钮;
			miniBtn = new MiniscreenButton  ;
			miniBtn.register(SButton.MINISCREEN,onPlayerEvent);
			miniBtn.visible = false;
			controlContainer.addChild(miniBtn);

			//添加全屏按钮;
			fullBtn = new FullscreenButton  ;
			fullBtn.register(SButton.FULLSCREEN,onPlayerEvent);
			controlContainer.addChild(fullBtn);

			//添加时间显示;
			tBar = new TimeBar  ;
			controlContainer.addChild(tBar);
			
			//添加暂停按钮;
			pauseBtn = new PauseButton;
			pauseBtn.register(SButton.PAUSE,onPlayerEvent);
			pauseBtn.visible = false;
			controlContainer.addChild(pauseBtn);
			
			//添加播放按钮;
			playBtn = new PlayButton  ;
			playBtn.register(SButton.PLAY,onPlayerEvent);
			controlContainer.addChild(playBtn);

			//添加进度条;
			pBar = new ProgressBar();
			pBar.register(ProgressBar.PROGRESS,onPlayerEvent);
			pBar.setTip(pTip);
			controlContainer.addChild(pBar);
//			
//			//添加加载字幕 tips
			loadingTips = new LoadingTips();
			loadingTips.visible = false;
			addChild(loadingTips);
		}
		
		public function resizeScreen(e:Event=null):void {
			var oy:int = 12;
			e && onPlayerEvent(stage.displayState);
			cw = stage.stageWidth;
			ch = stage.stageHeight;
			
			//pBar.x = 0;
			pBar.y = 0;
			pBar.width = cw;

			loadingTips.y = isFullScreen() ? 100 : 35;
			loadingTips.x = cw/2;
			
			bar.x = playBtn.width+tBar.width;
			bar.y = oy;
			bar.width = cw-playBtn.width-tBar.width-miniBtn.width - vBar.width - bSeparator2.width - bSeparator1.width - stBtn.width;

			playBtn.x = 0;
			playBtn.y = oy;

			pauseBtn.x = playBtn.x;
			pauseBtn.y = oy;

			tBar.x = playBtn.width;
			tBar.y = oy;

			stBtn.x = cw - miniBtn.width - vBar.width - bSeparator2.width - bSeparator1.width - stBtn.width;
			stBtn.y = oy;
			
			bSeparator1.x = cw - miniBtn.width - bSeparator2.width  - vBar.width - bSeparator1.width;
			bSeparator1.y = oy;
			
			vBar.x = cw - miniBtn.width - vBar.width - bSeparator2.width;
			vBar.y = oy;
			
			bSeparator2.x = cw - miniBtn.width - bSeparator2.width;
			bSeparator2.y = oy;
			
			miniBtn.x = cw - miniBtn.width;
			miniBtn.y = oy;

			fullBtn.x = miniBtn.x;
			fullBtn.y = oy;

			loading.x = cw / 2;
			loading.y = ch / 2;

			bigPlayBtn.x = cw / 2;
			bigPlayBtn.y = ch / 2;

			bigPauseBtn.x = 0;
			bigPauseBtn.y = 0;
			bigPauseBtn.width = cw;
			bigPauseBtn.height = ch;

			controlContainer.x = 0;
			controlContainer.y = ch - controlContainer.height;

			resizeVideoContainer();
			
			videoLightBar.x = 0;
			videoLightBar.y = 0;
			videoLightBar.width = cw;
			videoLightBar.height = ch;
			
			subTitleBar.x=cw/2;
			//subTitleBar.height = stage.stageHeight / 8;
			subTitleBar.y=controlContainer.y-subTitleBar.height;

			pTip.y = controlContainer.y;
			stBtn.resizeSubPanel();
		}
		private function initEvent():void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onFocusEvent);
			stage.addEventListener(MouseEvent.CLICK,onFocusEvent);
			stage.addEventListener(MouseEvent.ROLL_OUT,onFocusEvent);
			stage.addEventListener(Event.RESIZE,resizeScreen);
		}
		private function onFocusEvent(e:MouseEvent=null):void {
			showControlBar();
			clearTimeout(setTimeoutId);
			setTimeoutId = setTimeout(hideControlBar,2500);
		}
		public function showControlBar():void {
			PlayerUI.controlContainerVisible = true;
			Tweener.removeTweens(controlContainer,['y']);
			Tweener.removeTweens(subTitleBar,['y']);
			Tweener.addTween(controlContainer,{y:stage.stageHeight - controlContainer.height,time:2, onUpdate: function():void {
				if (PlayerUI.SubTitlePanelVisible) {
					stBtn.resizeSubPanel();
				}
				if (PlayerUI.VolumePanelVisible) {
					vBar.resizeVomPanel();
				}
			}});
			Tweener.addTween(subTitleBar,{y:stage.stageHeight-subTitleBar.height- controlContainer.height,time:2});
			Mouse.show();
		}
		public function hideControlBar():void {
			//当弹出面板出现时，不会自动隐藏整体控制栏
			if(PlayerUI.VolumePanelVisible || PlayerUI.SubTitlePanelVisible){
				onFocusEvent();
				return;
			}
			clearTimeout(setTimeoutId);
			PlayerUI.controlContainerVisible = false;
			Tweener.addTween(controlContainer,{y:stage.stageHeight-12,time:1.2});
			Tweener.addTween(subTitleBar,{y:stage.stageHeight-subTitleBar.height,time:1.2});
			vBar.hidePanel();
			stBtn.hidePanel();
			Mouse.hide();
		}
		private function initRightMouseMenu():void{
			var cm:ContextMenu = new ContextMenu();
			var item:ContextMenuItem;
			
			
			
			
			cm.hideBuiltInItems();
			cm.customItems.push(new ContextMenuItem(PlayerUI.APPNAME));
			
			/*
			item = new ContextMenuItem("亮度增强-低");
			item.separatorBefore=true;
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onMenuSelectEvent);
			cm.customItems.push(item);
			
			item = new ContextMenuItem("亮度增强-中");
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onMenuSelectEvent);
			cm.customItems.push(item);
			
			item = new ContextMenuItem("亮度增强-高");
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onMenuSelectEvent);
			cm.customItems.push(item);
			
			item = new ContextMenuItem("取消亮度增强");
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onMenuSelectEvent);
			cm.customItems.push(item);
			*/
			
			item = new ContextMenuItem(PlayerUI.VERSION);
			item.separatorBefore=true;
			cm.customItems.push(item);
			
			this.contextMenu = cm;
		}
		private function onMenuSelectEvent(e:ContextMenuEvent):void{
			switch(e.target.caption){
				case "取消亮度增强":
					videoLightBar.alpha=0;
					break;
				case "亮度增强-低":
					videoLightBar.alpha=0.1;
					break;
				case "亮度增强-中":
					videoLightBar.alpha=0.2;
					break;
				case "亮度增强-高":
					videoLightBar.alpha=0.35;
					break;
			}
		}
		public function onPlayerEvent(code:String,param:*=null):void{
			trace(code+"="+param);
		}
		
		private static var setTimeInterval:int = -1;
		public static function showLoadingTips(txt:String, hideTime:int) {
			PlayerUI.loadingTips.txtTip.text = txt;
			PlayerUI.loadingTips.visible = true;
			clearTimeout(setTimeInterval);
			if (hideTime >= 0) {
				setTimeInterval = setTimeout(function() {
					PlayerUI.loadingTips.visible = false;
				}, hideTime);
			}
		}
		
		//本地存储唯一关键字段
		public static var APPNAME:String = "网盘视频播放器";
		public static var VERSION:String = "百度云前端团队出品 v.1.2014092301";
		public static var SRTFONTSIZE:int=12;
		public static var MOVIEID:String;
		public static var FILENAME:String = "";
		public static var STROAGE:SharedObject = null;
		public static var controlContainerVisible:Boolean = true;
		public static var VolumePanelVisible:Boolean = false;
		public static var SubTitlePanelVisible:Boolean = false;
		public static var ShowSubSearchPanel:Boolean = false;
		public static function getStorage():SharedObject{
			if(!PlayerUI.STROAGE){
				PlayerUI.STROAGE = SharedObject.getLocal("disk-player-so");
			}
			return PlayerUI.STROAGE;
		}
		
		public function isFullScreen():Boolean {
			return stage.displayState == StageDisplayState.NORMAL ? false : true;
		}
		
		private function testInitApp():void{
			initPlayer(600,400,new Sprite);pBar.setDurationTime(100);
			PlayerUI.MOVIEID="movie123456";
			var i:int=0,obj:Object,datas1:Array,datas2:Array,datas3:Array;
			for(i=0,datas1=[];i<12;i++){
				obj={"url":"http://www.baidu.com"+i,"name":"来自网盘的电影字幕 "+i,"type":"来自网盘"+i,"id":i};
				datas1.push(obj);
			}
			for(i=12,datas2=[];i<24;i++){
				obj={"url":"http://www.baidu.com"+i,"name":"来自网盘的电影字幕 "+i,"type":"来自网盘"+i,"id":i};
				datas2.push(obj);
			}
			for(i=24,datas3=[];i<36;i++){
				obj={"url":"http://www.baidu.com"+i,"name":"来自网盘的电影字幕 "+i,"type":"来自网盘"+i,"id":i};
				datas3.push(obj);
			}
			stBtn.addSrtData(datas1);
			stBtn.addSrtData(datas2);
			stBtn.addSrtData(datas3);
			
			var item:Object={}
			item['id']="123";
			item['name']="最新字幕字幕";
			item['url']="http://www.baidu.com";
			item['type']="来自测试";
			//stBtn.addSrtData([item],true);
		}

	}

}