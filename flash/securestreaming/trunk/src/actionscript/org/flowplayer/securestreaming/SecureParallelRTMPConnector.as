/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 * Copyright (c) 2009 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.securestreaming {
	
    import org.flowplayer.controller.ParallelRTMPConnector;
    import flash.net.Responder;
	import com.meychi.ascrypt.TEA;
    import flash.events.NetStatusEvent;

    public class SecureParallelRTMPConnector extends ParallelRTMPConnector {
        
		private var _sharedSecret:String;

        public function SecureParallelRTMPConnector(url:String, sharedSecret:String, connectionClient:Object, onSuccess:Function, onFailure:Function) {
            super(url, connectionClient, onSuccess, onFailure);
			_sharedSecret = sharedSecret;
        }


        override protected function onConnectionStatus(event:NetStatusEvent):void {
            log.debug(this + "::onConnectionStatus() " + event.info.code);

            if (event.info.code == "NetConnection.Connect.Success") {
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
                    _connection.call("secureTokenResponse", new Responder(secureResult.onResult as Function), TEA.decrypt(event.info.secureToken, _sharedSecret));
                } else {
                    log.error("secure token was not received from the server");
                    handleError("secure token not received from server");
                }
			}
        }
		
		private function handleError(message:String):void {
            if (_failureListener != null) {
                var listener:Function = _failureListener;
                listener(message);
            }
        }
    }
}