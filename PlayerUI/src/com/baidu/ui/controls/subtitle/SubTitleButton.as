package com.baidu.ui.controls.subtitle {

	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.external.ExternalInterface;
	import com.baidu.ui.PlayerUI;
	
	public class SubTitleButton extends MovieClip {
		public static var SUBTITLE:String = "subtitle";
		public static var SUBTIME:String = "subtime";
		public static var SUBSEARCH:String = "subsearch";
		
		private var callback:Function;
		private var code:String;
		private var filename:String;
		private var subTitlePanel:SubTitlePanel = null;
		private var subTitleBar:SubTitleBar = null;
		private var ready:Boolean = false;
		private var container:Sprite;

		public function SubTitleButton(contextUI:Sprite=null, fileName:String="") {
			container = contextUI;
			subTitlePanel=new SubTitlePanel(fileName);
			subTitlePanel.addEventListener(SubTitlePanel.ADTIME,onButtonEvent);
			subTitlePanel.addEventListener(SubTitlePanel.FONTSIZE,onButtonEvent);
			subTitlePanel.addEventListener(SubTitlePanel.CHOOSE,onButtonEvent);
			
			subTitlePanel.addEventListener(SubTitlePanel.CHOOSE_SEARCH,onButtonEvent);
			
			subTitlePanel.addEventListener(SubTitlePanel.SEARCH,onButtonEvent);
			subTitlePanel.addEventListener(SubTitlePanel.CANCEL,onButtonEvent);
			this.addEventListener(MouseEvent.ROLL_OVER,onMouseOverEvent);
		}

		
		public function resizeSubPanel():void {
			if (ready == true) {
				subTitlePanel.y = this.parent.y + 11.9;
				subTitlePanel.x = this.x;
			}
		}
		
		private function onMouseOverEvent(e:MouseEvent):void {
			if (ready == false) {
				container.addChild(subTitlePanel);
				ready = true;
			}
			//在全局控制栏是否已经正常展现的情况下
			if (PlayerUI.controlContainerVisible) {
				subTitlePanel.show();
				resizeSubPanel();
			}
			//com.baidu.ui.PlayerUI.controlContainerVisible && subTitlePanel.show();
		}
		public function setSubTitleBar(sBar:SubTitleBar):void{
			subTitleBar=sBar;
		}
		public function register(c:String,cb:Function):void{
			code=c;
			callback=cb;
		}
		
		public function onButtonEvent(e:Event):void{
			
			switch(e.type){
				case SubTitlePanel.ADTIME:
					subTitleBar.setAdjustTime(e.target.adtime);
					break;
				case SubTitlePanel.FONTSIZE:
					subTitleBar.setFontSize(e.target.fontsize);
					break;
				case SubTitlePanel.CHOOSE:
					subTitleBar.loadSrt(e.target.itemurl);
					break;
				case SubTitlePanel.CHOOSE_SEARCH:
					addSrtData([e.target.srtItem], true);
					//subTitleBar.loadSrt(e.target.item.url);
					break;
				case SubTitlePanel.CANCEL:
					subTitleBar.closeSrt();
					break;
				case SubTitlePanel.SEARCH:
					callback(SubTitleButton.SUBSEARCH);
					break;
			}
		}
		public function hidePanel():void {
			subTitlePanel.hide();
		}
		public function addSrtData(datas:Array,autoSelected:Boolean=false):String {
			/*var storage:SharedObject = PlayerUI.getStorage();
			
			if(autoSelected && datas.length==1){
				storage.data[PlayerUI.MOVIEID] = datas[0]['id'];
				storage.flush();
			}
			
			var itemid:String = storage.data[PlayerUI.MOVIEID];
			datas.forEach(function(item:Object,index:int,arr:Array){
				if(item['id']==itemid){
					subTitleBar.loadSrt(item['url']);
				}
			});*/
			return subTitlePanel.addSrtData(datas,autoSelected);
		}
		
		public function updateSrtTips():void {
			subTitlePanel.updateSrtTips();
		}
	}

}