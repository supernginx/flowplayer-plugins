package org.flowplayer.pseudostreaming.net
{
	import com.adobe.net.URI;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamAppendBytesAction;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import org.flowplayer.util.Log;
	
	import org.httpclient.HttpClient;
	import org.httpclient.HttpHeader;
	import org.httpclient.HttpRequest;
	import org.httpclient.events.HttpDataEvent;
	import org.httpclient.events.HttpErrorEvent;
	import org.httpclient.events.HttpListener;
	import org.httpclient.events.HttpRequestEvent;
	import org.httpclient.events.HttpResponseEvent;
	import org.httpclient.events.HttpStatusEvent;
	import org.httpclient.http.Get;
	
	import org.flowplayer.pseudostreaming.DefaultSeekDataStore;

	
	
	public class ByteRangeNetStream extends NetStream
	{
		private var _dataStream:URLStream;
		private var _client:HttpClient;
		private var _httpHeader:HttpHeader;
		private var _eTag:String;
		private var _bytesTotal:uint = 0;
		private var _bytesLoaded:uint = 0;
		private var _seekTime:uint = 0;
		private var _currentURL:String;
		private var _seekDataStore:DefaultSeekDataStore;
		protected var log:Log = new Log(this);
		
		public function ByteRangeNetStream(connection:NetConnection, peerID:String="connectToFMS")
		{
			super(connection, peerID);	  
		}
		
		private function onIOError(event:IOErrorEvent):void {
			log.debug("IO error has occured " + event.text);
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.Failed", level:"error", message: event.text})); 
		}
		
		private function onSecurityError(event:SecurityErrorEvent):void {
			log.debug("Security error has occured " + event.text);
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.Failed", level:"error", message: event.text})); 
		}
		
		private function onError(event:HttpErrorEvent):void {
			log.debug("An error has occured " + event.text);
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.Failed", level:"error", message: event.text})); 
		}
		
		private function onTimeoutError(event:HttpErrorEvent):void {
			log.debug("Timeout error has occured " + event.text);
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.Failed", level:"error", message: event.text})); 
		}
		
		private function onComplete(event:HttpRequestEvent):void {
			//close();
			
		}
		
		private function onClose(event:Event):void {
			//close();
		}
		
		private function onStatus(event:HttpStatusEvent):void {
			
			switch (event.response.code) {
				case 404: 
					dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.StreamNotFound", level:"error"})); 
				break;
				case 200:
				default:
					_eTag = event.response.header.getValue("ETag");
					if (!_bytesTotal) _bytesTotal = event.response.contentLength;
					//_bytesTotal = event.response.contentLength;
					_httpHeader = event.response.header;
				break;
			}
		}
		
		public function getRequestHeader():HttpHeader {
			return _httpHeader;
		}
		
		override public function get bytesTotal():uint {
			return _bytesTotal;
		}
		
		override public function get bytesLoaded():uint {
			return _bytesLoaded;
		}
		
		override public function play(...parameters):void {
			
			super.play(null);
		
			try {
				_client.close();
				_client = null;
			} catch (e:Error) {
				
			}
			
			_client = new HttpClient();
			var httplistener:HttpListener = new HttpListener();
			_client.listener = httplistener;
			
			_client.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_client.addEventListener(HttpDataEvent.DATA, onData);
			_client.addEventListener(HttpStatusEvent.STATUS, onStatus);
			_client.addEventListener(HttpRequestEvent.COMPLETE, onComplete);
			_client.addEventListener(Event.CLOSE, onClose);
			_client.addEventListener(HttpErrorEvent.ERROR, onError);
			_client.addEventListener(HttpErrorEvent.TIMEOUT_ERROR, onTimeoutError);
			_client.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.Start", level:"status"})); 
		
			var uri:URI = new URI(parameters[0]);
			_currentURL = parameters[0];
			var request:HttpRequest = new Get();
			
			
			if (parameters[1] && parameters[2]) {
				
				_seekTime = parameters[1];
				_seekDataStore = parameters[2];
				
				_bytesLoaded = getByteRange(_seekTime);
				
				request.addHeader("If-Range", _eTag);	
				request.addHeader("Range", "bytes="+_bytesLoaded+"-");	
				
				this.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
				
				var bytes:ByteArray = new ByteArray();
				appendBytes(bytes);
			
				dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.Seek", level:"status"})); 
				
			}	
			
	
			_client.request(uri, request);
		}
		
		private function getByteRange(start:Number):Number {
			return  _seekDataStore.getQueryStringStartValue(start);
		}
		
		override public function close():void
		{
			_client.close();
			_client = null;
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.Stop", level:"status"})); 
			super.close();
		}
		
		override public function seek(seconds:Number):void {
			play(_currentURL, seconds, _seekDataStore);	
		}

		private function onData(event:HttpDataEvent):void {				
			var bytes:ByteArray = event.bytes; 
			_bytesLoaded += bytes.length;
			
		
			this.appendBytes(bytes);
		}
		
		override public function get time():Number {
			return _seekTime + super.time;	
		}
		
	}
}