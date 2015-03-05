package com.baidu.ui.controls.progressbar  {
	
	import flash.display.MovieClip;
	import transitions.Tweener;
	import flash.events.MouseEvent;
	import flash.display.Stage;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.globalization.DateTimeFormatter;

	public class ProgressBar extends MovieClip {
		
		public static var PROGRESS:String="progress";
		
		private var callback:Function;
		
		private var code:String;
		
		private var tip:ProgressBarTip;
		
		private var sroot:Stage;
		private var icursor:Number=0;
		private var ibuffer:Number=0;
		private var isDrag:Boolean=false;
		private var durationTime:uint=0;
		private var timeFormatter:DateTimeFormatter;
		public function ProgressBar() {
			mcCurBar.alpha=0;
			mcCurBar.scaleX=0.3;
			mcCurBar.scaleY=0.3;
			mcCurBar.x=9;
			mcCursorBar.height=2;
			mcBufferBar.height=2;
			mcBgBar.height=2;
			timeFormatter = new DateTimeFormatter("en-US");
			timeFormatter.setDateTimePattern("HH:mm:ss");
		}
		override public function set width(w:Number):void{
			mcBgBar.width=w;
			mcTopBar.width=w;
			mcCursorBar.width = mcBgBar.width*icursor/100;
			mcBufferBar.width = mcBgBar.width*ibuffer/100;
			this.cursor=mcCursorBar.width;
		}
		public function setDurationTime(time:uint=0):void{
			durationTime = time;
			mcTopBar.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMoveEvent);
			mcTopBar.addEventListener(MouseEvent.MOUSE_OVER,onMouseOverEvent);
			mcTopBar.addEventListener(MouseEvent.MOUSE_OUT,onMouseOutEvent);
			mcTopBar.addEventListener(MouseEvent.MOUSE_UP,onMouseUpEvent);
			mcTopBar.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownEvent);
		}
		public function setTip(t:ProgressBarTip):void{
			tip=t;
			tip.alpha=0;
		}
		
		public function set cursor(r:Number):void{
			mcCursorBar.width = mcBgBar.width*r/100;
			icursor=r;
			if(mcCursorBar.width<=9){
				mcCurBar.x=9;
			}else if(mcCursorBar.width>=mcBgBar.width-9){
				mcCurBar.x=mcBgBar.width-9;
			}else{
				mcCurBar.x=mcCursorBar.width;
			}
			
		}
		public function set buffer(r:Number):void{
			mcBufferBar.width = mcBgBar.width*r/100;
			ibuffer=r;
		}
		private function onMouseMoveEvent(e:MouseEvent):void{
			if(durationTime){
				tip.mcInfoTxt.text=timeFormatter.format(new Date(2014,0,0,0,0,durationTime*e.target.mouseX/100));
			}
			//tip.mcInfoTxt.text=e.target.mouseX+"%";
			
			var dx:int=this.width*Number(e.target.mouseX/100);
			if(dx<=35){
				Tweener.removeTweens(tip,['x']);
				tip.cur.x=dx-35;
				tip.x=35;
				tip.alpha=1;
			}else if(dx>=this.width-35){
				Tweener.removeTweens(tip,['x']);
				tip.cur.x=dx-this.width+35;
				tip.x=this.width-35;
				tip.alpha=1;
			}else{
				tip.cur.x=0;
				Tweener.addTween (tip,{x:dx,time:0.5});
			}
			if(isDrag){
				onMouseDownEvent();
			}
		}
		private function onMouseOverEvent(e:MouseEvent):void{
			tip.x=this.width*Number(e.target.mouseX/100);
			Tweener.addTween (tip,{alpha:1,time:0.3});
			Tweener.addTween (mcCurBar,{alpha:1,scaleX:1,scaleY:1,time:0.5});
			Tweener.addTween (mcCursorBar,{height:6,time:0.5});
			Tweener.addTween (mcBufferBar,{height:6,time:0.5});
			Tweener.addTween (mcBgBar,{height:6,time:0.5});
		}
		private function onMouseOutEvent(e:MouseEvent=null):void{
			Tweener.addTween (tip,{alpha:0,time:0.3});
			Tweener.addTween (mcCurBar,{alpha:0,scaleX:0.3,scaleY:0.3,time:0.5});
			Tweener.addTween (mcCursorBar,{height:2,time:0.5});
			Tweener.addTween (mcBufferBar,{height:2,time:0.5});
			Tweener.addTween (mcBgBar,{height:2,time:0.5});
			onMouseUpEvent();
		}
		/*private function onMouseClickEvent(e:MouseEvent):void{
			callback(code,mcTopBar.mouseX);
			this.cursor = mcTopBar.mouseX;
		}*/
		private function onMouseDownEvent(e:MouseEvent=null):void{
			this.cursor = mcTopBar.mouseX;
			this.buttonMode=true;
			isDrag=true;
		}
		private function onMouseUpEvent(e:MouseEvent=null):void{
			isDrag && callback(code,mcTopBar.mouseX);
			this.buttonMode=false;
			isDrag=false;
		}
		public function register(c:String,cb:Function){
			code=c;
			callback=cb;			
		}
	}
	
}