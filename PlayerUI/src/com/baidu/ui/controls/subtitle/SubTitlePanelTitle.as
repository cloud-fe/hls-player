package com.baidu.ui.controls.subtitle {

	import transitions.Tweener;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.ui.Mouse;

	public class SubTitlePanelTitle extends MovieClip {
		
		public var val:String = 'panellist';
		public function SubTitlePanelTitle() {
			
			txtSrtDefault.addEventListener(MouseEvent.CLICK,onMouseClickEvent);
			txtSrtSearch.addEventListener(MouseEvent.CLICK,onMouseClickEvent1);
			txtSrtConfig.addEventListener(MouseEvent.CLICK,onMouseClickEvent2);
			
			addMouseEvent(txtSrtDefault);
			addMouseEvent(txtSrtSearch);
			addMouseEvent(txtSrtConfig);
		}
		
		private function addMouseEvent(text:TextField):void {
			text.addEventListener(MouseEvent.MOUSE_OVER,mousesj1);
			text.addEventListener(MouseEvent.MOUSE_OUT,mousesj2);
		}
		
		private function mousesj1(e:MouseEvent) {
			Mouse.cursor="button";
		}
		private function mousesj2(e:MouseEvent) {
			Mouse.cursor="auto";
		}
		
		private function onMouseClickEvent1(e:MouseEvent):void {
			this.val = 'panelsearch';
			dispatchEvent(new Event(SubTitlePanel.PANEL_SELECT));
			e.stopImmediatePropagation();
		}
		private function onMouseClickEvent2(e:MouseEvent):void {
			this.val = 'panelconfig';
			dispatchEvent(new Event(SubTitlePanel.PANEL_SELECT));
			e.stopImmediatePropagation();
		}
		private function onMouseClickEvent(e:MouseEvent):void {
			this.val = 'panellist';
			dispatchEvent(new Event(SubTitlePanel.PANEL_SELECT));
			e.stopImmediatePropagation();
		}
		
		private var defaultColor:uint = 0xffD5D5D5;
		private var selectedColor:uint = 0xff0591fb;
		public function changeCurrentSelected(val:String):void {
			
			txtSrtDefault.textColor = defaultColor;
			txtSrtSearch.textColor = defaultColor;
			txtSrtConfig.textColor = defaultColor;
			
			if (val == 'panelsearch') {
				txtSrtSearch.textColor = selectedColor;
			} else if (val == 'panelconfig') {
				txtSrtConfig.textColor = selectedColor;
			} else {
				txtSrtDefault.textColor = selectedColor;
			}
		}
	}

}