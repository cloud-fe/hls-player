package com.baidu.ui.controls.subtitle {
	import com.baidu.ui.PlayerUI;
	import com.baidu.utils.Srt;
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.net.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;


	public class SubTitleBar extends MovieClip{

		private var subtitle:Object;
		private var textFormat:TextFormat;
		private var srt:Srt = null;
		private var adJustTime:uint = 0;
		public function SubTitleBar() {
			mcSrtTxt.text = "";

			var storage:SharedObject = com.baidu.ui.PlayerUI.getStorage();
			var fontsize:int = int(storage.data[com.baidu.ui.PlayerUI.SRTFONTSIZE]);
			if (! fontsize) {
				fontsize = 18;
			}
			textFormat = new TextFormat();
			textFormat.font = "黑体";
			setFontSize(fontsize);
		}
		public function setAdjustTime(time:uint):void {
			adJustTime = time;
		}
		public function setPlayTime(time:uint) {
			if (srt && mcSrtTxt.visible) {
				var text:String = srt.GetText(1000*(time+adJustTime));
				mcSrtTxt.htmlText = text;
				mcSrtTxt.setTextFormat(textFormat);
				//FIXME: /r/n出现空行，导致中英文字幕不出现的问题
				mcSrtTxt.htmlText = mcSrtTxt.htmlText.replace('<FONT FACE="黑体" SIZE="18" COLOR="#FFFFFF" LETTERSPACING="0" KERNING="0"></FONT></P><P ALIGN="CENTER">', '');
				
				trace(mcSrtTxt.htmlText);
			}
		}
		public function setFontSize(fontsize:int):void {
			trace("字幕字体被更改"+fontsize);
			textFormat.size = fontsize;
			mcSrtTxt.setTextFormat(textFormat);
			mcSrtTxt.height = 42+(fontsize-18)*2;
			mcSrtTxt.y=64-mcSrtTxt.height;
		}
		public function closeSrt():void{
			mcSrtTxt.visible = false;
		}
		
		public function showSrt():void {
			mcSrtTxt.visible = true;
		}
		
		private var setTimeInterval:int = -1;
		private function changeSrtStatus(status:String):void {
			
			//ExternalInterface.call('console.log', 'loaded status : '+ status);
			
			var txt:String = '';
			switch(status){
				case Srt.SRT_LOADED:
					txt = '字幕加载成功';
					break;
				case Srt.SRT_FAIL:
					txt = '字幕加载失败';
					break;
				case Srt.SRT_LOADING:
					txt = '字幕加载中，请稍候...';
					break;
			}
			PlayerUI.showLoadingTips(txt, status != Srt.SRT_LOADING ? 3000 : -1);
		}
		
		public function loadSrt(url:String=null) {
			trace("加载字幕的地址"+url);
			if (url) {
				showSrt();
				changeSrtStatus(Srt.SRT_LOADING);			
			}
			srt = new Srt(url,url);
			srt.addEventListener(Srt.SRT_FAIL, function():void {
				changeSrtStatus(Srt.SRT_FAIL);
			});
			srt.addEventListener(Srt.SRT_LOADED, function():void {
				changeSrtStatus(Srt.SRT_LOADED);
			});
		}

	}

}