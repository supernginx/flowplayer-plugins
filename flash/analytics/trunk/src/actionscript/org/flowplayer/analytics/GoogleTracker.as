
/*
This should work as a standalone plugin, but the whole point of this was to embed the player on 
external sites and track where, if possible, so I needed a fully-contained player with all options
and plugins compiled in (except for clip URL, which is passed in separately).
*/

 
package org.flowplayer.analytics {
	
	import flash.external.ExternalInterface;		// to determine the browser's URL
	
	import org.flowplayer.model.Plugin; 			// base flowplayer plugin imports
	import org.flowplayer.model.PluginModel;
	import org.flowplayer.view.Flowplayer;
	
	import org.flowplayer.view.StyleableSprite; 	// need StyleableSprite for debugging: GATracker requires a DisplayObject
	
	import org.flowplayer.model.ClipEvent; 			// for tracking the play, pause, stop events
	import org.flowplayer.model.PlayerEvent; 		// for tracking the play, pause, stop events
	import org.flowplayer.model.Clip;				// used to get the completeURL of the video clip
	
	import com.google.analytics.AnalyticsTracker;	// the base Google Analytics classes contained in analytics.swc from gaforflash.
	import com.google.analytics.GATracker;
	


	public class GoogleTracker extends StyleableSprite implements Plugin {
		
		private var _model:PluginModel;				// need this to interact with flowplayer
		private var _player:Flowplayer;				// this is the actual player object
		private var _tracker:GATracker;				// the actual tracker object
		private var _tracking_mode:String;			// Your Bridge or AS3 -- if you have ga.js on the page and a tracking object already, use 'Bridge', else 'AS3' and your google_id.
		private var _bridge_tracker_object:String;	// Your ga.js tracking object
		private var _google_id:String;				// Your Google id -- not necessary if using bridge mode
		private var _mydebug:Boolean;				// are we debugging?
		private var _embeddedURL:String;			// we'll store the URL of the page the movie is on, if AllowScriptAccess="always" -- otherwise, 'Unknown'.
		
		private var _labels:Object;

		public function GoogleTracker() { 			// constructor
			// Hey, this is empty!  Weird.
		}
		
		public function getDefaultConfig():Object {
			return { 
				"opacity": 0.0, 
				"url": "flowplayer.GoogleTracker.swf", 
				"tracking_mode": "AS3",
				"bridge_object": "", 
				"google_id": "", 
				"debug": true,
				"labels": {
					"start": "start",	
					"begin": "play",	
					"pause": "pause",	
					"resume": "resume",	
					"seek": "seek",	
					"stop": "stop",	
					"finish": "finish",	
					"mute": "mute",	
					"unmute": "unmute",	
					"fullscreen": "Full Screen",	
					"fullscreenexit": "Full Screen Exit"	
				}
			};
		} 
		
		public function onConfig(model:PluginModel):void {
			rootStyle = model.config;				// get outside variables from config
			_model = model;
		}
	
		public function onLoad(player:Flowplayer):void {
			_model.dispatchOnLoad();				// dispatch onLoad so that the player knows this plugin is initialized
			_tracking_mode = _model.config.tracking_mode;
			_bridge_tracker_object = _model.config.bridge_object;
			_google_id = _model.config.google_id;
			_mydebug = _model.config.debug
			_player = player;						// get our local reference to the player
			
			// allow configuration of event labels
			_labels = new Object();
			for (var i:String in _model.config.labels) {
				_labels[i] = _model.config.labels[i];	
			}
			
			
			// Set all the listeners for each action we want to track.
			// First, the clip-level events
			_player.playlist.onMetaData( function(event:ClipEvent):void {
				// this is stupid.  If tracker isn't yet instantiated, then tracker.isReady fails.  So, if tracker doesn't exist or if tracker isn't ready,  instantiate it.  WTF?
				try  {
					if (!_tracker.isReady()) {
						 instantiateTracker();
						}
					} catch(errObject:Error) {
						instantiateTracker();
				}
				// Get the one piece Google doesn't give us: on what webpage is the video showing?  Again, embed parameter AllowScriptAccess="always" -- so this doesn't work on MySpace.
				_embeddedURL = "host: " + ExternalInterface.call("window.location.href.toString");
			}); 
			_player.playlist.onStart( function(event:ClipEvent):void {
				if (_labels.start != false) doTrackEvent(_labels.start, event.target as Clip);
			});  
			_player.playlist.onBegin( function(event:ClipEvent):void {
				if (_player.status.time != 0) { // if you check exactly at 0, this will fire an error in IE8's Flash debugger, can't find a workaround so replay isn't tracked.
					if (_labels.begin != false) doTrackEvent(_labels.begin, event.target as Clip);
				}
			}); 
			_player.playlist.onPause( function(event:ClipEvent):void {
				if (_labels.pause != false) doTrackEvent(_labels.pause, event.target as Clip);
			}); 
			_player.playlist.onResume( function(event:ClipEvent):void {
				if (_labels.resume != false) doTrackEvent(_labels.resume, event.target as Clip);
			}); 
			_player.playlist.onSeek( function(event:ClipEvent):void {
				if (_labels.seek != false) doTrackEvent(_labels.seek, event.target as Clip);
			}); 
			_player.playlist.onStop( function(event:ClipEvent):void {
				if (_labels.stop != false) doTrackEvent(_labels.stop, event.target as Clip);
			}); 
			_player.playlist.onFinish( function(event:ClipEvent):void {
				if (_labels.finish != false) doTrackEvent(_labels.finish, event.target as Clip);
			}); 
			// now the player-level events
			_player.onMute( function():void {
				if (_labels.mute != false) doPlayerTrackEvent(_labels.mute);
			}); 
			_player.onUnmute( function():void {
				if (_labels.unmute != false) doPlayerTrackEvent(_labels.unmute);
			}); 
			_player.onFullscreen( function():void {
				if (_labels.fullscreen != false) doPlayerTrackEvent(_labels.fullscreen);
			}); 
			_player.onFullscreenExit( function():void {
				if (_labels.fullscreenexit != false) doPlayerTrackEvent(_labels.fullscreenexit);
			});  
 
		}
		
		// tracker instantiation.
		private function instantiateTracker():void {
			if (_tracking_mode == "Bridge") {
				// ExternalInterface.available = true;
				_tracker = new GATracker( this, _bridge_tracker_object, "Bridge", _mydebug);
			} else {
				_tracker = new GATracker( this, _google_id, "AS3", _mydebug);
			}
		}
		
			
		// 			if the local server URL is unavailable, change the null to a prettier 'Unknown'
		//			Finally, send the time each event happened.
		private function doTrackEvent(_eventLabel:String, _clip:Clip):void {
			if (_embeddedURL == null) {
				_embeddedURL = "Unknown";
			}
			_tracker.trackEvent(_embeddedURL, _eventLabel, _clip.completeUrl + (_clip.isInStream ? ": instream" : ""), _player.status.time);
		}
		private function doPlayerTrackEvent(_eventLabel:String):void {
			if (_embeddedURL == null) {
				_embeddedURL = "Unknown";
			}
			_tracker.trackEvent(_embeddedURL, _eventLabel, _player.playlist.getClip(0).completeUrl, _player.status.time);
		}
	
		[External]
		public function trackEvent(_eventLabel:String):void {
			doPlayerTrackEvent(_eventLabel);
		}
		
		[External]
		public function setLabelName(sLabel:String, newName:String):void {
			_labels[sLabel] = newName == "false" ? false : newName;
		}
				
	
	}
}
