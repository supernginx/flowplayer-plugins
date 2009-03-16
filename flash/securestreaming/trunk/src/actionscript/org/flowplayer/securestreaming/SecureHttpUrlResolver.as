/*
 *    Copyright 2009 Flowplayer Oy
 *
 *    author: Anssi Piirainen, api@iki.fi, Flowplayer Oy
 *
 *    This file is part of FlowPlayer.
 *
 *    FlowPlayer is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    FlowPlayer is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with FlowPlayer.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.flowplayer.securestreaming {
    import com.adobe.crypto.MD5;
import flash.events.NetStatusEvent;
    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.controller.ResourceLoader;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginError;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;

    public class SecureHttpUrlResolver implements ClipURLResolver {
        private var log:Log = new Log(this);
        private var _config:Config;
        private var _player:Flowplayer;
        private var _failureListener:Function;
        private static const SECRET:String = "sn983pjcnhupclavsnda";

        public function SecureHttpUrlResolver(player:Flowplayer, config:Config, failureListener:Function) {
            _player = player;
            _config = config;
            _failureListener = failureListener;
        }

        public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {
            if (_config.timestamp) {
                doResolve(buildClipUrl(_config.timestamp, clip), clip, successListener);
            } else {
                loadTimestampAndResolve(clip, successListener);
            }
        }

        private function loadTimestampAndResolve(clip:Clip, successListener:Function):void {
            log.debug("resolve, will load timestamp from url " + _config.timestampUrl);
            var loader:ResourceLoader = _player.createLoader();
            loader.load(_config.timestampUrl, function(loader:ResourceLoader):void {
                var url:String = buildClipUrl(stripLinebreaks(String(loader.getContent())), clip);
                doResolve(url, clip, successListener);
            }, true);
        }

        private function doResolve(url:String, clip:Clip, successListener:Function):void {
            log.debug("resolved url " + url);
            clip.resolvedUrl = url;
            if (! url) {
                if (_failureListener != null) {
                    _failureListener();
                }
                return;
            }
            successListener(clip);
        }

        private function stripLinebreaks(line:String):String {
            if (! line) return null;
            var tmp:Array = line.split("\n");
            line = tmp.join("");
            tmp = line.split("\r");
            line = tmp.join("");
            return line;
        }

        private function buildClipUrl(timestamp:String, clip:Clip):String {
            if (! timestamp) return null;

            var protection:String;

            if (URLUtil.isCompleteURLWithProtocol(clip.url)) {
                var parts:Array = URLUtil.baseUrlAndRest(clip.url);
                return URLUtil.appendToPath(URLUtil.appendToPath(parts[0], generateProtection(timestamp, parts[1])), parts[1]);
            }
            return URLUtil.appendToPath(generateProtection(timestamp, clip.url), clip.url);
        }

        private function generateProtection(timestamp:String, file:String):String {
            return MD5.hash(_config.token || SECRET + file + timestamp) + "/" + timestamp ;
        }

        public function set onFailure(listener:Function):void {
            _failureListener = listener;
        }

        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
            return true;
        }
    }
}