/*! 
 * ipad.js @VERSION. The Flowplayer API
 * 
 * Copyright 2010 Flowplayer Oy 
 * By Thomas Dubois <thomas@flowplayer.org>
 *
 * This file is part of Flowplayer.
 * 
 * Flowplayer is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Flowplayer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Flowplayer.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Date: @DATE
 * Revision: @REVISION 
 */


$f.addPlugin("ipad", function(options) {
console.log("ipad closure");
	var STATE_UNLOADED = -1;
	var STATE_LOADED    = 0;
	var STATE_UNSTARTED = 1;
	var STATE_BUFFERING = 2;
	var STATE_PLAYING   = 3;
	var STATE_PAUSED    = 4;
	var STATE_ENDED     = 5;

	var self = this;
	
	var currentVolume = 1;
	var onStartFired = false;
	var stopping = false;
	var playAfterSeek = false;
	
	var activeIndex = 0;
	var activePlaylist = [];
	var commonClip = {};
	
	var currentState = STATE_UNLOADED;
	var previousState= STATE_UNLOADED;
	
	var isiDevice = /iPad|iPhone/.test(navigator.userAgent);	
	
	function extend(to, from) {
		if (from) {
			for (key in from) {
				if (key) {
					if ( from[key] && typeof from[key] == "object" && from[key].length == undefined) {
						var cp = {};
						extend(cp, from[key]);
						to[key] = cp;
					} else {
						to[key] = from[key];
					}		
				} 
			}
		}
	}
	
	var opts = {
		simulateiDevice: false,
		controlsSizeRatio: 1.5,
		debug: false
	};
	
	extend(opts, options);
	
	if ( opts.simulateiDevice )
		isiDevice = true;
		

	// some util funcs
	function log() {
		if ( opts.log )
			console.log.apply(console, arguments);
//		document.querySelector('#logdiv').innerHTML = document.querySelector('#logdiv').innerHTML + "<br>" + [].splice.call(arguments,0).join(', ');
	}	
	
	function stateDescription(state) {
		switch(state) {
			case -1: return "UNLOADED";
			case  0: return "LOADED";
			case  1: return "UNSTARTED";
			case  2: return "BUFFERING";
			case  3: return "PLAYING";
			case  4: return "PAUSED";
			case  5: return "ENDED";
		}
		return "UNKOWN";
	}
	
	function actionAllowed(eventName) {
		return self._fireEvent("onBefore"+eventName) !== false;
	}
	
	function stopEvent(e) {
		e.stopPropagation();
		e.preventDefault();
		return false;
	}
	
	function setState(state) {
		previousState = currentState;
		currentState = state;
		
		log(stateDescription(state));
	}
	
	function resetState(video) {
		video.fp_stop();
		
		onStartFired = false;
		stopping 	 = false;
		playAfterSeek= false;
		// call twice so previous state is unstarted too
		setState(STATE_UNSTARTED);
		setState(STATE_UNSTARTED);
	}
	
	function replay(video) {
		resetState(video);
		playAfterSeek = true;
		video.fp_seek(0);
	}	
	
	function scaleVideo(video, clip) {
		
	}
		
	// internal func, maps flowplayer's API
	function addAPI(video) {
		video._setCommonClip = function(clip) {
			commonClip = clip;
		}
		
		video.fp_play = function(clip, inStream) {
			var url = null;
			var autoBuffering 	 = true;
			var autoPlay 		 = true;
			
			console.log("CALLING PLAY : ", clip);
			
			if ( inStream ) {
				console.log("ERROR: inStream clips not yet supported");
				return;
			}
			
			// we got a param :
			// array, index, clip obj, url
			if ( clip ) {
				
				// simply change the index
				if ( typeof clip == "number" ) {
					if ( activeIndex >= activePlaylist.length )
						return;
						
					activeIndex = clip;
					clip = activePlaylist[activeIndex];
				} else {
					// String
					if ( typeof clip == "string" ) {
						clip = {
							url: clip
						};
					}
					
					var extendedClip = {};
					extend(extendedClip, commonClip)
					extend(extendedClip, clip);
					
					clip = extendedClip;
					// replace playlist
					video.fp_setPlaylist(clip.length != undefined ? clip : [clip]);
				}
					
				if ( clip.ipadUrl )
					url = clip.ipadUrl;
				else if ( clip.url )
					url = clip.url;

                //use ipadBaseUrl if available
				if ( url && url.indexOf('://') == -1 && extendedClip.ipadBaseUrl )
                    url = extendedClip.ipadBaseUrl + '/' + url;
                else if ( url && url.indexOf('://') == -1 && extendedClip.baseUrl )
                    url = extendedClip.baseUrl + '/' + url;
					
				if ( clip.autoBuffering != undefined && clip.autoBuffering == false )
					autoBuffering = false;
					
				if ( clip.autoPlay == undefined || clip.autoPlay == true ) {
					autoBuffering = true;
					autoPlay = true;
				}
			} else {
				log("clip was not given, simply calling video.play, if not already buffering");
				
				// clip was not given, simply calling play
				if ( currentState != STATE_BUFFERING )
					video.play();
					
				return;
			}
			
			console.log("about to play "+ url, autoBuffering, autoPlay);
			
			// we have a new clip to play
			resetState(video);
			
			if ( url ) {
				log("Changing SRC attribute"+ url);
				video.setAttribute('src', url);
			}
				
			// autoBuffering is true or we just called play
			if ( autoBuffering ) {
				if ( ! actionAllowed('Begin') )
					return false;
				
				$f.fireEvent(self.id(), 'onBegin', activeIndex);
				
				video.load();
			}
		
			// auto
			if ( autoPlay ) {
				log("calling video.play()");	
				video.play();
			}
		}
		
		video.fp_pause = function() {
			console.log("pause called");
			
			if ( ! actionAllowed('Pause') )
				return false;
						
			video.pause();
		};
		
		video.fp_resume = function() {
			console.log("resume called");
			
			if ( ! actionAllowed('Resume') )
				return false;
			
			video.play();
		};
		
		video.fp_stop = function() {
			console.log("stop called");
			
			if ( ! actionAllowed('Stop') )
				return false;
			
			stopping = true;
			video.pause();
			try {
				video.currentTime = 0;
			} catch(ignored) {}
		};
		
		video.fp_seek = function(position) {
			console.log("seek called");
			
			if ( ! actionAllowed('Seek') )
				return false;
			
			var seconds = 0;
			var position = position + "";
			if ( position.charAt(position.length-1) == '%' ) {
				var percentage = parseInt(position.substr(0, position.length-1)) / 100;
				var duration = video.duration;
				
				seconds = duration * percentage;
			} else {
				seconds = position;
			}

			try {
				video.currentTime = seconds;
			} catch(e) {
				log.error("Wrong seek time");
			}
		};
		
		video.fp_getTime = function() {
		//	console.log("getTime called");
			return video.currentTime;
		};
		
		video.fp_mute = function() {
			console.log("mute called");
			
			if ( ! actionAllowed('Mute') )
				return false;
			
			currentVolume = video.volume;
			video.volume = 0;
		};
		
		video.fp_unmute = function() {
			if ( ! actionAllowed('Unmute') )
				return false;
			
			video.volume = currentVolume;
		};
		
		video.fp_getVolume = function() {
			return video.volume * 100;
		};
		
		video.fp_setVolume = function(volume) {
			if ( ! actionAllowed('Volume') )
				return false;
				
			video.volume = volume / 100;
		};
		
		video.fp_toggle = function() {
			console.log('toggle called');
			if ( self.getState() == STATE_ENDED ) {
				replay(video);
				return;
			}
			
			if ( video.paused )
				video.fp_play();
			else
				video.fp_pause();
		};
		
		video.fp_isPaused = function() {
			return video.paused;
		};
		
		video.fp_isPlaying = function() {
			return ! video.paused;
		};
		
		video.fp_getPlugin = function(name) {
			if ( name == 'canvas' || name == 'controls' ) {
				var config = self.getConfig();
				//console.log("looking for config for "+ name, config);
				
				return config['plugins'] && config['plugins'][name] ? config['plugins'][name] : null;
			}
			console.log("ERROR: no support for "+ name +" plugin on iDevices");
			return null;
		};
		/*
		video.fp_css = function(name, css) {
			if ( self.plugins[name] && self.plugins[name]._api && 
				 self.plugins[name]['_api'] && self.plugins[name]['_api']['css'] &&
				 self.plugins[name]['_api']['css'] instanceof Function )
				return self.plugins[name]['_api']['css']();
				
			return self;
		}*/
		
		video.fp_close = function() {
			// nothing to do
		};
		
		video.fp_getStatus = function() {
			var bufferStart = 0;
			var bufferEnd   = 0;
			
			try {
				bufferStart = video.buffered.start();
				bufferEnd   = video.buffered.end();
			} catch(ignored) {}
			
			return {
				bufferStart: bufferStart,
				bufferEnd:  bufferEnd,
				state: currentState,
				time: video.fp_getTime(),
				muted: video.muted,
				volume: video.fp_getVolume()
			};
		};
		
		video.fp_getState = function() {
			return currentState;
		};
		
		video.fp_startBuffering = function() {
			if ( currentState == STATE_UNSTARTED )
				video.load();
		};
		
		video.fp_setPlaylist = function(playlist) {
			console.log("Setting playlist");
			activeIndex = 0;
			activePlaylist = playlist;
			
			// keep flowplayer.js in sync
			$f.fireEvent(self.id(), 'onPlaylistReplace', playlist);
			
			//resetState(); /// ???
			//video.fp_play(playlist[0]);
		};
		
		video.fp_addClip = function(clip, index) {
			activePlaylist.splice(index, 0, clip);
			
			// keep flowplayer.js in sync
			$f.fireEvent(self.id(), 'onClipAdd', clip, index);
		};
		
		video.fp_updateClip = function(clip, index) {
			activePlaylist[index] = clip;
		};
		
		video.fp_getVersion = function() {
			return '3.2.3';
		}
		
		video.fp_isFullscreen = function() {
			return video.webkitDisplayingFullscreen;
		}
		
		video.fp_toggleFullscreen = function() {
			if ( video.fp_isFullscreen() )
				video.webkitExitFullscreen();
			else
				video.webkitEnterFullscreen();
		}
		
		// install all other core API with dummy function
		// core API methods
		$f.each(("isFullscreen,toggleFullscreen,stopBuffering,reset,playFeed,setKeyboardShortcutsEnabled,isKeyboardShortcutsEnabled,addCuepoints,css,animate,showPlugin,hidePlugin,togglePlugin,fadeTo,invoke,loadPlugin").split(","),		
			function() {		 
				var name = this;

				video["fp_"+name] = function() {
					console.log("ERROR: unsupported API on iDevices "+ name);
					return false;
				};			 
			}
		);	
	}
	
	
	
	
	
	
	
	// Internal func, maps Flowplayer's events
	function addListeners(video) {


		// Volume*,Mute*,Unmute*,PlaylistReplace,ClipAdd,Error"
		// Begin*,Start,Pause*,Resume*,Seek*,Stop*,Finish*,LastSecond,Update,BufferStop
						
		/* CLIP EVENTS MAPPING */
		/*
		var onBegin = function(e) {
			// we are not getting that one on the device ?
			fireOnBeginIfNeeded(e);
		};
		video.addEventListener('loadstart', onBegin);
		*/
		var onBufferEmpty = function(e) {		
			log("got onBufferEmpty event "+e.type)
			setState(STATE_BUFFERING);
			$f.fireEvent(self.id(), 'onBufferEmpty', activeIndex);	
		};
		video.addEventListener('emptied', onBufferEmpty);
		video.addEventListener('waiting', onBufferEmpty);
		
		var onBufferFull = function(e) {
			if ( previousState == STATE_UNSTARTED || previousState == STATE_BUFFERING )	{
				// wait for play event, nothing to do

			} else {
				console.log("Restoring old state "+ stateDescription(previousState));
				setState(previousState);
			}
			$f.fireEvent(self.id(), 'onBufferFull', activeIndex);
		};
		video.addEventListener('canplay', onBufferFull);
		video.addEventListener('canplaythrough', onBufferFull);
		
		var onMetaData = function(e) {
			// update clip
			activePlaylist[activeIndex].duration = video.duration;
			$f.fireEvent(self.id(), 'onMetaData', activeIndex, activePlaylist[activeIndex]);
		};
		video.addEventListener('loadedmetadata', onMetaData);
		video.addEventListener('durationchange', onMetaData);
		
		var onStart = function(e) {
			if ( currentState == STATE_PAUSED ) {
				if ( ! actionAllowed('Resume') ) {
					// user initiated resume
					console.log("Resume disallowed, pausing");
					video.fp_pause();
					return stopEvent(e);
				}
				
				$f.fireEvent(self.id(), 'onResume', activeIndex);
			}
			
			setState(STATE_PLAYING);
			
			if ( ! onStartFired ) {
				onStartFired = true;
				$f.fireEvent(self.id(), 'onStart', activeIndex);
			}	
		};
		video.addEventListener('playing', onStart);
		
		// TODO : test this :)
		var onFinish = function(e) {
			if ( ! actionAllowed('Finish') ) {
				if ( activePlaylist.length == 1 ) {
					//In the case of a single clip, the player will start from the beginning of the clip. 
					replay(video);
				} else if ( activeIndex != (activePlaylist.length -1) ) {
					// In the case of an ordinary clip in a playlist, the "Play again" button will appear. 
					// oops, we don't have any play again button yet :)
					// simply go to the beginning of the video
					video.fp_seek(0);
				} else {
					//In the case of the final clip in a playlist, the player will start from the beginning of the playlist. 
					video.fp_play(0);
				}
				
				return stopEvent(e);
			}	// action was canceled
			
			setState(STATE_ENDED);
			$f.fireEvent(self.id(), 'onFinish', activeIndex);
			
			if ( activePlaylist.length > 1 && activeIndex < (activePlaylist.length - 1) ) {
				// not the last clip in the playlist
				video.fp_play(activeIndex++);
			}
			
		};
		video.addEventListener('ended', onFinish);
		
		var onError = function(e) {
			setState(STATE_LOADED);
			$f.fireEvent(self.id(), 'onError', activeIndex, 200);
		};
		video.addEventListener('error', onError);

		var onPause = function(e) {
			console.log("got pause event from player");
			if ( stopping )
				return;
				
			if ( currentState == STATE_BUFFERING && previousState == STATE_UNSTARTED ) {
				log("forcing play");
				setTimeout(function() { video.play(); }, 0);
				return;// stopEvent(e);
			}	
				
			if ( ! actionAllowed('Pause') ) {
				// user initiated pause
				video.fp_resume();
				return stopEvent(e);
			}	
				
			setState(STATE_PAUSED);
			$f.fireEvent(self.id(), 'onPause', activeIndex);
		}
		video.addEventListener('pause', onPause);

		var onSeek = function(e) {
			$f.fireEvent(self.id(), 'onBeforeSeek', activeIndex);
		};
		video.addEventListener('seeking', onSeek);
		
		var onSeekDone = function(e) {
			if ( stopping ) {
				stopping = false;
				$f.fireEvent(self.id(), 'onStop', activeIndex);
			}
			else
				$f.fireEvent(self.id(), 'onSeek', activeIndex);
				
				
			console.log("seek done, currentState", stateDescription(currentState));
			
			if ( playAfterSeek ) {
				playAfterSeek = false;
				video.fp_play();
			} else if ( currentState != STATE_PLAYING )
				video.fp_pause();
		};
		video.addEventListener('seeked', onSeekDone);
		
		
		
		
		
		/* PLAYER EVENTS MAPPING */
		
		var onVolumeChange = function(e) {
			// add onBeforeQwe here
			$f.fireEvent(self.id(), 'onVolume', video.fp_getVolume());
		};
		video.addEventListener('volumechange', onVolumeChange);
	}

	// this is called only on iDevices
	function onPlayerLoaded() {
		//installControlbar();
	}
	
	
	function installControlbar() {
		// if we're on an iDevice, try to load the js controlbar if needed
		/*
		if ( self['controls'] == undefined )
			return;	// js controlbar not loaded
		
		var controlsConf = {};
		if ( self.getConfig() && self.getConfig()['plugins'] && self.getConfig()['plugins']['controls'] )  
			controlsConf = self.getConfig()['plugins']['controls'];

		var controlsRoot = document.createElement('div');
		
		// dynamically load js, css file according to swf url ?
		
		// something more smart here
		
		controlsRoot.style.position = "absolute";
		controlsRoot.style.bottom = 0;
		self.getParent().children[0].appendChild(controlsRoot);
		
		self.controls(controlsRoot, {heightRatio: opts.controlsSizeRatio  }, controlsConf);
		*/
	}
	



	// Here we are getting serious. If we're on an iDevice, we don't care about Flash embed.
	// replace it by ours so we can install a video html5 tag instead when FP's init will be called.
	if ( isiDevice ) {
		
		if ( ! window.flashembed.__replaced ) {
		
			var realFlashembed = window.flashembed;
			window.flashembed = function(root, opts, conf) {
				// DON'T, I mean, DON'T use self here as we are in a global func
						
				if (typeof root == 'string') {
					root = document.getElementById(root.replace("#", ""));
				}

				// not found
				if (!root) { return; }

				var style = window.getComputedStyle(root, null);
				var width = parseInt(style.width);
				var height= parseInt(style.height);

			//	console.log("installing video tag", opts, conf, root);
				var hasBuiltinControls = conf.config['plugins'] == undefined || (conf.config['plugins'] && conf.config['plugins']['controls'] && conf.config['plugins']['controls'] != null 
										&& self['controls'] == undefined);	// we make a careful use of "self", as we're looking in the prototype
		
		
				var rootStyle = 'position: relative; background: -webkit-gradient(linear, left top, left bottom, from(rgba(0, 0, 0, 0.5)), to(rgba(0, 0, 0, 0.7))); height:'+ height +'px; width: '+ width +'px; overflow: hidden; cursor: default; -webkit-user-drag: none;'; // scaling
				
				root.innerHTML =  '<div style="'+ rootStyle +'"><video '+ (hasBuiltinControls ? 'controls="controls" ' : '') +
				//	'src="'+ conf.config.clip.url +'" '+
				//	'width="100%"'+
				//	' height="100%"'+ 
					'id="' + opts.id + 
					'" name="' + opts.id + '" type="video/mp4" style="height: 100%; width: 100%; cursor: pointer; -webkit-user-drag: none;"></video></div>';
			
				var api = root.children[0].children[0];
			
				$f.fireEvent(conf.config.playerId, 'onLoad', 'player');	
			
				api._setCommonClip(conf.config.clip);
				api.fp_play(conf.config.clip);
			}
			flashembed.getVersion = realFlashembed.getVersion;
			flashembed.asString = realFlashembed.asString;
			flashembed.isSupported = realFlashembed.isSupported;
			flashembed.__replaced = true;
		}
		
		
		// hack so we get the onload event before everybody and we can set the api
		var __fireEvent = self._fireEvent;
		// only on iDevice, of course
		
		self._fireEvent = function(a) {
			if ( a[0] == 'onLoad' && a[1] == 'player' ) {
				var api = self.getParent().children[0].children[0];
				addAPI(api);
				addListeners(api);

				setState(STATE_LOADED);

				// we are loaded
				onPlayerLoaded();

				// fire onLoad on parent
				__fireEvent.apply(self, arguments);

				
				return;
			}

			__fireEvent.apply(self, arguments);
		}
		
	
		
	} // end of iDevice test

	// some chaining
	return self;
});
