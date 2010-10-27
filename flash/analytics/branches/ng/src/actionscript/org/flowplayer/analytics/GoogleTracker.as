/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Richard Mueller  richard@3232design.com
 * Copyright (c) 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

/*
 This should work as a standalone plugin, but the whole point of this was to embed the player on
 external sites and track where, if possible, so I needed a fully-contained player with all options
 and plugins compiled in (except for clip URL, which is passed in separately).
 */


package org.flowplayer.analytics {
    import com.google.analytics.GATracker;
    import com.google.analytics.AnalyticsTracker;
    import com.google.analytics.debug.DebugConfiguration;

    import flash.external.ExternalInterface;

    import flash.ui.Keyboard;

    import org.flowplayer.model.*;

    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.StyleableSprite;

    public class GoogleTracker extends StyleableSprite implements Plugin {

        private var _model:PluginModel;
        private var _player:Flowplayer;
        private var _tracker:AnalyticsTracker;
        private var _trackingMode:String;			// Bridge or AS3 -- if you have ga.js on the page and a tracking object already, use 'Bridge', else 'AS3' and your google_id.
        private var _bridgeTrackerObject:String;
        private var _googleId:String;
        private var _mydebug:Boolean;
        private var _labels:Object;
        private var _embeddedURL:String;

        public function GoogleTracker() {             // constructor
        }

        public function getDefaultConfig():Object {
            return {
                "opacity": 0.0,
                "url": "flowplayer.GoogleTracker.swf",
                "trackingMode": "AS3",
                "bridgeObject": "",
                "googleId": "",
                "debug": false,
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

            if (! _model.config.trackingMode) {
                if (_model.config.googleId && _model.config.bridgeObject) {
                    _trackingMode = "Bridge";	// preference to bridge
                } else if (! _model.config.googleId && _model.config.bridgeObject) {
                    _trackingMode = "Bridge";
                } else {
                    _trackingMode = "AS3";
                }
            }

            if (_model.config.trackingMode == "Bridge") {
                _trackingMode = "Bridge";
                if (_model.config.bridgeObject) {
                    _bridgeTrackerObject = _model.config.bridgeObject;
                } else if (_model.config.googleId) {
                    _bridgeTrackerObject = _model.config.googleId;
                } else {
                    _bridgeTrackerObject = "window.pageTracker";
                }
            }

            _googleId = _model.config.googleId;
            _mydebug = _model.config.debug
            _player = player;						// get our local reference to the player

            // allow configuration of event labels
            _labels = new Object();
            for (var i:String in _model.config.labels) {
                _labels[i] = _model.config.labels[i];
            }

            _embeddedURL = getEmbeddedUrl();

            var createClipTracker:Function = function(eventName:String):Function {
                return function(event:ClipEvent):void {
                    if (_labels[eventName] != false) doTrackEvent(_labels[eventName], event.target as Clip);
                }
            }

            _player.playlist.onStart(createClipTracker("start"));
            _player.playlist.onBegin(createClipTracker("begin"));
            _player.playlist.onPause(createClipTracker("pause"));
            _player.playlist.onResume(createClipTracker("resume"));
            _player.playlist.onSeek(createClipTracker("seek"));
            _player.playlist.onStop(createClipTracker("stop"));
            _player.playlist.onFinish(createClipTracker("finish"));

            // now the player-level events

            var createPlayerTracker:Function = function(eventName:String):Function {
                return function(event:PlayerEvent):void {
                    if (_labels[eventName] != false) doTrackEvent(_labels[eventName]);
                }
            }

            _player.onMute(createPlayerTracker("mute"));
            _player.onUnmute(createPlayerTracker("unmute"));
            _player.onFullscreen(createPlayerTracker("fullscreen"));
            _player.onFullscreenExit(createPlayerTracker("fullscreenexit"));

        }

        public function getEmbeddedUrl():String {
            if (!ExternalInterface.available) return "Unknown";
            try {
                var href:String = ExternalInterface.call("self.location.href.toString");
                return "host: " + href;
            } catch (e:Error) {
                log.error("error in getEmbeddedUrl(): " + e);
            }
            return "Unknown";
        }

        // tracker instantiation.
        private function instantiateTracker():void {

            try {
                var _confdebug:DebugConfiguration = new DebugConfiguration();
                _confdebug.minimizedOnStart = true;

                if (_trackingMode == "Bridge") {
                    if (! ExternalInterface.available) {
                        _model.dispatchError(PluginError.ERROR, "Unable to create tracked in Bridge mode because ExternalInterface is not available");
                    }
                    log.debug("Creating tracker in Bridge mode using " + _bridgeTrackerObject + ", debug ? " + (_mydebug ? "true" : "false"));
                    _tracker = new GATracker(this, _bridgeTrackerObject, "Bridge", _mydebug);
                } else {
                    if (! _googleId) {
                        _model.dispatchError(PluginError.ERROR, "Google ID not specified");
                    }

                    log.debug("Creating tracker in AS3 mode using " + _googleId + ", debug ? " + (_mydebug ? "true" : "false"));
                    _tracker = new GATracker(this, _googleId, "AS3", _mydebug);
                    _tracker.debug.showHideKey = Keyboard.F6; // use the F6 key to toggle visual debug display
                }
            } catch(e:Error) {
                log.error("Unable to create tracker:", e.toString());
                log.error("Stack:", e.getStackTrace());
            }
        }


        // 			if the local server URL is unavailable, change the null to a prettier 'Unknown'
        //			Finally, send the time each event happened.
        private function doTrackEvent(eventName:String, clip:Clip = null):void {
            if (_tracker == null) {
                instantiateTracker();
            }
            if (clip == null)
                clip = _player.currentClip;

            try {
                log.debug("Tracking " + eventName + "[" + (clip.completeUrl + (clip.isInStream ? ": instream" : "")) + "] : " + (_player.status ? _player.status.time : 0) + " on page " + _embeddedURL);
                if (_tracker.isReady()) {
                    _tracker.trackEvent(_embeddedURL, eventName, clip.completeUrl + (clip.isInStream ? ": instream" : ""), int(_player.status ? _player.status.time : 0));
                }
            } catch (e:Error) {
                log.error("Got error while tracking event " + eventName);
            }
        }

        [External]
        public function trackEvent(eventName:String):void {
            doTrackEvent(eventName);
        }

        [External]
        public function setLabelName(sLabel:String, newName:String):void {
            _labels[sLabel] = newName == "false" ? false : newName;
        }


    }
}
