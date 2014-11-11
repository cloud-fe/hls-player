package com.baidu.ui.controls.subtitle {

	import com.baidu.ui.PlayerUI;
	
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import transitions.Tweener;

	public class SubTitlePanel extends MovieClip {
		//搜索字幕
		public static const SEARCH:String = "search";
		//设置按钮
		public static const CONFIG:String = "config";
		//调节字幕时间
		public static const ADTIME:String = "adtime";
		//调教字幕文字大小
		public static const FONTSIZE:String = "fontsize";
		//选择字幕
		public static const CHOOSE:String = "choose";
		//搜索字幕面板 选择字幕
		public static const CHOOSE_SEARCH:String = "choosesearch";
		//搜索字幕面板 input输入框获得焦点
		public static const SEARCH_FOCUS:String = "searchfocus";
		//关闭配置面板
		public static const CONFCLOSE:String = "confclose";
		//取消字幕
		public static const CANCEL:String = "cancel";
		//面板标识
		public static const PAGEBTN:String = "pagebtn";
		//调起无字幕面板事件
		public static const PANEL_NOINFOR:String = "panelnoinfor";
		//调起字幕配置面板事件
		public static const PANEL_CONFIG:String = "panelconfig"; 
		//调起字幕列表面板事件
		public static const PANEL_LIST:String = "panellist";
		//调起搜索字幕面板
		public static const PANEL_SEARCH:String = "panelsearch";
		//切换面板的按钮
		public static const PANEL_SELECT:String  = "panelselect";

		
		public static const SEARCH_INPUT_MOUSE_DOWN:String = "searchinputmousedown";
		public static const SEARCH_INPUT_MOUSE_UP:String = "searchinputmouseup";
		
		private var positionLeftMap:Object = {
			panellist: -428,
			panelnoinfor: -428,
			panelsearch: -207,
			panelconfig: -317
		};
		
		//字幕列表
		private var subTitlePanelList:SubTitlePanelList;
		//搜索字幕列表
		private var subTitlePanelSearch:SubTitlePanelSearch;
		//字幕配置
		private var subTitlePanelConfig:SubTitlePanelConfig;
		//无字幕缺省面板
		private var subTitlePanelNoInfor:SubTitlePanelNoInfor;
		//头部
		private var subTitlePanelTitle:SubTitlePanelTitle;

		public var adtime:Number;
		public var fontsize:int;
		public var itemurl:String;
		public var srtItem:Object;

		private var curPanel:String;
		
		private var fileName:String;
		
		public function SubTitlePanel(fileName:String="") {
			this.addEventListener(MouseEvent.ROLL_OUT,onMouseRollOutEvent);
			
			this.fileName = fileName;
			
			subTitlePanelList = new SubTitlePanelList  ;
			subTitlePanelList.addEventListener(SubTitlePanel.CHOOSE,onPanelEvent);
			subTitlePanelList.addEventListener(SubTitlePanel.SEARCH,onPanelEvent);
			subTitlePanelList.addEventListener(SubTitlePanel.CONFIG,onPanelEvent);
			subTitlePanelList.addEventListener(SubTitlePanel.CANCEL,onPanelEvent);
			subTitlePanelList.x = -444;
			subTitlePanelList.y = -322;
			addChild(subTitlePanelList);
			
			subTitlePanelSearch = new SubTitlePanelSearch  ;
			subTitlePanelSearch.addEventListener(SubTitlePanel.CHOOSE_SEARCH,onPanelEvent);
			subTitlePanelSearch.addEventListener(SubTitlePanel.SEARCH_FOCUS,onPanelEvent);
			subTitlePanelSearch.addEventListener(SubTitlePanel.SEARCH_INPUT_MOUSE_DOWN,onPanelEvent);
			subTitlePanelSearch.addEventListener(SubTitlePanel.SEARCH_INPUT_MOUSE_UP,onPanelEvent);
			subTitlePanelSearch.x = -444;
			subTitlePanelSearch.y = -322;
			addChild(subTitlePanelSearch);
			
			subTitlePanelConfig = new SubTitlePanelConfig  ;
			subTitlePanelConfig.addEventListener(SubTitlePanel.ADTIME,onPanelEvent);
			subTitlePanelConfig.addEventListener(SubTitlePanel.FONTSIZE,onPanelEvent);
			subTitlePanelConfig.addEventListener(SubTitlePanel.CONFCLOSE,onPanelEvent);
			subTitlePanelConfig.x = -444;
			subTitlePanelConfig.y = -322;
			addChild(subTitlePanelConfig);
			
			subTitlePanelNoInfor = new SubTitlePanelNoInfor  ;
			subTitlePanelNoInfor.addEventListener(SubTitlePanel.SEARCH,onPanelEvent);
			subTitlePanelNoInfor.addEventListener(SubTitlePanel.CONFIG,onPanelEvent);
			subTitlePanelNoInfor.addEventListener(SubTitlePanel.PANEL_LIST,onPanelEvent);
			subTitlePanelNoInfor.x = -444;
			subTitlePanelNoInfor.y = -322;
			addChild(subTitlePanelNoInfor);
			
			
			subTitlePanelTitle = new SubTitlePanelTitle ;
			subTitlePanelTitle.addEventListener(SubTitlePanel.PANEL_SELECT, onPanelEvent);
			subTitlePanelTitle.x = -440;
			subTitlePanelTitle.y = -380;
			addChild(subTitlePanelTitle);
			
			curPanel=SubTitlePanel.PANEL_NOINFOR;
			switchToPanel(curPanel);
			
			
			if (PlayerUI.ShowSubSearchPanel) {
				subTitlePanelTitle.txtSrtSearch.visible = true;
				subTitlePanelTitle.sepSrtSearch.visible = true;
			} else {
				subTitlePanelTitle.txtSrtSearch.visible = false;
				subTitlePanelTitle.sepSrtSearch.visible = false;
			}
		}
		
		
		import flash.external.ExternalInterface;

		private function onPanelEvent(e:Event):void {
			
//			ExternalInterface.call("console.log", e.type, "____" , e.target.val); 
			
			switch (e.type) {
				case SubTitlePanel.PANEL_SELECT:
					trace("切换面板");
					switchToPanel(e.target.val);
					break
				case SubTitlePanel.SEARCH :
					trace("调起页面中的搜索面板");
					switchToPanel(SubTitlePanel.PANEL_SEARCH);
					//dispatchEvent(new Event(SubTitlePanel.SEARCH));
					break;
				case SubTitlePanel.CANCEL :
					trace("取消字幕回调上级方法");
					dispatchEvent(new Event(SubTitlePanel.CANCEL));
					this.hide();
					break;
				case SubTitlePanel.CONFIG :
					trace("打开字幕配置面板");
					switchToPanel(SubTitlePanel.PANEL_CONFIG);
					break;
				case SubTitlePanel.CONFCLOSE :
					trace("关闭字幕配置面板");
					switchToPanel(curPanel);
					break;
				case SubTitlePanel.ADTIME :
					trace("微调字幕播放时间，告知父级button，微调字幕播放时间");
					this.adtime = e.target.adtime;
					dispatchEvent(e);
					break;
				case SubTitlePanel.FONTSIZE :
					trace("设置字体，告知父级button，设置字幕字体");
					this.fontsize = e.target.fontsize;
					dispatchEvent(e);
					break;
				case SubTitlePanel.CHOOSE :
					trace("选择字幕，告知父级button，加载字幕数据");
					this.itemurl = e.target.itemurl;
					dispatchEvent(e);
					break;
				case SubTitlePanel.CHOOSE_SEARCH :
					trace("选择字幕，告知父级button，加载搜索字幕数据");
					this.srtItem = e.target.srtItem;
					dispatchEvent(e);
					break;
				case SubTitlePanel.SEARCH_FOCUS:
					if (stage.displayState == StageDisplayState.FULL_SCREEN) {
						stage.displayState = StageDisplayState.NORMAL;
						canHideSubTitlePanel = false;
					}					
					break;
				case SubTitlePanel.SEARCH_INPUT_MOUSE_DOWN:
					//ExternalInterface.call("console.log","oninput mousedown");
					canHideSubTitlePanel = false;
					break;
				case SubTitlePanel.SEARCH_INPUT_MOUSE_UP:
					//ExternalInterface.call("console.log","oninput mouseup");
					canHideSubTitlePanel = true;
					break;
			}
		}
		
		private function switchToPanel(panel:String):void {
			subTitlePanelList.visible = SubTitlePanel.PANEL_LIST == panel;
			subTitlePanelConfig.visible = SubTitlePanel.PANEL_CONFIG == panel;
			subTitlePanelNoInfor.visible = SubTitlePanel.PANEL_NOINFOR == panel;
			subTitlePanelSearch.visible = SubTitlePanel.PANEL_SEARCH == panel;
			
			if (SubTitlePanel.PANEL_SEARCH == panel) {
				subTitlePanelSearch.setDefaultWD(this.fileName);
			}
			
			if (SubTitlePanel.PANEL_LIST == panel && flagAddSrted == false) {
				switchToPanel(SubTitlePanel.PANEL_NOINFOR);
			}
			subTitlePanelTitle.changeCurrentSelected(panel);
			Tweener.removeTweens(barAnimate,['x']);
			Tweener.addTween (barAnimate,{x: positionLeftMap[panel],time:0.5});
			//barAnimate.x = positionLeftMap[panel];
		}
		private var canHideSubTitlePanel:Boolean = true;
		private function onMouseRollOutEvent(e:MouseEvent):void {
			
			//ExternalInterface.call("console.log","domouserolloutevent     ", canHideSubTitlePanel);
			if (canHideSubTitlePanel) {
				this.hide();
			} else {
				canHideSubTitlePanel = true;
			}
		}
		public function hide():void {
			Tweener.addTween(this,{alpha:0,time:0.5,onComplete:onHideFinished});
		}
		public function show():void {
			com.baidu.ui.PlayerUI.SubTitlePanelVisible = true;
			this.alpha = 0.1;
			this.visible = true;
			Tweener.addTween(this,{alpha:1,time:0.5});
		}
		private function onHideFinished():void {
			this.visible = false;
			com.baidu.ui.PlayerUI.SubTitlePanelVisible = false;
		}
		
		private var flagAddSrted:Boolean = false;
		public function addSrtData(datas:Array,autoSelected:Boolean=false):String {
			
			if (flagAddSrted === false && datas.length > 0) {
				flagAddSrted = true;
			}
			
			//传入字幕，如果字幕有数据则现实字幕list，否则现实无信息的缺省面板
			if (datas.length) {
				if (!autoSelected) {
					curPanel=SubTitlePanel.PANEL_LIST;
					switchToPanel(curPanel);
				}
			}
			return subTitlePanelList.addSrtData(datas,autoSelected);
		}
	}

}