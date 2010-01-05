package org.flowplayer.bwcheck.monitor {
	
	import org.flowplayer.model.ClipEvent;
	import flash.net.NetStream;
	import org.flowplayer.bwcheck.BitrateStorage;

	public interface QosMonitor {
				
        function set bitrateProperties(value:Array):void
		function set bitrateStorage(storage:BitrateStorage):void 
        function set netStream(netStream:NetStream):void
		function start():void
		function stop():void
		function onStart(event:ClipEvent = null):void
		function onStop(event:ClipEvent):void
		function onBufferEmpty(event:ClipEvent):void
		function onBufferFull(event:ClipEvent = null):void
		function onPause(event:ClipEvent):void
		function onResume(event:ClipEvent):void
		function onSeek(event:ClipEvent):void
		function onError(event:ClipEvent):void
		function addEventListener(type:String,listener:Function,useCapture:Boolean = false,priority:int = 0,useWeakReference:Boolean = false):void;
		function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void;
	}
}
