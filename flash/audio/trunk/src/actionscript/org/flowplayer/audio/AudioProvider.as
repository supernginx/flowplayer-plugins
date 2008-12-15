/*     *    Copyright 2008 Anssi Piirainen * *    This file is part of FlowPlayer. * *    FlowPlayer is free software: you can redistribute it and/or modify *    it under the terms of the GNU General Public License as published by *    the Free Software Foundation, either version 3 of the License, or *    (at your option) any later version. * *    FlowPlayer is distributed in the hope that it will be useful, *    but WITHOUT ANY WARRANTY; without even the implied warranty of *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the *    GNU General Public License for more details. * *    You should have received a copy of the GNU General Public License *    along with FlowPlayer.  If not, see <http://www.gnu.org/licenses/>. */package org.flowplayer.audio {	import org.flowplayer.controller.StreamProvider;	import org.flowplayer.controller.VolumeController;	import org.flowplayer.model.Clip;	import org.flowplayer.model.ClipEvent;	import org.flowplayer.model.ClipEventType;	import org.flowplayer.model.Playlist;	import org.flowplayer.model.Plugin;	import org.flowplayer.model.PluginModel;	import org.flowplayer.util.Log;	import org.flowplayer.view.Flowplayer;		import flash.display.DisplayObject;	import flash.events.Event;	import flash.events.IOErrorEvent;	import flash.events.ProgressEvent;	import flash.events.TimerEvent;	import flash.media.Sound;	import flash.media.SoundChannel;	import flash.net.URLRequest;	import flash.system.Capabilities;	import flash.utils.Timer;		/**	 * @author api	 */	public class AudioProvider implements StreamProvider, Plugin {		private var log:Log = new Log(this);		private var _sound:Sound;		private var _playing:Boolean;		private var _paused:Boolean;		private var _durationSeconds:Number;		private var _clip:Clip;		private var _pausedPosition:Number;		private var _channel:SoundChannel;		private var _playlist:Playlist;		private var _progressTimer:Timer;		private var _seeking:Boolean;		private var _started:Boolean;		private var _volumeController:VolumeController;		private var _pauseAfterStart:Boolean;		public function stopBuffering():void {			_sound.close();			resetState();		}				public function stop(event:ClipEvent, closeStream:Boolean = false):void {			seek(null, 0);			_channel.stop();			if (closeStream) {				try {					_sound.close();				} catch (e:Error) {					// ignore				}			}			resetState();			if (event) {				_clip.dispatchEvent(event);			}		}				private function resetState():void {			_playing = false;			_paused = false;			_started = false;			_durationSeconds = 0;			_pausedPosition = 0;			if (_progressTimer) {				_progressTimer.stop();			}		}		public function attachStream(video:DisplayObject):void {		}				public function load(event:ClipEvent, clip:Clip, pauseAfterStart:Boolean = true):void {			log.debug("load()");			resetState();			if (_clip == clip) {				log.debug("reusing existing sound object");				addListeners(_sound);				play(0);				_clip.dispatch(ClipEventType.BEGIN);				_clip.dispatch(ClipEventType.START);							} else {				_clip = clip;				_sound = new Sound();				addListeners(_sound);				_sound.load(new URLRequest(clip.completeUrl));				play(0);			}			_pauseAfterStart = pauseAfterStart;		}				private function addListeners(sound:Sound):void {			sound.addEventListener(ProgressEvent.PROGRESS, onProgress);			sound.addEventListener(Event.SOUND_COMPLETE, onComplete);			sound.addEventListener(IOErrorEvent.IO_ERROR, onIoError);			sound.addEventListener(Event.ID3, onId3);			_progressTimer = new Timer(200);			_progressTimer.addEventListener(TimerEvent.TIMER, onProgressTimer);			_progressTimer.start();		}				private function onIoError(event:IOErrorEvent):void {			log.error("Unable to load audio file: " + event.text);			//dispatching this error causes crashes in Safari://			_clip.dispatch(ClipEventType.ERROR, "Unable to load audio file: " + event.text);		}		private function onId3(event:Event):void {			var metadata:Object = new Object();			for (var prop:String in _sound.id3) {				log.debug(prop + ": " + _sound.id3[prop]);				metadata[prop] = _sound.id3[prop];			}			if (_started) return;			_clip.metaData = metadata;			log.debug("dispatching START");			_clip.dispatch(ClipEventType.METADATA);			_clip.dispatch(ClipEventType.START);			_started = true;			if (_pauseAfterStart) {				pause(new ClipEvent(ClipEventType.PAUSE));			}		}		private function onProgress(event:ProgressEvent):void {			if (_playing) return;			_playing = true;			_clip.dispatch(ClipEventType.BEGIN);		}		private function onProgressTimer(event:TimerEvent):void {			log.debug("onProgressTimer");			estimateDuration();    		    		if (! _sound.bytesTotal > 0) return;    		if (! _sound.bytesLoaded > 0) return;			if(_sound.isBuffering == true && _sound.bytesTotal > _sound.bytesLoaded) {				_clip.dispatch(ClipEventType.BUFFER_EMPTY);			} else{				_clip.dispatch(ClipEventType.BUFFER_FULL);				_progressTimer.stop();			}		}				private function estimateDuration():void {    		var durationSecs:Number = (_sound.length/(_sound.bytesLoaded/_sound.bytesTotal))/1000;    		_clip.durationFromMetadata = durationSecs;		}		private function onComplete(event:Event):void {			// dispatch a before event because the finish has default behavior that can be prevented by listeners			_clip.dispatchBeforeEvent(new ClipEvent(ClipEventType.FINISH));			_progressTimer.stop();		}		public function getVideo(clip:Clip):DisplayObject {			return null;		}				public function resume(event:ClipEvent):void {			log.debug("resume");			_paused = false;			play(_pausedPosition);			if (event) {				_clip.dispatchEvent(event);			}		}				public function pause(event:ClipEvent):void {			log.debug("pause");			_paused = true;			_pausedPosition = _channel.position; 			_channel.stop();			if (event) {				_clip.dispatchEvent(event);			}		}		public function seek(event:ClipEvent, seconds:Number):void {			_channel.stop();			_seeking = true;			play(seconds * 1000);			if (event) {				_clip.dispatchEvent(event);			}			if (_paused) {				_pausedPosition = _channel.position; 				_channel.stop();			} 		}				private function play(posMillis:Number):void {			_channel = _sound.play(posMillis, 0);			_volumeController.soundChannel = _channel;		}		public function get stopping():Boolean {			return false;		}				public function get allowRandomSeek():Boolean {			return false;		}				public function get bufferStart():Number {			return 0;		}				public function get playlist():Playlist {			return _playlist;		}		public function get time():Number {			return _channel ? _channel.position / 1000 : 0;		}		public function get bufferEnd():Number {			return _sound && _clip ? _sound.bytesLoaded / _sound.bytesTotal * _clip.duration : 0;		}		public function get fileSize():Number {			return _sound ? _sound.bytesLoaded : 0;		}				public function set playlist(playlist:Playlist):void {			_playlist = playlist;		}				public function set netStreamClient(client:Object):void {		}				public function set volumeController(controller:VolumeController):void {			_volumeController = controller;		}				public function onConfig(model:PluginModel):void {			model.dispatchOnLoad();		}				public function getDefaultConfig():Object {			return null;		}				public function onLoad(player:Flowplayer):void {		}	}}