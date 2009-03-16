/*    
 *    Copyright 2008, 2009 Flowplayer Oy
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
    import com.meychi.ascrypt.TEA;

    import flash.events.NetStatusEvent;
    import flash.net.NetConnection;
    import flash.net.Responder;

    import org.flowplayer.controller.DefaultRTMPConnectionProvider;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;

    /**
	 * @author api
	 */
	internal class SecureRTMPConnectionProvider extends DefaultRTMPConnectionProvider {

        private var _onSuccess:Function;
        private var _sharedSecret:String;

        public function SecureRTMPConnectionProvider(sharedSecret:String) {
            _sharedSecret = sharedSecret;
        }

        override public function connect(provider:StreamProvider, clip:Clip, successListener:Function, objectEncoding:uint, ...rest):void {
            log.debug("connect");
            super.connect(provider, clip, successListener, objectEncoding, rest);
        }

        override protected function onConnectionStatus(event:NetStatusEvent):void {
            log.debug("received connection status " + event.info.code);
            if (event.info.code == "NetConnection.Connect.Success")
            {
                if (event.info.secureToken != undefined) {
                    log.debug("received secure token");
                    var secureResult:Object = new Object();
                    secureResult.onResult = function(isSuccessful:Boolean):void {
                        log.info("secureTokenResponse: " + isSuccessful);
                        if (! isSuccessful) {
                            log.error("secure token not accepted.");
                            handleError("secure token was not accepted by the server");
                        }
                    };
                    connection.call("secureTokenResponse", new Responder(secureResult.onResult as Function), TEA.decrypt(event.info.secureToken, _sharedSecret));
                } else {
                    log.error("secure token was not received from the server");
                    handleError("secure token not received from server");
                }
            }
        }

        private function handleError(message:String):void {
            if (failureListener != null) {
                var listener:Function = failureListener;
                listener(message);
            }
        }

        override protected function getNetConnectionUrl(clip:Clip):String {
            if (isRtmpUrl(clip.completeUrl)) {
                var url:String = clip.completeUrl;
                var lastSlashPos:Number = url.lastIndexOf("/");
                return url.substring(0, lastSlashPos);
            }
            if (clip.customProperties && clip.customProperties.netConnectionUrl) {
                return clip.customProperties.netConnectionUrl;
            }
            return provider.model.config.netConnectionUrl;
        }

        public static function isRtmpUrl(url:String):Boolean {
            return url && url.toLowerCase().indexOf("rtmp") == 0;
        }
	}
}
