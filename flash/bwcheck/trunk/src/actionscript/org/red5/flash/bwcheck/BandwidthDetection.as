/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>, Anssi Piirainen Flowplayer Oy
 * Copyright (c) 2009 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.red5.flash.bwcheck
{
	import flash.events.EventDispatcher;
	import flash.net.NetConnection;
    import org.flowplayer.util.Log;
    import org.red5.flash.bwcheck.events.BandwidthDetectEvent;
	import org.red5.flash.bwcheck.IBandwidthDetection;

	[Event(name=BandwidthDetectEvent.DETECT_STATUS, type="org.red5.flash.bwcheck.events.BandwidthDetectEvent")]
	[Event(name=BandwidthDetectEvent.DETECT_COMPLETE, type="org.red5.flash.bwcheck.events.BandwidthDetectEvent")]
	
	public class BandwidthDetection extends EventDispatcher implements IBandwidthDetection
	{
        protected var log:Log = new Log(this);
		protected var _nc:NetConnection;
		protected var _service:String = "checkBandwidth";
		protected var _url:String;
		
		public function BandwidthDetection()
		{
	
		}
		
		protected function dispatch(info:Object, eventName:String):void
		{
			var event:BandwidthDetectEvent = new BandwidthDetectEvent(eventName);
			event.info = info;
			dispatchEvent(event);
		}
		
		protected function dispatchStatus(info:Object):void
		{
			var event:BandwidthDetectEvent = new BandwidthDetectEvent(BandwidthDetectEvent.DETECT_STATUS);
			event.info = info;
			dispatchEvent(event);
		}
		
		protected function dispatchComplete(info:Object):void
		{
			var event:BandwidthDetectEvent = new BandwidthDetectEvent(BandwidthDetectEvent.DETECT_COMPLETE);
			event.info = info;
			dispatchEvent(event);
		}
		
		protected function dispatchFailed(info:Object):void
		{
			var event:BandwidthDetectEvent = new BandwidthDetectEvent(BandwidthDetectEvent.DETECT_FAILED);
			event.info = info;
			dispatchEvent(event);
		}
		
		public function set connection(connect:NetConnection):void
		{
			_nc = connect;
		}
		
		public function set url(url:String):void
		{
			_url = url;
		}
		
		public function start():void
		{
			
		}
		
		public function set service(value:String):void
		{
			_service = value;
		}

	}
}