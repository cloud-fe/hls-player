package com.baidu.ui.controls.volume  {
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import com.baidu.ui.PlayerUI;
	
	
	public class VolumeButton extends MovieClip {
		public static var VOLUME:String="volume";
		private var volumePanel:VolumePanel=null;
		private var ready:Boolean=false;
		private var container:Sprite;
		public function VolumeButton(contextUI:Sprite=null) {
			volumePanel=new VolumePanel;
			container=contextUI;
			this.addEventListener(MouseEvent.MOUSE_OVER,onMouseOverEvent);
			this.mcSilentBar.visible = false;
		}
		private function onMouseOverEvent(e:MouseEvent):void{
			//元素是否就位(已添加到面板) 
			if(ready == false ){
				container.addChild(volumePanel);
				ready=true;
			}
			resizeVomPanel();
			//在全局控制栏是否已经正常展现的情况下
			com.baidu.ui.PlayerUI.controlContainerVisible && volumePanel.show();
		}
		
		public function resizeVomPanel():void {
			if (ready == true) {
				volumePanel.y=this.parent.y+18;
				volumePanel.x=this.x;
			}
		}
		
		public function set volume(v:Number):void{
			volumePanel.volume=v;
			mcSilentBar.visible = v == 0;
		}
		public function get volume():Number{
			return volumePanel.volume;
		}
		public function hidePanel():void{
			volumePanel.hide();
		}
		public function register(c:String,cb:Function){
			volumePanel.register(c,function(c:String,vol:int){
					mcSilentBar.visible = vol == 0;
					cb(c,vol);
			});
		}
		
	}
	
}
			