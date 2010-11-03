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

    import flash.display.Sprite;
    import flash.external.ExternalInterface;

    import flash.ui.Keyboard;

    import org.flowplayer.model.*;

    import org.flowplayer.util.Log;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.StyleableSprite;

    public class GoogleTracker extends Sprite implements Plugin {
        private var log:Log = new Log(this);
        private var _model:PluginModel;
        private var _player:Flowplayer;
        private var _config:Config;
        private var _tracker:AnalyticsTracker;

        public function onConfig(model:PluginModel):void {
            _model = model;
            _config = Config(new PropertyBinder(new Config()).copyProperties(model.config));
        }

        public function onLoad(player:Flowplayer):void {
            _player = player;
            var events:Events = _config.events;
            createClipEventTracker(_player.playlist.onStart, events.start, true);
            createClipEventTracker(_player.playlist.onStop, events.stop, true);
            createClipEventTracker(_player.playlist.onFinish, events.finish, true);
            createClipEventTracker(_player.playlist.onPause, events.pause, events.trackPause);
            createClipEventTracker(_player.playlist.onResume, events.resume, events.trackResume);
            createClipEventTracker(_player.playlist.onSeek, events.seek, events.trackSeek);

            createPlayerEventTracker(_player.onMute, events.mute, events.trackMute);
            createPlayerEventTracker(_player.onUnmute, events.unmute, events.trackUnmute);
            createPlayerEventTracker(_player.onFullscreen, events.fullscreen, events.trackFullscreen);
            createPlayerEventTracker(_player.onFullscreenExit, events.fullscreenExit, events.trackFullscreenExit);

            // track unload if the clip is playing or paused. If it's stopped or finished, the Stop event has already
            // been tracked or the playback has not started at all.
            createPlayerEventTracker(_player.onUnload, events.unload, true, function():Boolean { return _player.isPlaying() ||  _player.isPaused() });

            _model.dispatchOnLoad();
        }

        private function createClipEventTracker(eventBinder:Function, eventName:String, doTrack:Boolean):void {
            if (! doTrack) return;
            eventBinder(function(event:ClipEvent):void {
                doTrackEvent(eventName, event.target as Clip);
            });
        }

        private function createPlayerEventTracker(eventBinder:Function, eventName:String, doTrack:Boolean, extraCheck:Function = null):void {
            if (!doTrack) return;
            eventBinder(function(event:PlayerEvent):void {
                if (extraCheck != null) {
                    if (! extraCheck()) {
                        // extra check returns false --> don't track
                        return;
                    }
                }
                doTrackEvent(eventName);
            });
        }

        public function getCategory():String {
            var clipCategory:String = String(_player.playlist.current.getCustomProperty("eventCategory"));
            if (clipCategory) return clipCategory;

            var pageUrl:String = URLUtil.pageUrl;
            if (pageUrl) return pageUrl;

            _model.dispatchError(PluginError.ERROR, "Unable to get page URL to be used as google analytics event gategory. Specify this in the analytics plugin config.");
            return "Unknown";
        }

        private function instantiateTracker():void {
            try {
                var _confdebug:DebugConfiguration = new DebugConfiguration();
                _confdebug.minimizedOnStart = true;

                if (_config.mode == "Bridge") {
                    if (! ExternalInterface.available) {
                        _model.dispatchError(PluginError.ERROR, "Unable to create tracker in Bridge mode because ExternalInterface is not available");
                        return;
                    }
                    log.debug("Creating tracker in Bridge mode using " + _config.bridgeObject + ", debug ? " + _config.debug);
                    _tracker = new GATracker(this, _config.bridgeObject, "Bridge", _config.debug);
                    return;
                }

                if (! _config.accountId) {
                    _model.dispatchError(PluginError.ERROR, "Google Analytics account ID not specified. Look it up in your Analytics account, the format is 'UA-XXXXXX-N'");
                    return;
                }

                log.debug("Creating tracker in AS3 mode using " + _config.accountId + ", debug ? " + _config.debug);
                _tracker = new GATracker(this, _config.accountId, "AS3", _config.debug);
                _tracker.debug.showHideKey = Keyboard.F6; // use the F6 key to toggle visual debug display

            } catch(e:Error) {
                _model.dispatchError(PluginError.ERROR, "Unable to create tracker: " + e);
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
                log.debug("Tracking " + eventName + "[" + (clip.completeUrl + (clip.isInStream ? ": instream" : "")) + "] : " + (_player.status ? _player.status.time : 0) + " on page " + getCategory());
                if (_tracker.isReady()) {
                    _tracker.trackEvent(getCategory(), eventName, clip.completeUrl + (clip.isInStream ? ": instream" : ""), int(_player.status ? _player.status.time : 0));
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
        public function setEventName(oldName:String, newName:Object):void {
            var newProp:Object = {};
            newProp[oldName] = newName == "false" ? null : newName;
            log.debug("setEventName()", newProp);
            new PropertyBinder(_config.events).copyProperties(newProp, true);
        }

        [External(convert="true")]
        public function get config():Config {
            return _config;
        }

        public function getDefaultConfig():Object {
            return null;
        }

    }
}
