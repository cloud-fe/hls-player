package com.baidu.ui.controls.volume  {
	
	import transitions.Tweener;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import com.baidu.ui.PlayerUI;

	public class VolumePanel extends MovieClip {
		private var code:String;
		private var callback:Function=null;
		private var beOperated:Boolean=false;
		
		
		public function VolumePanel() {
			mcSilentBar.visible = false;
			this.addEventListener(MouseEvent.ROLL_OUT,onMouseRollOutEvent);
			mcCurBar.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownEvent);
			mcTopBar.addEventListener(MouseEvent.MOUSE_DOWN,onMouseClickEvent);
			
			volumeButton.addEventListener(MouseEvent.CLICK, onClickEvent);
			mcSilentBar.addEventListener(MouseEvent.CLICK, onClickEvent);
			onHideFinished();
			
			callCallback();
		}
		private var cacheVolume:Number = 0;
		private function onClickEvent(e:MouseEvent):void {
			if (this.volume == 0) {
				if (cacheVolume == 0) {
					this.volume = 100;
				} else {
					this.volume = cacheVolume;
				}
			} else {
				cacheVolume = this.volume;
				this.volume = 0;
			}
			callCallback();
		};
		
		public function set volume(v:Number):void{
			mcProBar.height=Math.round(80*v/100);
			mcCurBar.y=-40-mcProBar.height;
			mcSilentBar.visible = v == 0;
		}
		public function get volume():Number{
			return Math.round(100*mcProBar.height/80);
		}
		private function onMouseDownEvent(e:MouseEvent):void{
			Tweener.removeTweens(mcCurBar,['y']);
			Tweener.removeTweens(mcProBar,['height']);
			mcCurBar.startDrag(false,new Rectangle (25,-120,0,80));
			this.addEventListener(MouseEvent.MOUSE_UP,onMouseUpEvent);
			this.addEventListener(Event.ENTER_FRAME,onFrameEvent);
			//有操作
			beOperated=true;
		}
		private function onMouseUpEvent(e:MouseEvent=null):void{
			mcCurBar.stopDrag();
			this.removeEventListener(MouseEvent.MOUSE_UP,onMouseUpEvent);
			this.removeEventListener(Event.ENTER_FRAME,onFrameEvent);
			callCallback();
			beOperated=false;
		}
		private function onMouseRollOutEvent(e:MouseEvent):void{
			onMouseUpEvent();
			this.hide();
		}
		private function onMouseClickEvent(e:MouseEvent):void{
			var m:int=-mcTopBar.mouseY;
			if(m<=0)m=0;
			if(m>=80)m=80;
			Tweener.addTween (mcCurBar,{y:-m-40,time:0.5});
			Tweener.addTween (mcProBar,{height:m,time:0.5,onComplete:function(){
				//有操作
				beOperated=true;
				onMouseUpEvent();
			}});
			
		}
		private function onFrameEvent(e:Event):void{
			mcProBar.height=-40-mcCurBar.y;
			mcSilentBar.visible = this.volume == 0;
			callCallback();
		}
		public function hide():void{
			Tweener.addTween (this,{alpha:0,time:0.5,onComplete:onHideFinished});
		}
		public function show():void{
			com.baidu.ui.PlayerUI.VolumePanelVisible = true;
			this.alpha=0.1;
			this.visible=true;
			Tweener.addTween (this,{alpha:1,time:0.5});
		}
		private function onHideFinished():void{
			this.visible=false;
			com.baidu.ui.PlayerUI.VolumePanelVisible = false;
		}
		
		private function callCallback():void {
			callback && callback(code,this.volume);
		}
		
		public function register(c:String,cb:Function){
			code=c;
			callback=cb;
		}
	}
	
}
