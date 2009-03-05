package org.red5.flash.bwcheck
{
	import flash.events.EventDispatcher;
	import flash.net.NetConnection;
	import org.red5.flash.bwcheck.events.BandwidthDetectEvent;
	

	public interface IBandwidthDetection
	{
		
		function start():void;
		function set service(service:String):void;
		function set connection(connect:NetConnection):void;

	}
}