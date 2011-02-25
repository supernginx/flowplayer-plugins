/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009-2011 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.slowmotion {
    import flash.events.NetStatusEvent;
    import flash.net.NetStream;

    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.controller.TimeProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.ClipEventType;
    import org.flowplayer.model.ClipType;
    import org.flowplayer.model.Playlist;
    import org.flowplayer.model.PluginEventType;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.slowmotion.SlowMotionInfo;
    import org.flowplayer.util.Log;

    public class SlowMotionTimeProvider implements TimeProvider {
        private var log:Log = new Log(this);
        private var _provider:StreamProvider;
        private var _info:SlowMotionInfo;
        private var _playlist:Playlist;
        private var _model:PluginModel;

        public function SlowMotionTimeProvider(model:PluginModel, provider:StreamProvider, providerName:String, playlist:Playlist) {
            _model = model;
            _provider = provider;
            _playlist = playlist;
            playlist.onStart(onStart, function(clip:Clip):Boolean { return clip.provider == providerName; });
			playlist.onStop(reset);
			playlist.onFinish(reset);
			playlist.onPlaylistReplace(reset);
        }

        public function getTime(netStream:NetStream):Number {
            var time:Number = _provider.netStream.time;
            if (! _info) return time;
            if (_info.isTrickPlay) {
                return _info.adjustedTime(time);
            }

            return time;
        }

        public function info():SlowMotionInfo {
            return _info;
        }

		private function reset(event:ClipEvent):void {
			_info = new SlowMotionInfo(_playlist.current, false, true, 0, 1);
		}

        private function onStart(event:ClipEvent):void {
            log.warn("onStart(), netStream: " + netStream);
			reset(event);
            netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
        }

        private function onNetStatus(infoObject:NetStatusEvent):void
        {
            log.debug("onNetStatus(): ");
            for (var propName:String in infoObject.info) {
                log.warn("  "+propName + " = " + infoObject.info[propName]);
            }

            // use the NetStream.Play.Start to get the current fast play settings
            if (infoObject.info.code == "NetStream.Play.Start") {
				log.debug("Got Start")
                if (infoObject.info.isFastPlay != undefined) {
					if ( infoObject.info.isFastPlay ) {
						_info = new SlowMotionInfo(_playlist.current, true, Number(infoObject.info.fastPlayDirection) > 0, infoObject.info.fastPlayOffset as Number, infoObject.info.fastPlayMultiplier as Number);
	                    log.debug("isFastPlay = true");
					}
					else {
						log.debug("isFastPlay = false");
						reset(null);
					}
                    
                }
 
                log.warn("dispatching PluginEvent 'onTrickPlay'");
                _model.dispatch(PluginEventType.PLUGIN_EVENT, "onTrickPlay", _info);
            }
        }

        private function get netStream():NetStream {
            return _provider.netStream;
        }
    }
}