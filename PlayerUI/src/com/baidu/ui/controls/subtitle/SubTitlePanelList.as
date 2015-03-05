package com.baidu.ui.controls.subtitle {

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.SharedObject;
	import com.baidu.ui.PlayerUI;

	public class SubTitlePanelList extends MovieClip {
		private var storage:SharedObject;
		public var datalist:Array = [];
		private var itemList:Array = [];
		private var groubBtnList:Array = [];

		private var curGroupId:int = 0;
		private var groupNum:int = 0;

		private var groupid:int;
		public var itemid:String;
		public var itemurl:String;
		private var itemname:String;

		private var item:SubTitlePanelListItem;
		public function SubTitlePanelList() {
			
			//btnConfig.addEventListener(MouseEvent.CLICK,onMouseClickEvent);
			btnCancel.addEventListener(MouseEvent.CLICK,onMouseClickEvent);
			btnPrePage.addEventListener(MouseEvent.CLICK,onMouseClickEvent);
			btnNexPage.addEventListener(MouseEvent.CLICK,onMouseClickEvent);
			
			
			btnPrePage.visible = false;
			btnNexPage.visible = false;
		}
		public function addSrtData(datas:Array,autoSelected:Boolean=false):String {
			storage = com.baidu.ui.PlayerUI.getStorage();
			//外部手工添加的字幕自动播放
			if (autoSelected && datas.length==1) {
				storage.data[com.baidu.ui.PlayerUI.MOVIEID] = datas[0]['id'];
				storage.flush();
			}
			itemid = storage.data[com.baidu.ui.PlayerUI.MOVIEID];
			trace('cache itemid:', itemid);
			datalist = datas.concat(datalist);
			//去重
			for (var i:int=0,r:Object={},arr:Array=[],item:Object; i<datalist.length; i++) {
				item = datalist[i];
				if ( r[item['id']]) {
					continue;
				} else {
					r[item['id']] = true;
					arr.push( item );
				}
			}
			datalist = arr;
			renderList();
			return itemid;
		}
		private function clearList():void {
			for (var i:int=0; i<itemList.length; i++) {
				itemList[i].removeEventListener(SubTitlePanel.CHOOSE,onMouseClickEvent);
				this.removeChild(itemList[i]);
			}
			itemList = [];
		}
		private function clearGroupBtnList():void {
			for (var i:int=0; i<groubBtnList.length; i++) {
				groubBtnList[i].removeEventListener(SubTitlePanel.CHOOSE,onMouseClickEvent);
				this.removeChild(groubBtnList[i]);
			}
			groubBtnList = [];

			//btnPrePage.visible=true;
			//btnNexPage.visible=true;
		}
		private function renderList():void {
			this.curGroupId = 0;
			clearList();
			datalist.forEach(renderItem);
			groupNum = Math.ceil(datalist.length / 8);
			renderGroupBtn(0,groupNum);
			updateCancelSrtBtn();
		}
		private function renderItem(data:Object,index:int,list:Array) {
			var itemX:int = 15,itemY:int = 17 + 30 * ((index + 8) % 8);
			var groupId:int=Math.floor(index/8);

			item = new SubTitlePanelListItem(
					data['id'],
					groupId,
					data['url'],
					data['name'],
					data['type'],
					itemX,
					itemY,
					(itemid==data['id'])
			);
			item.addEventListener(SubTitlePanel.CHOOSE,onItemClickEvent);
			item.showGroup(0);
			itemList.push(item);
			this.addChild(item);
			//如果列表中有该字幕，并且是上次记录的字幕，就会自动加载
			
			trace('cache itemid:', itemid == data['id']);
			
			if (itemid == data['id']) {
				
				this.itemurl = data.url;
				this.itemid = data.id;
				
				dispatchEvent(new Event(SubTitlePanel.CHOOSE));
			}
		}
		private function selectItem(item:SubTitlePanelListItem):void {
			
			this.itemurl = item.url;
			this.itemid = item.id;
			
			itemList.forEach(updateItemState);
			//存入缓存
			storage.data[com.baidu.ui.PlayerUI.MOVIEID] = this.itemid;
			storage.flush();

			//请求加载字幕
			dispatchEvent(new Event(SubTitlePanel.CHOOSE));
		}
		private function updateItemState(item:Object,index:int,list:Array):void {
			item.selectItem(this.itemid);
		}
		
		private function updateCancelSrtBtn():void {
			var currentPageCount:Number = 0;
			itemList.forEach(function(item:Object,index:int,list:Array):void {
				if (item.groudId == curGroupId) {
					currentPageCount++;
				}
			});
			btnCancel.y = 23 + 30 * currentPageCount;
		}
		private function renderGroupBtn(curIndex:int,num:int):void {
			
			var btn:SubTitlePanelListBtn;
			var i:int,index:int;
			clearGroupBtnList();
			if(groupNum == 1){
				return;
			}else if (groupNum<8) {
				btnPrePage.visible = false;
				btnNexPage.visible = false;
				for (i=0; i<groupNum; i++) {
					btn = new SubTitlePanelListBtn(i);
					btn.addEventListener(SubTitlePanel.PAGEBTN,onBtnClickEvent);
					btn.x = (500 - groupNum * 30) + 30 * i;
					btn.y = 276;
					groubBtnList.push(btn);
					addChild(btn);
				}
				btnPrePage.visible = false;
				btnNexPage.visible = false;
			} else {
				if (curIndex>=2 && curIndex<=groupNum-3) {
					index = curIndex - 2;
				} else if (curIndex<2) {
					index = 0;
				} else if (curIndex+2>=groupNum) {
					index = groupNum - 8;
				}
				for (i=index; i<index+8; i++) {
					btn = new SubTitlePanelListBtn(i);
					if (i==(index+8-1) && index+8!=groupNum) {
						btn.setText("...");
					}
					btn.addEventListener(SubTitlePanel.PAGEBTN,onBtnClickEvent);
					btn.x=(500-2*56-8*30)+46+30*(i-index);
					btn.y = 276;
					groubBtnList.push(btn);
					addChild(btn);
				}
				btnPrePage.y = 276;
				btnNexPage.y = 276;
				btnPrePage.x=(500-2*56-8*30);
				btnNexPage.x=(500-2*56-8*30)+56+30*8+6;
				btnPrePage.visible = true;
				btnNexPage.visible = true;
			}
		}
		private function selectGroup(gid:int):void {
			this.groupid = gid;
			this.curGroupId = gid;
			itemList.forEach(updateGroupState);
			renderGroupBtn(this.groupid,groupNum);
			groubBtnList.forEach(updateGroupBtnState);
			
			updateCancelSrtBtn();
		}
		private function updateGroupState(item:Object,index:int,list:Array):void {
			item.showGroup(this.groupid);
		}
		private function updateGroupBtnState(btn:Object,index:int,list:Array):void {
			btn.selectBtn(this.groupid);
		}
		private function onMouseClickEvent(e:MouseEvent):void {
			switch (e.target) {
				//case btnConfig :
					//dispatchEvent(new Event(SubTitlePanel.CONFIG));
					//break;
				case btnCancel :
					selectItem(new SubTitlePanelListItem("-1",-1,"","",""));
					dispatchEvent(new Event(SubTitlePanel.CANCEL));
					break;
				case btnPrePage :
					if (curGroupId-1<0) {
						curGroupId = 0;
						//btnPrePage.visible=false;
					} else {
						curGroupId--;
					}
					selectGroup(curGroupId);
					break;
				case btnNexPage :
					if (curGroupId+1>=groupNum) {
						curGroupId = groupNum - 1;
						//btnNexPage.visible=false;
					} else {
						curGroupId++;
					}
					selectGroup(curGroupId);
					break;
			}
			e.stopImmediatePropagation();
		}
		private function onItemClickEvent(e:Event):void {
			var item:SubTitlePanelListItem = e.target as SubTitlePanelListItem;
			selectItem(item);
			e.stopImmediatePropagation();
		}
		private function onBtnClickEvent(e:Event):void {
			var btn:SubTitlePanelListBtn = e.target as SubTitlePanelListBtn;
			selectGroup(btn.index);
			e.stopImmediatePropagation();
		}
	}

}