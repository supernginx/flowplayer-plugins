package org.flowplayer.rtmp.cluster.event
{
	import org.flowplayer.model.EventType;
	
	public class RTMPEventType extends EventType
	{
		public static const FAILED:RTMPEventType = new RTMPEventType("onFailed");
		public static const RECONNECTED:RTMPEventType = new RTMPEventType("onReconnect");
		
		public function RTMPEventType(name:String)
		{
			super(name);
		}

	}
}