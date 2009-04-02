/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2008 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
 
package org.flowplayer.bwcheck.servers
{

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.Responder;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.getTimer;
	
	import org.red5.flash.bwcheck.BandwidthDetection;
	
	public class HttpServerClientBandwidth extends BandwidthDetection
	{
		private var info:Object = new Object();
		private var res:Responder;
		private var _counter:int = 0;
		private var loader:URLLoader;
		private var request:URLRequest;
		private var _startTime:Number;
		private var _bytes:Number;
		private var _bandwidth:Number;
		private var _downloadTime:Number;
		public var maximumBytes:uint;
		private var _url:String;
		
		public function HttpServerClientBandwidth()
		{
	
			loader = new URLLoader();
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);

		}
		
		public function set url(url:String):void
		{
			_url = url;
		}
		
		public function onComplete(event:Event):void
		{
            log.debug("reference file successfully downloaded");
			this._downloadTime = getTimer() - this._startTime;
			this._bytes = event.currentTarget.bytesLoaded;
			this._bandwidth = this._bytes * 8 / this._downloadTime;
			
			loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.removeEventListener(Event.COMPLETE, onComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			
			var obj:Object = new Object();		
			obj.kbitDown = this._bandwidth;
					
			dispatchComplete(obj);
		}
		
		public function onProgress(event:ProgressEvent):void
		{
			this._downloadTime = getTimer() - this._startTime;
			this._bytes = event.currentTarget.bytesLoaded;
			this._bandwidth = this._bytes * 8 / this._downloadTime;
			
			if (this.maximumBytes && (this._bytes >= this.maximumBytes))
			{
				loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			
				loader.close();
				var e:Event = new Event(Event.COMPLETE);
				loader.dispatchEvent(e);
			}
			
			var obj:Object = new Object();
            obj.info = new Object();
			obj.info.count = this._bytes;
			
			dispatchStatus(obj);
		}
		

		override public function start():void
		{
			log.debug("requesting reference file " + _url);
            request = new URLRequest(_url);
			var noCacheHeader:URLRequestHeader = new URLRequestHeader('pragma', 'no-cache');
			request.requestHeaders.push(noCacheHeader);
			
			this._startTime = getTimer();
			loader.load(request);
		}
		
		protected function onResult(obj:Object):void
		{
			dispatchStatus(obj);
				
		}
		
		protected function onError(event:IOErrorEvent):void
		{
			var obj:Object = new Object();
			obj.application = "";
			obj.description = event.text;
			dispatchFailed(obj);
			/*
			switch (obj.code)
			{
				case "NetConnection.Call.Failed":
					dispatchFailed(obj);
				break;
			}*/

		}
	}
}