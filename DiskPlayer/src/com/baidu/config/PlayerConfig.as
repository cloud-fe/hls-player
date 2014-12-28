package com.baidu.config
{
	public class PlayerConfig
	{
		public function PlayerConfig()
		{
		}
		
		/**
		 * 视频地址
		 */
		private var _file:String = "";
		
		/**
		 * 字幕地址
		 */
		private var _srturl:String = "";
		
		/**
		 * 搜索字幕函数
		 */
		private var _searchSrtFunc:String = "";
		
		private var _onPlayOverFunc:String = "";
		
		private var _onPlayerErrorFunc:String = "";
		
		
		private var _md5:String = "";
		
		public function GetMd5():String {
			return _md5;
		}
		public function SetMd5(md5:String):void{
			_md5 = md5;
		}
		
		private var _fileName:String = "";
		
		public function GetFileName():String {
			return _fileName;
		}
		public function SetFileName(fileName:String):void {
			_fileName = fileName;
		}
		
		private var _onReadyFunc:String = "";
		
		private var _onLoadFunc:String = "";
		
		public function GetOnReadyFunc():String {
			return _onReadyFunc;
		}
		public function SetOnReadyFunc(onReadyFunc:String):void {
			_onReadyFunc = onReadyFunc;
		}
		
		public function GetOnLoadFunc():String {
			return _onLoadFunc;
		}
		public function SetOnLoadFunc(onLoadFunc:String):void {
			_onLoadFunc = onLoadFunc;
		}
		
		
		private var _onTimeFunc:String = "";
		
		public function GetOnTimeFunc():String {
			return _onTimeFunc;
		}
		public function SetOnTimeFunc(onTimeFunc:String):void {
			_onTimeFunc = onTimeFunc;
		}
		
		private var _fsid:String = "";
		
		public function GetFile():String {
			return _file;
		}
		public function SetFile(file:String):void {
			_file = file;
		}
		
		public function GetFsid():String {
			return _fsid;
		}
		public function SetFsid(fsid:String):void {
			_fsid = fsid;
		}
		
		public function GetSrturl():String {
			return _srturl;
		}
		public function SetSrturl(srtUrl:String):void {
			_srturl = srtUrl;
		}
		
		public function GetSearchSrtFunc():String {
			return _searchSrtFunc;
		}
		public function SetSearchSrtFunc(searchSrtFunc:String):void {
			_searchSrtFunc = searchSrtFunc;
		}
		
		public function GetOnPlayOverFunc():String {
			return _onPlayOverFunc;
		}
		public function SetOnPlayOverFunc(onPlayOverFunc:String):void {
			_onPlayOverFunc = onPlayOverFunc;
		}
		
		public function GetOnPlayerErrorFunc():String {
			return _onPlayerErrorFunc;
		}
		public function SetOnPlayerErrorFunc(onPlayerErrorFunc:String):void {
			_onPlayerErrorFunc = onPlayerErrorFunc;
		}
		
		
		
		private var _showSearch:String = "";
		
		public function GetShowSearch():String {
			return _showSearch;
		}
		public function SetShowSearch(showSearch:String):void {
			_showSearch = showSearch;
		}
		
		
		public static function initConfig(info:Object):PlayerConfig {
			var config:PlayerConfig = new PlayerConfig();
			//file infos
			config.SetFile(info.file);
			config.SetSrturl(info.srturl);
			config.SetFsid(info.fsid);
			
			//settings
			config.SetShowSearch(info.showSearch);
			
			//callbacks
			config.SetOnPlayOverFunc(info.onOver);
			config.SetOnPlayerErrorFunc(info.onError);
			config.SetOnReadyFunc(info.onReady);
			config.SetOnTimeFunc(info.onTime);
			config.SetOnLoadFunc(info.onLoad);
			return config;
		}
	}
}