/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, Flowplayer Oy
 * Copyright (c) 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
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
