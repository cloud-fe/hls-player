package com.baidu.utils {
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.net.*;
	import flash.utils.setTimeout;
	
	public class Srt extends MovieClip{
		
		public static const SRT_LOADING:String = "srtloading";
		public static const SRT_LOADED:String = "srtloaded";
		public static const SRT_FAIL:String = "srtfail";
		
		private var _title:String = "";
		private var _arrList:Array = new Array();
		private var _lastTime:uint = 0;
		private var _lastIndex:uint = 0;
		public function Srt(url:String, srtName:String=null) {
			if(!url)return;
			_title = srtName;
			var urlRequest:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, OnSrtLoadedComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, OnSrtLoadedError);
			loader.load(urlRequest);
		}
		private var regStr:String = "\\d+\\r\\n(\\d{2}:\\d{2}:\\d{2},\\d{3}) --> (\\d{2}:\\d{2}:\\d{2},\\d{3})\\r\\n(.*?)\\r\\n\\r\\n";
		private var reg:RegExp;
		private var srt:String;
		private var rst:Object;
		private var srtItem:Object;
		private function OnSrtLoadedComplete(e:Event):void {
		
			var loader:URLLoader = URLLoader(e.target);
			srt = loader.data;
			reg = new RegExp(regStr,"gism");
			_arrList=[];
			if (srt != "") {
				setTimeout(addSrtItem,1);
			} else {
				//load fail
				triggerLoadFail();
			}
		}
		
		private function triggerLoadFail():void {
			dispatchEvent(new Event(Srt.SRT_FAIL));
		}
		private function triggerLoadSuccess():void {
			dispatchEvent(new Event(Srt.SRT_LOADED));
		}
		private function OnSrtLoadedError(e:IOErrorEvent):void{
			trace("资源不存在");
			//load fail
			triggerLoadFail();
		}
		private var loadingCount:int = 0;
		private function addSrtItem():void{
			rst = reg.exec(srt);
			if (rst != null) {
				srtItem = {
					"bt":ParseTime(rst[1]),
					"et":ParseTime(rst[2]),
					"txt":rst[3].replace(/=([#,0-9,A-F,a-f]*)(>|\s?)/gism,"='$1'$2")
				};
				_arrList.push(srtItem);
				loadingCount++;
				if (loadingCount >= 50) {
					loadingCount = 0;
					setTimeout(addSrtItem, 1);
				} else {
					addSrtItem();
				}
			} else {
				loadingCount = 0;
				//load success
				triggerLoadSuccess();
			}
		}
		private function ParseTime(str:String):uint {
			var nRet:uint = 0;
			if (str != "") {
				var arr1:Array = str.split(",");
				var nMs:uint = parseInt(arr1[1]);
				var arr2:Array = arr1[0].split(":");
				var nH:uint = parseInt(arr2[0]);
				var nM:uint = parseInt(arr2[1]);
				var nS:uint = parseInt(arr2[2]);
				nRet +=  nS * 1000;
				nRet +=  nM * 60 * 1000;
				nRet +=  nH * 60 * 60 * 1000;
				nRet +=  nMs;
			}
			return nRet;
		}
		public function GetText(time:uint):String {
			var strRet:String = "";
			if (time < _lastTime) {
				_lastIndex = 0;
			}
			for (var i:uint = _lastIndex; i <  _arrList.length; i++) {
				var obj:Object = _arrList[i];
				if (obj.bt <= time && time <= obj.et) {
					strRet = obj.txt;
					_lastTime = obj.bt;
					_lastIndex = i;
					break;
				}
			}
			return strRet;
		}
		public function GetTitle():String {
			return _title;
		}
	}
}