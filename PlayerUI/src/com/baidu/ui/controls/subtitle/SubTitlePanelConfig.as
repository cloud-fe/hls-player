package com.baidu.ui.controls.subtitle  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.net.SharedObject;
	import transitions.Tweener;
	import com.baidu.ui.PlayerUI;

	public class SubTitlePanelConfig extends MovieClip {
		var storage:SharedObject;
		public var adtime:Number = 0.0;
		public var fontsize:int;
		private var fontSizeArr:Array=[18,22,26,30];
		public function SubTitlePanelConfig() {
			btnAdd.addEventListener(MouseEvent.CLICK,onMouseClickEvent);
			btnDel.addEventListener(MouseEvent.CLICK,onMouseClickEvent);
			//btnClose.addEventListener(MouseEvent.CLICK,onMouseClickEvent);
			mcTopBar.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownEvent);
			mcTopBar.addEventListener(MouseEvent.MOUSE_UP,onMouseUpEvent);
			mcTopBar.addEventListener(MouseEvent.MOUSE_OUT,onMouseOutEvent);
			mcTopBar.addEventListener(MouseEvent.MOUSE_OVER,onMouseOverEvent);
			storage = com.baidu.ui.PlayerUI.getStorage();
			fontsize = int(storage.data[com.baidu.ui.PlayerUI.SRTFONTSIZE]);
			if(!fontsize)fontsize=fontSizeArr[2];
			fontSizeArr.forEach(function(item:Object,index:int,arr:Array){
				if(item==fontsize){
					mcCurBar.x=220+index*50;
					mcFlagBar.x=220+index*50;
				}
			});
			mcCurBar.gotoAndStop(1);
		}
		private function onMouseOverEvent(e:MouseEvent):void{
			mcCurBar.gotoAndStop(2);
		}
		private function onMouseOutEvent(e:MouseEvent):void{
			this.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMoveEvent);
			mcCurBar.gotoAndStop(1);
		}
		private function onMouseDownEvent(e:MouseEvent):void{
			mcCurBar.gotoAndStop(3);
			this.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMoveEvent);
			onMouseMoveEvent(e);
		}
		private function onMouseUpEvent(e:MouseEvent):void{
			this.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMoveEvent);
			mcCurBar.gotoAndStop(2);
		}
		private function onMouseMoveEvent(e:MouseEvent):void{
			mcCurBar.gotoAndStop(3);
			var index:int=Math.floor((e.target.mouseX-25)/50);
			if(index>3)index=3;
			if(index<0)index=0;
			fontsize=fontSizeArr[index];
			storage = com.baidu.ui.PlayerUI.getStorage();
			if(storage.data[com.baidu.ui.PlayerUI.SRTFONTSIZE]==fontsize){
				return;
			}else{
				storage.data[com.baidu.ui.PlayerUI.SRTFONTSIZE]=fontsize
			}
			storage.flush();
			Tweener.addTween (mcCurBar,{x:220+index*50,time:0.3});
			Tweener.addTween (mcFlagBar,{x:220+index*50,time:0.5});
			dispatchEvent(new Event(SubTitlePanel.FONTSIZE));
		}
		private function onMouseClickEvent(e:MouseEvent):void{
			switch(e.target){
				case btnAdd:
					adtime=Math.round((adtime+0.5)*10)/10;
					//if(adtime>5)adtime=5;
					txtTime.text=adtime+"秒";
					dispatchEvent(new Event(SubTitlePanel.ADTIME));
					break;
				case btnDel:
					adtime=Math.round((adtime-0.5)*10)/10;
					//if(adtime<-5)adtime=-5;
					txtTime.text=adtime+"秒";
					dispatchEvent(new Event(SubTitlePanel.ADTIME));
					break;
				//case btnClose:
					//dispatchEvent(new Event(SubTitlePanel.CONFCLOSE));
					//break;
			}
			e.stopImmediatePropagation();
		}
	}
	
}
