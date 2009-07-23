/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>, Anssi Piirainen Flowplayer Oy
 * Copyright (c) 2009 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.bwcheck
{
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.NetStream;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.util.Log;
	
	import org.flowplayer.bwcheck.event.DynamicStreamEvent;
	
	[Event(name=DynamicStreamEvent.SWITCH_STREAM, type="org.flowplayer.bwcheck.event.DynamicStreamEvent")]
	
	public class DynamicStream extends EventDispatcher
	{
		private var _config:BWConfig;
		private var _bitrates:Array;
		private var _netStream:NetStream;
		private var _bitrateProfile:SharedObject = SharedObject.getLocal("bitrateProfile","/");
		private var log:Log = new Log(this);
		
		private var _maxRate:Number = 0;
		private var _maxBandwidth:Number = 0;
		private var _curStreamID:int = 0;
		private var _prevStreamID:int = 0;
		private var _curBufferTime:uint = 0;
		private var _previousDroppedFrames:uint = 0;
		private var _previousDroppedFramesTime:uint = 0;
		private var _bufferMode:int = 0;
		private var _isBuffering:Boolean;
		private var _reachedBufferTime:Boolean = false;
		private var _switchMode:Boolean = false;		
		private var _preferredBufferLength:Number;
		private var _startBufferLength:Number;
		private var _aggressiveModeBufferLength:Number;
		private var _switchQOSTimerDelay:Number;
		private var _manualSwitchMode:Boolean;
		private var _droppedFramesLockRate:int; // rate that drops frames in excess of 25%
		private var _droppedFramesLockDelay:int;		
		private var _liveStream:Boolean;
		private var _liveBWErrorCount:int = 0;
		private var _previousMaxBandwidth:Number = 0;
		private var qosTimer:Timer;
		private var mainTimer:Timer;
		private var droppedFramesTimer:Timer; // lock delay for dropped frames so it doesn't upswitch again
		private var bandwidthlimit:int = -1;
		
		public function DynamicStream(config:BWConfig)
		{
			_config = config;
			_bitrates = _config.bitrates;
		}
		
		public function set netStream(netStream:NetStream):void
		{
			_netStream = netStream;
		}

        public function get currentStreamBitRate():Number {
            return _bitrates[_curStreamID];
        }

		protected function setup():void
		{
			_preferredBufferLength = _config.preferredBufferLength;
			_switchQOSTimerDelay = _config.switchQOSTimerDelay;
			_aggressiveModeBufferLength = _config.aggressiveModeBufferLength;
			_startBufferLength = _config.startBufferLength;
			_droppedFramesLockRate = _config.droppedFramesLockRate;
		
			//_maxRate = 500000; ///Assuming max stream rate to be 500000 bytes/sec
			
			_maxRate = Math.max(_maxRate,_config.bitrates[_config.bitrates.length - 1] * 1024/8);
			
			_manualSwitchMode = false;
			_maxBandwidth = _bitrateProfile.data.maxBandwidth;
			
			_curBufferTime = _startBufferLength;

            createQosTimer();

			mainTimer = new Timer(_config.monitorQOSTimerDelay *1000, 0);
			mainTimer.addEventListener(TimerEvent.TIMER, monitorQOS);


            droppedFramesTimer = new Timer(_config.droppedFramesTimerDelay *1000, 0);
            droppedFramesTimer.addEventListener(TimerEvent.TIMER, releaseDFLock);
            mainTimer.start();
        }

        private function createQosTimer():void {
            if (qosTimer) return;
            qosTimer  = new Timer(_config.switchQOSTimerDelay*1000, 0);
            qosTimer.addEventListener(TimerEvent.TIMER, getQOSAndSwitch);
        }
		
		private function init():void
		{
			log.debug("initializing ...");
			
			_previousDroppedFrames = _netStream.info.droppedFrames;
			_previousDroppedFramesTime = getTimer();
			_isBuffering = true;
			_reachedBufferTime = false;
		}
		
		private function getMaxBandwidth():void {
			if (bandwidthlimit>-1) {
				var maxbw:Number =  _netStream.info.maxBytesPerSecond*8/1024;			
				if (bandwidthlimit>maxbw) _maxBandwidth = maxbw; else _maxBandwidth =  bandwidthlimit;	
			}
			else {
				 _maxBandwidth =  _netStream.info.maxBytesPerSecond*8/1024;		
			}
		}
		
		private function getQOSAndSwitch(te:TimerEvent):void {
			if(_config.liveStream)
				checkLiveQOSAndSwitch();
			else
				checkVodQOSAndSwitch();
			///writing out the max bandwidth value for future sessions
			_bitrateProfile.data.maxBandwidth = _maxBandwidth;
		}

        // TODO: this function needs refactoring, nobody can understand this
		private function checkLiveQOSAndSwitch():void {

			log.debug(_preferredBufferLength + "-" + int(_netStream.bufferLength) + " *-1: " + _maxBandwidth); 

			log.debug("max bw: "+_maxBandwidth+" cur bitrate: " + this.currentStreamBitRate + " buffer: "+_netStream.bufferLength+ "	fps: "+_netStream.currentFPS);

			if(qosTimer.currentCount <= 2) //for the first couple of timer events there is not enough data with fps to make a switching decision.
				return;

			if( (_maxBandwidth < _bitrates[_curStreamID].rate) && (_liveBWErrorCount < _config.liveErrorCorrectionLimit) ) {
				_maxBandwidth = _previousMaxBandwidth;
				_liveBWErrorCount++;
			} else {
				_liveBWErrorCount = 0;
				_previousMaxBandwidth = _maxBandwidth;
			}

			log.debug("*-* *-2: " + _maxBandwidth);

			//downscale
			var nowTime:int = getTimer();
			
			if( (_netStream.bufferLength < _preferredBufferLength/2)|| ((_maxBandwidth < _bitrates[_curStreamID]) && (_maxBandwidth != 0)) 

				|| ((_netStream.info.droppedFrames - _previousDroppedFrames)*1000/(nowTime - _previousDroppedFramesTime) > _netStream.currentFPS*0.25)) {

				var nextStreamID:uint = 0;

				if(_netStream.bufferLength < _preferredBufferLength/2) {

					if(_netStream.bufferLength < _preferredBufferLength/2)
						nextStreamID = _curStreamID-1;
					else if(_netStream.bufferLength <= _preferredBufferLength /3)
						nextStreamID = 0;

					if(nextStreamID < 0)
						nextStreamID = 0;
						
					log.debug("Switching down because of buffer");

				} else if(_maxBandwidth < _bitrates[_curStreamID]) {
					
					var i:int = _bitrates.length - 1;
					while(i >= 0) {
						if(_maxBandwidth > _bitrates[i]) {
							nextStreamID = i;
							break;
						}
						i--;
					}


					if( nextStreamID < _curStreamID) {
						log.debug(int(_maxBandwidth) + " - Switching down because of maxBitrate lower than current stream bitrate");
					}
				} else {
					log.debug("Switching down because of dropped fps "+(_netStream.info.droppedFrames - _previousDroppedFrames)*1000/(nowTime - _previousDroppedFramesTime)+ " is greather than 0.25 of fps: "+ _netStream.currentFPS*0.25);
					// init lock timer and flag lock rate

					_droppedFramesLockRate = _bitrates[_curStreamID];

					if((droppedFramesTimer.currentCount < _config.droppedFramesLockLimit)  && !droppedFramesTimer.running) {
						droppedFramesTimer.start();
						log.debug("Activating lock to prevent switching to " + _droppedFramesLockRate + " | Offense Number " + droppedFramesTimer.currentCount);
					}	
					nextStreamID = _curStreamID -1;
				}
				
				if(nextStreamID > 0) {
	 				if(_bitrates[nextStreamID] >= _droppedFramesLockRate) {
						log.debug("next rate: "+_bitrates[nextStreamID]+" lock rate: "+_droppedFramesLockRate);
						return;
					}
				}					

				if(_curStreamID != nextStreamID) {
					switchStream(nextStreamID);
				}
					
				_previousDroppedFrames = _netStream.info.droppedFrames;
				_previousDroppedFramesTime = getTimer();
			} else {
				SwitchUpOnMaxBandwidth();		
			}
		}

        // TODO: this function needs refactoring, nobody can understand this
		private function checkVodQOSAndSwitch():void {


			log.debug("getQOSAndSwitch called");
			log.debug("max bw: "+_maxBandwidth+" cur bitrate: " + this.currentStreamBitRate + " buffer: "+_netStream.bufferLength+ "fps: "+_netStream.currentFPS);

			///writing out the max bandwidth value for future sessions
			_bitrateProfile.data.maxBandwidth = _maxBandwidth;

			//downscale
			var nowTime:int = getTimer();
	
			if( (_netStream.bufferLength < _preferredBufferLength)|| ((_maxBandwidth < _bitrates[_curStreamID]) && (_maxBandwidth != 0)) 
				|| ((_netStream.info.droppedFrames - _previousDroppedFrames)*1000/(nowTime - _previousDroppedFramesTime) > _netStream.currentFPS*0.25)) {
					
				
				var nextStreamID:int = 0;
				
				if(_netStream.bufferLength < _preferredBufferLength || (_maxBandwidth < _bitrates[_curStreamID])) {
					var i:int = _bitrates.length - 1;
					
					while(i >= 0) {
						if(_maxBandwidth > _bitrates[i]) {
							nextStreamID = i;
							break;
						}	
				 		i--;
					}

					if( nextStreamID < _curStreamID) {
						if(_maxBandwidth < _bitrates[_curStreamID]) {
							log.debug("Switching down because of maxBitrate lower than current stream bitrate");
						} else if(_netStream.bufferLength < _curBufferTime) {
							log.debug("Switching down because of buffer");
						}
					}

					if(_netStream.bufferLength > _curBufferTime && _curBufferTime != _preferredBufferLength) 
					{
						_curBufferTime =  _preferredBufferLength;
						log.debug("setting buffer time to "+_curBufferTime);
						_netStream.bufferTime = _curBufferTime;
					}
				} else {
					log.debug("Switching down because of dropped fps "+(_netStream.info.droppedFrames - _previousDroppedFrames)*1000/(nowTime - _previousDroppedFramesTime)+ " is greather than 0.25 of fps: "+ _netStream.currentFPS*0.25);
					// init lock timer and flag lock rate
					_droppedFramesLockRate = _bitrates[_curStreamID];
					
					if((droppedFramesTimer.currentCount < _config.droppedFramesLockLimit)  && !droppedFramesTimer.running) {
						droppedFramesTimer.start();
						log.debug("Activating lock to prevent switching to " + _droppedFramesLockRate + " | Offense Number " + droppedFramesTimer.currentCount);
					}
					nextStreamID = _curStreamID -1;
				}

				///aggressively go down to the latest bit rate if the buffer is below the half mark of the expected buffer length
				if(_netStream.bufferLength < _aggressiveModeBufferLength && _reachedBufferTime) {
						log.debug("switching to the aggressive mode");
						nextStreamID = 0;
						///check more frequently
						qosTimer.delay = _switchQOSTimerDelay*1000/2;									
				} 	

				if(nextStreamID > 0) {
	 				if(_bitrates[nextStreamID] >= _droppedFramesLockRate) {
						return;
					}
				}
					
				if(_curStreamID != nextStreamID) {
					switchStream(nextStreamID);
				}
				_previousDroppedFrames = _netStream.info.droppedFrames;
				_previousDroppedFramesTime = getTimer();				
			} else {
				SwitchUpOnMaxBandwidth();
				///also reverting QOS interval
				if(qosTimer.delay != _switchQOSTimerDelay*1000) {
					qosTimer.delay = _switchQOSTimerDelay*1000;
				}
			}
		}


		
		private function releaseDFLock(te:TimerEvent):void {
			_droppedFramesLockRate = int.MAX_VALUE;
			droppedFramesTimer.stop();
		}
		
		private function SwitchUpOnMaxBandwidth():void {

			var nowTime:int = getTimer();
			log.debug("switch up current max bandwidth: "+_maxBandwidth);

			var droppedFrames:int = _netStream.info.droppedFrames;
			var nextStreamID:int = 0;
			var i:int = _bitrates.length - 1;
			
			while(i >= 0) {
				if(_maxBandwidth > _bitrates[i]) {
					nextStreamID = i;
					break;
				}
				i--;
			}

			if( nextStreamID < _curStreamID) {
				//we are testing if we can switch up here... so dont go down
				nextStreamID = _curStreamID;
			}  else if (nextStreamID > _curStreamID) {
				///go up only if the buffer length looks good
				if(_netStream.bufferLength < _curBufferTime) {
					nextStreamID = _curStreamID;
				}
			}
			
			//regardless of bandwidth if the dropped frame count is higher than 25% of fps
			//then switch to lower bitrate
			/*

			///Shouldnt need this here.. should be caught earlier in qosAndSwitch
			if(_curStreamID > 0 && ((droppedFrames - _previousDroppedFrames)*1000/(nowTime - _previousDroppedFramesTime) > this.currentFPS*0.25)) {
				nextStreamID = _curStreamID-1;
				debug("switching down because of dropped frames");
				// init lock timer and flag lock rate
				_droppedFramesLockRate = dsPlayList[dsPlayIndex].streams[_curStreamID].rate;
				if((droppedFramesTimer.currentCount < DROPPED_FRAMES_LOCK_LIMIT)  && !droppedFramesTimer.running) {
					droppedFramesTimer.start();
					debug("Activating lock to prevent switching to " + _droppedFramesLockRate + " | Offense Number " + droppedFramesTimer.currentCount);
				}					

			}
			*/

		
			if(nextStreamID > (_bitrates.length - 1)) {
				nextStreamID = _bitrates.length - 1;
			}

			//this looks like its suppose to set a limit for a bitrate ? 
			if(nextStreamID > 0) {
				if(_bitrates[nextStreamID] >= _droppedFramesLockRate) {
					return;
				}
			}

			if(_curStreamID != nextStreamID) {
				switchStream(nextStreamID);
			} 

			if(_curBufferTime != _preferredBufferLength) 
			{
				_curBufferTime =  _preferredBufferLength;
				log.debug("setting buffer time to "+_curBufferTime);
				_netStream.bufferTime = _curBufferTime;
			}
		}
		
		/**
		 * Switches the stream in the native playlist 
		 * @param streamID
		 * @private
		 */		

		private function switchStream(streamID:Number = 0): void {
			if(streamID < 0)
				streamID = 0;

			if(streamID > _config.bitrates.length -1)
				streamID = _config.bitrates.length -1;

			if(streamID == _curStreamID)
				return;
				
			if(_switchMode == true) //dont send another transition if the previous 
				return;			   //one is in process already

			_prevStreamID = _curStreamID;
			_curStreamID = streamID;
			
			var obj:Object = {
				streamID: streamID
			};
			
			dispatch(obj, DynamicStreamEvent.SWITCH_STREAM);
			
			_switchMode = true;
		}
		
		protected function dispatch(info:Object, eventName:String):void
		{
			var event:DynamicStreamEvent = new DynamicStreamEvent(eventName);
			event.info = info;
            log.debug("dispatching dynamic stream event with info obj ", info);
			dispatchEvent(event);
		}
		
		private function monitorQOS(te:TimerEvent):void {

			var curTime:Number = _netStream.time;		

			if(_netStream.time == 0)
				return;
				
			if (_isBuffering) return;

			if(_netStream.bufferLength >= _preferredBufferLength)
				_reachedBufferTime = true;
				
			getMaxBandwidth();
			
//			log.debug("max bw: "+_maxBandwidth);
		}
		
		public function stop():void
		{
			log.info("no more QOS check");
			mainTimer.stop();
			qosTimer.stop();	
		}
		
		
		public function onStart(event:ClipEvent):void
		{
            log.debug("onStart()");
			setup();
			init();
		}
		
		public function onStop(event:ClipEvent):void
		{
			_switchMode = false;					
			stop();
		}
		
		public function onBufferEmpty(event:ClipEvent):void
		{
            log.debug("onBufferEmpty()");
			_curStreamID = 0;

			if(!_config.liveStream) {
				_curBufferTime = _config.emptyBufferLength;
				_netStream.bufferTime = _curBufferTime;
			}

			switchStream();
			qosTimer.stop();
			init();			
		}
		
		public function onBufferFull(event:ClipEvent):void
		{
            log.debug("onBufferFull()");
			getMaxBandwidth();
			SwitchUpOnMaxBandwidth();
			_isBuffering = false;
            createQosTimer();
			qosTimer.start();
		}
		
		public function onPause(event:ClipEvent):void
		{
			if(qosTimer.running){ qosTimer.stop(); }
			if(mainTimer.running){ mainTimer.stop(); }
		}
		
		public function onResume(event:ClipEvent):void
		{
			if(!qosTimer.running){ qosTimer.start(); }
			if(!mainTimer.running){ mainTimer.start(); }
		}
		
		public function onSeek(event:ClipEvent):void
		{
			if(!_config.liveStream) {
				_curBufferTime = _startBufferLength;
				_netStream.bufferTime = _curBufferTime;											
			}
			
			_isBuffering = true;
			_reachedBufferTime = false;
		}
		
		public function onError(event:ClipEvent):void
		{
			switch (event.info2)
			{
				case 200:
					_curStreamID = _prevStreamID;
					_switchMode = false;
				break;
			}
		}

	}
}