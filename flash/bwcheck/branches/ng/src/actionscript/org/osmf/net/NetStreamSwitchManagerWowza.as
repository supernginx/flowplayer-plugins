/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.osmf.net {
    import flash.net.NetConnection;
    import flash.net.NetStream;

    public class NetStreamSwitchManagerWowza extends NetStreamSwitchManager {
        public function NetStreamSwitchManagerWowza
                (connection:NetConnection
                        , netStream:NetStream
                        , resource:DynamicStreamingResource
                        , metrics:NetStreamMetricsBase
                        , switchingRules:Vector.<SwitchingRuleBase>) {
            super(connection, netStream, resource, metrics, switchingRules, onPlayStatusWowza);
        }

        private function onPlayStatusWowza(info:Object, info2:Object, info3:Object):void {
            CONFIG::LOGGING
            {
                debug("onPlayStatus() - " + info + ", " + info2 + ", " + info3);
                for (var prop:String in info3) {
                    debug(prop + ": " + info3[prop]);
                }
            }
            if (info3 && info3.code == "NetStream.Play.TransitionComplete") {
                transitionComplete();
            }
        }

   }
}