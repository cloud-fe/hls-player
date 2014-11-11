/**************************************
 * Developed for the Adobe Flash Developer Center.
 * Written by Dan Carr (dan@dancarrdesign.com), 2011.
 * 
 * Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License
 * http://creativecommons.org/licenses/by-sa/3.0/
 */
package com.event
{
	import flash.events.Event;
	
	/**********************************
	 * The ProgressEvent class defines a custom event object
	 * representing the progress information for loading media.
	 * 
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0.0
	 */
	public class ProgressEvent extends Event
	{
		//*****************************
		// Constants:
		
		public static const MEDIA_PROGRESS:String = "mediaProgress";
		
		//*****************************
		// Properties:
		
		private var _bytesLoaded:uint;
		private var _bytesTotal:uint;
		
		//*****************************
		// Constructor:
		
		public function ProgressEvent( type:String, bubbles:Boolean, cancelable:Boolean, loaded:uint, total:uint ):void
		{
			super(type, bubbles, cancelable);
			
			_bytesLoaded = loaded;
			_bytesTotal = total;
		}
		
		//*****************************
		// Methods:
		
		override public function clone():Event 
		{
			return new ProgressEvent(type, bubbles, cancelable, bytesLoaded, bytesTotal);
		}
		
		//*****************************
		// Getter/Setters:
		
		/**
		 * Bytes loaded so far.
		 */
		public function get bytesLoaded():uint 
		{
			return _bytesLoaded;
		}

		public function set bytesLoaded( value:uint ):void 
		{
			_bytesLoaded = value;
		}
		
		/**
		 * Total number of bytes to load.
		 */
		public function get bytesTotal():uint {
			return _bytesTotal;
		}

		public function set bytesTotal( value:uint ):void {
			_bytesTotal = value;
		}
	}
}