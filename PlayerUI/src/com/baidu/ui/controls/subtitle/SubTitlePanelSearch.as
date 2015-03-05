package com.baidu.ui.controls.subtitle 
{

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	import flash.utils.setTimeout;

	public class SubTitlePanelSearch extends MovieClip
	{
		private var datalist:Array = [];
		private var itemList:Array = [];
		private var groubBtnList:Array = [];

		private var curGroupId:int = 0;
		private var groupNum:int = 0;


		private var groupid:int;
		public var itemid:String;
		public var itemurl:String;
		private var itemname:String;

		private var item:SubTitlePanelListItem;

		public var srtItem:Object;
		public function SubTitlePanelSearch()
		{
			
			btnSearch.addEventListener(MouseEvent.CLICK,onMouseClickEvent);
			btnPrePage.addEventListener(MouseEvent.CLICK,onMouseClickEvent);
			btnNexPage.addEventListener(MouseEvent.CLICK,onMouseClickEvent);
			
			
			txtSearch.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownEvent);
			txtSearch.addEventListener(MouseEvent.MOUSE_UP, onMouseUpEvent);
			
			txtSearch.addEventListener(FocusEvent.FOCUS_IN, onFocusInEvent);
			txtSearch.addEventListener(FocusEvent.FOCUS_OUT, onFocusOutEvent);
			txtSearch.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEvent);
			
			btnPrePage.visible = false;
			btnNexPage.visible = false;
			txtEmptyTip.visible = false;
			
			lblSrtName.visible = false;
			lblSrtLan.visible = false;
			searchLine.visible = false;
		}
		
		
		private function onMouseDownEvent(e:FocusEvent):void {
//			ExternalInterface.call("console.log","oninput mousedown");
			dispatchEvent(new Event(SubTitlePanel.SEARCH_INPUT_MOUSE_DOWN));
		}
		private function onMouseUpEvent(e:FocusEvent):void {
//			ExternalInterface.call("console.log","oninput mouseup");
			dispatchEvent(new Event(SubTitlePanel.SEARCH_INPUT_MOUSE_UP));
		}
		
		private var flagSetDefaultWd:Boolean = false;
		public function setDefaultWD(wd:String):void {
			var text:String = txtSearch.text.replace( /^\s*|\s*$/g,"");
			if (text == placeHolderStr && flagSetDefaultWd != true)
			{
				if (wd) {
					flagSetDefaultWd = true;
					txtSearch.text = wd;
					//if (state) {
						//stage.focus = txtSearch;
					//}
				}
			}
		}
		public function addSrtData(datas:Array,autoSelected:Boolean=false)
		{
			datalist = datas;
			renderList();
		}
		private function clearList():void
		{
			for (var i:int=0; i<itemList.length; i++)
			{
				itemList[i].removeEventListener(SubTitlePanel.CHOOSE,onMouseClickEvent);
				this.removeChild(itemList[i]);
			}
			itemList = [];
		}
		private function clearGroupBtnList():void
		{
			for (var i:int=0; i<groubBtnList.length; i++)
			{
				groubBtnList[i].removeEventListener(SubTitlePanel.PAGEBTN,onBtnClickEvent);
				this.removeChild(groubBtnList[i]);
			}
			groubBtnList = [];
		}
		private function renderList():void
		{
			clearList();
			
			if (datalist.length <= 0) {
				txtEmptyTip.visible = true;
				lblSrtName.visible = false;
				lblSrtLan.visible = false;
				searchLine.visible = false;
			} else {
				txtEmptyTip.visible = false;
				lblSrtName.visible = true;
				lblSrtLan.visible = true;
				searchLine.visible = true;
			}
			
			datalist.forEach(renderItem);
			groupNum = Math.ceil(datalist.length / 5);
			renderGroupBtn(0,groupNum);
		}
		private function renderItem(data:Object,index:int,list:Array)
		{
			var itemX:int = 12,itemY:int = 105 + 30 * ((index + 5) % 5);
			var groupId:int=Math.floor(index/5);

			item = new SubTitlePanelListItem(
				data['id'],
				groupId,
				data['url'],
				data['name'],
				data['language'],
				itemX,
				itemY,
				(itemid==data['id'])
			);
			
			trace('init event');
			item.addEventListener(SubTitlePanel.CHOOSE,onItemClickEvent);
			item.showGroup(0);
			itemList.push(item);
			this.addChild(item);
		}
		private function selectItem(item:SubTitlePanelListItem):void
		{

			this.itemurl = item.url;
			this.itemid = item.id;

			
			this.srtItem = this.getItemById(item.id); 

			itemList.forEach(updateItemState);
			//请求加载字幕
			
			dispatchEvent(new Event(SubTitlePanel.CHOOSE_SEARCH));
		}
		
		private function getItemById(id:String):Object {
		
			for (var i:int = 0, len:int = this.datalist.length; i < len; i++) {
				if (this.datalist[i].id == id) {
					return this.datalist[i];
				}
			}
			return null;
		}
		
		private function updateItemState(item:Object,index:int,list:Array):void
		{
			item.selectItem(this.itemid);
		}
		private function renderGroupBtn(curIndex:int,num:int):void
		{
			var btn:SubTitlePanelListBtn;
			var i:int,index:int;
			clearGroupBtnList();
			if (groupNum == 1)
			{
				return;
			}
			else if (groupNum<5)
			{
				btnPrePage.visible = false;
				btnNexPage.visible = false;
				for (i=0; i<groupNum; i++)
				{
					btn = new SubTitlePanelListBtn(i);
					btn.addEventListener(SubTitlePanel.PAGEBTN,onBtnClickEvent);
					btn.x = (500 - groupNum * 30) + 30 * i;
					btn.y = 276;
					groubBtnList.push(btn);
					addChild(btn);
				}
				btnPrePage.visible = false;
				btnNexPage.visible = false;
			}
			else
			{
				if (curIndex>=2 && curIndex<=groupNum-3)
				{
					index = curIndex - 2;
				}
				else if (curIndex<2)
				{
					index = 0;
				}
				else if (curIndex+2>=groupNum)
				{
					index = groupNum - 5;
				}
				for (i=index; i<index+5; i++)
				{
					btn = new SubTitlePanelListBtn(i);
					if (i==(index+5-1) && index+5!=groupNum)
					{
						btn.setText("...");
					}
					btn.addEventListener(SubTitlePanel.PAGEBTN,onBtnClickEvent);
					btn.x=(500-2*56-5*30)+46+30*(i-index);
					btn.y = 276;
					groubBtnList.push(btn);
					addChild(btn);
				}
				btnPrePage.y = 276;
				btnNexPage.y = 276;
				btnPrePage.x=(500-2*56-5*30);
				btnNexPage.x=(500-2*56-5*30)+56+30*5+6;
				btnPrePage.visible = true;
				btnNexPage.visible = true;
			}
		}
		private function selectGroup(gid:int):void
		{
			this.groupid = gid;
			this.curGroupId = gid;
			itemList.forEach(updateGroupState);
			renderGroupBtn(this.groupid,groupNum);
			groubBtnList.forEach(updateGroupBtnState);
		}
		private function updateGroupState(item:Object,index:int,list:Array):void
		{
			item.showGroup(this.groupid);
		}
		private function updateGroupBtnState(btn:Object,index:int,list:Array):void
		{
			btn.selectBtn(this.groupid);
		}

		private function onFocusInEvent(e:FocusEvent):void {
			switch (e.target)
			{
				case txtSearch :
					changeTxtSearchPlaceholder(true);
					break;
			}
			dispatchEvent(new Event(SubTitlePanel.SEARCH_FOCUS));
			
		}
		private function onFocusOutEvent(e:FocusEvent):void {
			switch (e.target)
			{
				case txtSearch :
					changeTxtSearchPlaceholder(false);
					break;
			}
		}
		
		private function onKeyEvent(e:KeyboardEvent): void {
			switch (e.target) {
				case txtSearch:
					if (e.keyCode == 13) {
						searchSrt();
					} else if (e.keyCode == 32) {
						e.stopPropagation();
					}
					break;
			}
		
		}
		
		private function onMouseClickEvent(e:MouseEvent):void
		{
			switch (e.target)
			{
				case btnSearch :
					searchSrt();
					break;
				case btnPrePage :
					if (curGroupId-1<0)
					{
						curGroupId = 0;
						//btnPrePage.visible=false;
					}
					else
					{
						curGroupId--;
					}
					selectGroup(curGroupId);
					break;
				case btnNexPage :
					if (curGroupId+1>=groupNum)
					{
						curGroupId = groupNum - 1;
						//btnNexPage.visible=false;
					}
					else
					{
						curGroupId++;
					}
					selectGroup(curGroupId);
					break;
			}
			e.stopImmediatePropagation();
		}

		private var placeHolderStr:String = '输入电影名检索字幕';

		private function changeTxtSearchPlaceholder(flag:Boolean):void
		{
			var text:String = txtSearch.text.replace( /^\s*|\s*$/g,"");

			if (flag)
			{
				if (text == placeHolderStr)
				{
					txtSearch.text = '';
				}
				
			}
			else
			{
				if (text == placeHolderStr || text == '')
				{
					txtSearch.text = placeHolderStr;
				}
			}
		}

		private function searchSrt():void
		{
			var text:String = txtSearch.text;
			text = text.replace( /^\s*|\s*$/g,"");
			if (text == '' || text == placeHolderStr)
			{
				return;
			}
			
//			var data = {"errno":0,"request_id":3795558559,"total_num":3,"records":[{"ajust":0,"from":"wd","name":"Beneath.2007.DVDRip.XviD-ESPiSE.gb.srt","title":"","lang_chs":"0","lang_cht":"0","lang_chn":"0","lang_eng":"0","file_path":"http:\/\/nj.bs.baidu.com\/subtitle-5\/ca6e409fe8a145677fb4f7ccdffc8c0a?sign=MBOT:RaSExz7qu7yWHUNFcQj:bB9b46NVv4QmXfJhY6b2H1%2BdEbo%3D&time=1412913997","id":"a0UeTiHHH9s=","callback":"http:\/\/nsclick.baidu.com\/v.gif?pid=375&type=feedback&st_id=a0UeTiHHH9s%3D&wd=%E4%B8%8D%E8%83%BD%E8%AF%B4%E7%9A%84%E7%A7%98%E5%AF%86&timestamp=1412910397&from=wd&uid=h3MAzDHb%2F44%3D","display_name":"\u4e0d\u80fd\u8bf4\u7684\u79d8\u5bc6\/\u811a\u4e0b(Beneath)"},{"ajust":0,"from":"wd","name":"Beneath.2007.DVDRip.XviD-ESPiSE.big5.srt","title":"","lang_chs":"0","lang_cht":"0","lang_chn":"0","lang_eng":"0","file_path":"http:\/\/nj.bs.baidu.com\/subtitle-13\/c4e8a7eceae54887824490a46cefd5a1?sign=MBOT:RaSExz7qu7yWHUNFcQj:7PQsC2fqA%2FdbANo014Iatnos0CI%3D&time=1412913997","id":"PE90ZK\/7EwI=","callback":"http:\/\/nsclick.baidu.com\/v.gif?pid=375&type=feedback&st_id=PE90ZK%2F7EwI%3D&wd=%E4%B8%8D%E8%83%BD%E8%AF%B4%E7%9A%84%E7%A7%98%E5%AF%86&timestamp=1412910397&from=wd&uid=h3MAzDHb%2F44%3D","display_name":"\u4e0d\u80fd\u8bf4\u7684\u79d8\u5bc6\/\u811a\u4e0b(Beneath)"},{"ajust":0,"from":"wd","name":"Beneath.2007.DVDRip.XviD-ESPiSE.English.srt","title":"","lang_chs":"0","lang_cht":"0","lang_chn":"0","lang_eng":"1","file_path":"http:\/\/nj.bs.baidu.com\/subtitle-11\/c79c3d133aff2ff41ce70f89e06b9730?sign=MBOT:RaSExz7qu7yWHUNFcQj:BTSyt51AjqJmdjLaV4nIxxRPZvI%3D&time=1412913997","id":"MFjhpgiAFK4=","callback":"http:\/\/nsclick.baidu.com\/v.gif?pid=375&type=feedback&st_id=MFjhpgiAFK4%3D&wd=%E4%B8%8D%E8%83%BD%E8%AF%B4%E7%9A%84%E7%A7%98%E5%AF%86&timestamp=1412910397&from=wd&uid=h3MAzDHb%2F44%3D","display_name":"\u4e0d\u80fd\u8bf4\u7684\u79d8\u5bc6\/\u811a\u4e0b(Beneath)_\u82f1"}]};
//			if (data.errno == 0 && data.records) {
//				addSrtData(operateSrtList(data.records), false);
//			};
//		return;
			getSrtListByKW(text, function(e) {
				var data:Object = JSON.parse(e.target.data.toString());
				if (data.errno == 0 && data.records) {
					addSrtData(operateSrtList(data.records), false);
				};
			});
		}
		private function operateSrtList(srtlist:Array):Array
		{
			var srtResult = [],
				item:Object,
				flagChn:Boolean,
				language:String;
			srtlist.forEach(function(data:Object,index:int,list:Array) {
				
				flagChn = false;
				language = "未知";
				
				if (data.lang_chs == 1 || data.lang_cht == 1 || data.lang_chn == 1) {
					flagChn = true;
				}
				if (flagChn && data.lang_eng == 1) {
					language = '中英';
				} else if (data.lang_eng == 1) {
					language = '英';
				} else if (flagChn) {
					language = '中';
				}
				
				item = {
					id: data.id,
					url: data.file_path,
					name: data.display_name,
					type: data.from == 'pcs' ? '网盘字幕' : '在线字幕',
					language: language
				};
				srtResult.push(item);
			});
			return srtResult;
		}
		private function getSrtListByKW(keyWord:String, callback:Function):void
		{
			var urlRequest:URLRequest = new URLRequest();
			urlRequest.method = 'get';
			urlRequest.url = '/api/resource/subtitle?format=2&wd=' + encodeURIComponent(keyWord) + '&start=0&limit=100';
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, function(e:Event):void {
			if (callback != null)
			callback(e);
			});
			urlLoader.load(urlRequest);
		}

		private function onItemClickEvent(e:Event):void
		{
			trace('onItemClickEvent event');
			var item:SubTitlePanelListItem = e.target as SubTitlePanelListItem;
			selectItem(item);
			e.stopImmediatePropagation();
		}
		private function onBtnClickEvent(e:Event):void
		{
			var btn:SubTitlePanelListBtn = e.target as SubTitlePanelListBtn;
			selectGroup(btn.index);
			e.stopImmediatePropagation();
		}
	}

}