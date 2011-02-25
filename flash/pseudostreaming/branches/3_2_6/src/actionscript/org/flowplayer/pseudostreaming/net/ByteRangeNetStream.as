package org.flowplayer.pseudostreaming.net
{
    import com.adobe.net.URI;

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.NetStatusEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    import flash.net.URLStream;
    import flash.net.NetStreamAppendBytesAction;
    //import flash.system.Security;
    import flash.utils.ByteArray;
    import flash.utils.setTimeout;

    import org.flowplayer.pseudostreaming.DefaultSeekDataStore;
    import org.flowplayer.util.Log;
    import org.httpclient.HttpClient;
    import org.httpclient.HttpHeader;
    import org.httpclient.HttpRequest;
    import org.httpclient.events.HttpDataEvent;
    import org.httpclient.events.HttpErrorEvent;
    import org.httpclient.events.HttpListener;
    import org.httpclient.events.HttpRequestEvent;
    import org.httpclient.events.HttpStatusEvent;
    import org.httpclient.http.Get;
    
    import org.osmf.net.httpstreaming.flv.FLVHeader;
    import org.osmf.net.httpstreaming.flv.FLVParser;
    import org.osmf.net.httpstreaming.flv.FLVTag;
    import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
    import org.osmf.net.httpstreaming.flv.FLVTagVideo;
    import org.osmf.net.httpstreaming.flv.FLVTagAudio;

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
		private var _ended:Boolean;
		private var _serverAcceptsBytes:Boolean;
		
		private static const MAIN_TIMER_INTERVAL:int = 25;
        
    
        private var _numQualityLevels:int = 0;
        private var _qualityRates:Array;    
        private var _streamNames:Array;
        private var _segmentDuration:Number = -1;
        private var _urlStreamVideo:URLStream = null;
        private var _loadComplete:Boolean = false;

        private var _dataAvailable:Boolean = false;
        private var _qualityLevel:int = 0;
        private var qualityLevelHasChanged:Boolean = false;
        private var _seekTarget:Number = -1;
        private var _lastDownloadStartTime:Number = -1;
        private var _lastDownloadDuration:Number;
        private var _lastDownloadRatio:Number = 0;
        private var _manualSwitchMode:Boolean = false;
        private var _aggressiveUpswitch:Boolean = true; // XXX needs a getter and setter, or to be part of a pluggable rate-setter
    
        private var _totalDuration:Number = -1;
        private var _enhancedSeekTarget:Number = -1;    // now in seconds, just like everything else
        private var _enhancedSeekEnabled:Boolean = false;
        private var _enhancedSeekTags:Vector.<FLVTagVideo>;
        private var _flvParserIsSegmentStart:Boolean = false;
        private var _savedBytes:ByteArray = null;
    
        private var _prevState:String = null;
        private var _seekAfterInit:Boolean;
        private var indexIsReady:Boolean = false;
        private var _insertScriptDataTags:Vector.<FLVTagScriptDataObject> = null;
        private var _flvParser:FLVParser = null;    // this is the new common FLVTag Parser
        private var _flvParserDone:Boolean = true;  // signals that common parser has done everything and can be removed from path
        private var _flvParserProcessed:uint;
        private var _initialTime:Number = -1;   // this is the timestamp derived at start-of-play (offset or not)... what FMS would call "0"
        
        private var _fileTimeAdjustment:Number = 0; // this is what must be added (IN SECONDS) to the timestamps that come in FLVTags from the file handler to get to the index handler timescale
        // XXX an event to set the _fileTimestampAdjustment is needed
        private var _playForDuration:Number = -1;
        private var _lastValidTimeTime:Number = 0;
        private var _retryAfterWaitUntil:Number = 0;    // millisecond timestamp (as per date.getTime) of when we retry next
        

        private var _unpublishNotifyPending:Boolean = false;
        private var _signalPlayStartPending:Boolean = false;
		
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
	
			
		}
		
		private function streamComplete():void {
			_seekTime = _seekTime + 1;
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.Stop", level:"status"})); 
			_ended = true;
			this.appendBytesAction(NetStreamAppendBytesAction.END_SEQUENCE);
		}
		
		private function onClose(event:Event):void {
	
			//send complete status once the buffer length is finished
			if (_bytesLoaded >= _bytesTotal) {
				setTimeout(streamComplete, this.bufferLength * 1000);
			}
			
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
					
					_httpHeader = event.response.header;
					
					if (!_serverAcceptsBytes && _httpHeader.find("Accept-Ranges")) {
						log.debug("Server accepts byte ranges");
						_serverAcceptsBytes = true; 
					}
					
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
			
			/*Security.allowInsecureDomain("*");
			Security.allowDomain("*");

            Security.loadPolicyFile("http://flowplayer.electroteque.org/xml/crossdomain.xml")*/

			var header:FLVHeader = new FLVHeader();
            var headerBytes:ByteArray = new ByteArray();
            header.write(headerBytes);
            
            appendBytes(headerBytes);
            
            
            
            _flvParser = new FLVParser(false);
            _flvParserDone = false;
            
			_client = new HttpClient();
			var httplistener:HttpListener = new HttpListener();
			_client.listener = httplistener;
			
			_client.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_client.addEventListener(HttpDataEvent.DATA, onData);
			_client.addEventListener(HttpStatusEvent.STATUS, onStatus);
			//_client.addEventListener(HttpRequestEvent.COMPLETE, onComplete);
			_client.addEventListener(Event.CLOSE, onClose);
			_client.addEventListener(HttpErrorEvent.ERROR, onError);
			_client.addEventListener(HttpErrorEvent.TIMEOUT_ERROR, onTimeoutError);
			_client.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
		
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.Start", level:"status"})); 
		
			var uri:URI = new URI(parameters[0]);
			_currentURL = parameters[0];
			var request:HttpRequest = new Get();
			
			_ended = false;
			if (Number(parameters[1]) && DefaultSeekDataStore(parameters[2]) && _serverAcceptsBytes) {
				
				_seekTime = Number(parameters[1]);
				_seekDataStore = DefaultSeekDataStore(parameters[2]);

				_bytesLoaded = getByteRange(_seekTime);
				
				request.addHeader("If-Range", _eTag);	
				request.addHeader("Range", "bytes="+_bytesLoaded+"-");	
				
				this.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
				
				var bytes:ByteArray = new ByteArray();
				appendBytes(bytes);
			
				dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.Seek", level:"status"})); 
				
			} else {
				//reset seek, bytes loaded and send bytes reset actions
				_seekTime = 0;
				_bytesLoaded = 0;
				//this.appendBytesAction(NetStreamAppendBytesAction.END_SEQUENCE);
				//this.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
				
				
			}
			
	
			_client.request(uri, request);
		}
		
		private function getByteRange(start:Number):Number {
			return  _seekDataStore.getQueryStringStartValue(start);
		}
		
		override public function seek(seconds:Number):void {
			play(_currentURL, seconds, _seekDataStore);	
		}

		private function onData(event:HttpDataEvent):void {   
            //appendBytes(event.bytes);
            //_bytesLoaded += event.bytes.length;
            processAndAppend(event.bytes);
        }
		
		private function processAndAppend(inBytes:ByteArray):uint {
            var bytes:ByteArray;
            var processed:uint = 0;
            
            if (!inBytes)
            {
                return 0;
            }
            
    
            if (_flvParser)
            {
                //inBytes.readBytes(inBytes,inBytes.position, 8);
                inBytes.position = 0;   
                //_flvParser = null;
                inBytes.position = 10;  // rewind
                _flvParserProcessed = 0;
                _flvParser.parse(inBytes, true, flvTagHandler); // common handler for FLVTags, parser consumes everything each time just as appendBytes does when in pass-through
                processed += _flvParserProcessed;
                if(!_flvParserDone)
                {
                    // the common parser has more work to do in-path
                    return processed;
                }
                else
                {
                    // the common parser is done, so flush whatever is left and then pass through the rest of the segment
                    bytes = new ByteArray();
                    _flvParser.flush(bytes);
                    _flvParser = null;  // and now we're done with it
                }
            } //else {
            //  appendBytes(inBytes);
            //}
            else
            {
                bytes = inBytes;
            }
            
            // now, 'bytes' is either what came in or what we massaged above 
            
            // (ES is now part of unified parser)
            
            processed += bytes.length;
            
            
            
            
            
            appendBytes(bytes);
            //return 0;
            //return inBytes.length;
            //return bytes.length;
            return processed;
        }
        
        private function flvTagHandler(tag:FLVTag):Boolean
        {
            // this is the new common FLVTag Parser's tag handler
            var i:int;
            
        
            if (_insertScriptDataTags)
            {
                for (i = 0; i < _insertScriptDataTags.length; i++)
                {
                    var t:FLVTagScriptDataObject;
                    var bytes:ByteArray;
                    
                    t = _insertScriptDataTags[i];
                    t.timestamp = tag.timestamp;
                    
                    bytes = new ByteArray();
                    t.write(bytes);
                    _flvParserProcessed += bytes.length;
                    appendBytes(bytes);
                }
                _insertScriptDataTags = null;           
            }
            
            if (_playForDuration >= 0)
            {
                if (_initialTime >= 0)  // until we know this, we don't know where to stop, and if we're enhanced-seeking then we need that logic to be what sets this up
                {
                    var currentTime:Number = (tag.timestamp / 1000.0) + _fileTimeAdjustment;
                    if (currentTime > (_initialTime + _playForDuration))
                    {
                        //setState(HTTPStreamingState.STOP);
                        _flvParserDone = true;
                        if (_seekTime < 0)
                        {
                            _seekTime = _playForDuration + _initialTime;    // FMS behavior... the time is always the final time, even if we seek to past it
                            // XXX actually, FMS  actually lets exactly one frame though at that point and that's why the time gets to be what it is
                            // XXX that we don't exactly mimic that is also why setting a duration of zero doesn't do what FMS does (plays exactly that one still frame)
                        }
                        return false;
                    }
                }
            }
            
            if (_enhancedSeekTarget < 0)
            {
                if (_initialTime < 0)
                {
                    
                        _initialTime = (tag.timestamp / 1000.0) + _fileTimeAdjustment;
                    
                }
                
                if (_seekTime < 0)
                {
                    _seekTime = (tag.timestamp / 1000.0) + _fileTimeAdjustment;
                }
            }       
            else // doing enhanced seek
            {
                if (tag is FLVTagVideo)
                {   
                    if (_flvParserIsSegmentStart)   
                    {
                        var _muteTag:FLVTagVideo = new FLVTagVideo();
                        _muteTag.timestamp = tag.timestamp; // may get overwritten, ok
                        _muteTag.codecID = FLVTagVideo(tag).codecID; // same as in use
                        _muteTag.frameType = FLVTagVideo.FRAME_TYPE_INFO;
                        _muteTag.infoPacketValue = FLVTagVideo.INFO_PACKET_SEEK_START;
                        // and start saving, with this as the first...
                        _enhancedSeekTags = new Vector.<FLVTagVideo>();
                        _enhancedSeekTags.push(_muteTag);
                        _flvParserIsSegmentStart = false;
                    }   
                    
                    if ((tag.timestamp / 1000.0) + _fileTimeAdjustment >= _enhancedSeekTarget)
                    {
                        _enhancedSeekTarget = -1;
                        _seekTime = (tag.timestamp  / 1000.0) + _fileTimeAdjustment;
                        if(_initialTime < 0)
                        {
                            _initialTime = _seekTime;
                        }
                        
                        var _unmuteTag:FLVTagVideo = new FLVTagVideo();
                        _unmuteTag.timestamp = tag.timestamp;  // may get overwritten, ok
                        _unmuteTag.codecID = (_enhancedSeekTags[0]).codecID;    // take the codec ID of the corresponding SEEK_START
                        _unmuteTag.frameType = FLVTagVideo.FRAME_TYPE_INFO;
                        _unmuteTag.infoPacketValue = FLVTagVideo.INFO_PACKET_SEEK_END;
                        
                        _enhancedSeekTags.push(_unmuteTag); 
                        
                        // twiddle and dump
                        
                        for (i=0; i<_enhancedSeekTags.length; i++)
                        {
                            var vTag:FLVTagVideo;
                            
                            vTag = _enhancedSeekTags[i];
                            //vTag.timestamp = tag.timestamp;
                            if (vTag.codecID == FLVTagVideo.CODEC_ID_AVC && vTag.avcPacketType == FLVTagVideo.AVC_PACKET_TYPE_NALU)
                            {
                                // for H.264 we need to move the timestamp forward but the composition time offset backwards to compensate
                                var adjustment:int = tag.timestamp - vTag.timestamp; // how far we are adjusting
                                var compTime:int = vTag.avcCompositionTimeOffset;
                                compTime = vTag.avcCompositionTimeOffset;
                                compTime -= adjustment; // do the adjustment
                                vTag.avcCompositionTimeOffset = compTime;   // save adjustment
                                vTag.timestamp = tag.timestamp; // and adjust the timestamp forward
                            }
                            else
                            {
                                // the simple case
                                vTag.timestamp = tag.timestamp;
                            }
                            bytes = new ByteArray();
                            vTag.write(bytes);
                            _flvParserProcessed += bytes.length;
                            appendBytes(bytes);
                        }
                        _enhancedSeekTags = null;
                        
                        // and append this one
                        bytes = new ByteArray();
                        tag.write(bytes);
                        _flvParserProcessed += bytes.length;
                        appendBytes(bytes);
                        if (_playForDuration >= 0)
                        {
                            return true;    // need to continue seeing the tags, and can't shortcut because we're being dropped off mid-segment
                        }
                        _flvParserDone = true;
                        return false;   // and end of parsing (caller must dump rest, unparsed)
                        
                    } // past enhanced seek target
                    else
                    {
                        _enhancedSeekTags.push(tag);
                    }
                } // is video
                else if (tag is FLVTagScriptDataObject)
                {
                    // ScriptDataObject tags simply pass through with unadjusted timestamps rather than discarding or saving for later
                    bytes = new ByteArray();
                    tag.write(bytes);
                    _flvParserProcessed += bytes.length;
                    appendBytes(bytes);
                } // else tag is FLVTagAudio, which we discard, unless...           
                else if (tag is FLVTagAudio) 
                {
                    var aTag:FLVTagAudio = tag as FLVTagAudio;
                    if (aTag.isCodecConfiguration)  // need to pass this through? (ex. AAC AudioConfig message)
                    {
                        // yes, can never skip initialization...
                        bytes = new ByteArray();
                        tag.write(bytes);
                        _flvParserProcessed += bytes.length;
                        appendBytes(bytes);
                    }
                }
                
                return true;
            } // enhanced seek
            
            // finally, pass this one on to appendBytes...
            
            bytes = new ByteArray();
            tag.write(bytes);
            _flvParserProcessed += bytes.length;
            appendBytes(bytes);
            
            // probably done seeing the tags, unless we are in playForDuration mode...
            if (_playForDuration >= 0)
            {
                if (_segmentDuration >= 0 && _flvParserIsSegmentStart)
                {
                    // if the segmentDuration has been reported, it is possible that we might be able to shortcut
                    // but we need to be careful that this is the first tag of the segment, otherwise we don't know what duration means in relation to the tag timestamp
                    
                    _flvParserIsSegmentStart = false; // also used by enhanced seek, but not generally set/cleared for everyone. be careful.
                    currentTime = (tag.timestamp / 1000.0) + _fileTimeAdjustment;
                    if (currentTime + _segmentDuration >= (_initialTime + _playForDuration))
                    {
                        // it stops somewhere in this segment, so we need to keep seeing the tags
                        return true;
                    }
                    else
                    {
                        // stop is past the end of this segment, can shortcut and stop seeing tags
                        _flvParserDone = true;
                        return false;
                    }
                }
                else
                {
                    return true;    // need to continue seeing the tags because either we don't have duration, or started mid-segment so don't know what duration means
                }
            }
            // else not in playForDuration mode...
            _flvParserDone = true;
            return false;
        }
		
		override public function get time():Number {
			return _seekTime + super.time;	
		}
		
	}
}