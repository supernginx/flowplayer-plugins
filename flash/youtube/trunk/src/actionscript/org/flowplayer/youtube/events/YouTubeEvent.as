package org.flowplayer.youtube.events {

	import flash.events.Event;
	
	public class YouTubeEvent extends Event {
		
		public var data:*;
		
		public static  const IOERROR:String = "IOERROR";
		public static  const STATE_CHANGE:String = "STATE_CHANGE";
		public static  const ERROR:String = "ERROR";
		public static  const READY:String = "READY";
		public static  const QUALITY_CHANGED:String = "QUALITY_CHANGED";

		public function YouTubeEvent(type:String, data:*) {
			this.data= data;
			super(type);
		}
	}
}
