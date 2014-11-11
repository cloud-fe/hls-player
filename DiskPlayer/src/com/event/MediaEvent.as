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
	 * The MediaEvent class defines a custom event object
	 * for common events related to the OSMF media display.
	 * 
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0.0
	 */
	public class MediaEvent extends Event
	{
		//*****************************
		// Constants:
		
		public static const AUTO_REWOUND:String = "autoRewound";
		public static const BUFFERING_STATE_ENTERED:String = "bufferingStateEntered";
		public static const CLOSE:String = "close";
		public static const COMPLETE:String = "complete";
		public static const CONFIG_ERROR:String = "configError";
		public static const CONFIG_LOADED:String = "configLoaded";
		public static const DURATION_CHANGED:String = "durationChange";
		public static const MEDIA_ERROR:String = "mediaError";
		public static const PAUSED_STATE_ENTERED:String = "pausedStateEntered";
		public static const PLAYBACK_ERROR:String = "playbackError";
		public static const PLAYHEAD_UPDATE:String = "playheadUpdate";
		public static const PLAYING_STATE_ENTERED:String = "playingStateEntered";
		public static const READY:String = "ready";
		public static const SEEKED:String = "seeked";
		public static const STATE_CHANGE:String = "stateChange";
		public static const STOPPED_STATE_ENTERED:String = "stoppedStateEntered";
		public static const VOLUME_CHANGED:String = "volumeChanged";
		
		//*****************************
		// Properties:
		
		private var _state:String;
		private var _playheadTime:Number;
		
		//*****************************
		// Constructor:
		
		public function MediaEvent( type:String, bubbles:Boolean=false, cancelable:Boolean=false,
		                            state:String = null, playheadTime:Number = NaN ) 
		{
			super(type, bubbles, cancelable);
			
			_state = state;
			_playheadTime = playheadTime;
		}
		
		//*****************************
		// Methods:
		
		override public function clone():Event 
		{
			return new MediaEvent(type, bubbles, cancelable, state, playheadTime);
		}
		
		//*****************************
		// Getter/Setters:
		
		/**
		 * The playhead time of the current media.
		 */
		public function get playheadTime():Number 
		{
			return _playheadTime;
		}

		public function set playheadTime( value:Number ):void 
		{
			_playheadTime = value;
		}
		
        /**
         * A string identifying the constant from the VideoState 
         * class that describes the playback state of the component. This property is set by the 
         * <code>load()</code>, <code>play()</code>, <code>stop()</code>, <code>pause()</code>, 
         * and <code>seek()</code> methods. 
		 * 
         * #DISCONNECTED
         * #STOPPED
         * #PLAYING
         * #PAUSED
         * #BUFFERING
         * #LOADING
         * #CONNECTION_ERROR
         * #REWINDING
         * #SEEKING
         */
		public function get state():String {
			return _state;
		}

		public function set state(s:String):void {
			_state = s;
		}
	}
}