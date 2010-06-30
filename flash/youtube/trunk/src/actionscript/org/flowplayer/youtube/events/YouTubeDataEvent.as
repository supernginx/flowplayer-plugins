package org.flowplayer.youtube.events {

	import flash.events.Event;
	
	public class YouTubeDataEvent extends Event {
		
		public var data:*;
		
		public static  const IOERROR:String = "IOERROR";
		public static  const SECURITY_ERROR:String = "SECURITY_ERROR";
		public static  const ON_DATA:String = "ON_DATA";
		
		public function YouTubeDataEvent(type:String, data:*) {
			this.data= data;
			super(type);
		}
	}
}
