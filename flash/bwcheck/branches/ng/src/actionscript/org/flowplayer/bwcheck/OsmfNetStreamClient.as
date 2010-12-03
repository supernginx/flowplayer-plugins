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
package org.flowplayer.bwcheck {
    import org.flowplayer.controller.NetStreamCallbacks;
    import org.flowplayer.controller.NetStreamClient;
    import org.flowplayer.util.Log;
    import org.osmf.net.NetClient;
    import org.osmf.net.NetStreamCodes;

    /**
     * A OSMF and Flowplayer compatible NetStream client.
     */
    public class OsmfNetStreamClient extends NetClient implements NetStreamCallbacks {
        protected var log:Log = new Log(this);
        private var _fpClient:NetStreamClient;
        private var _onTransitionComplete:Function;

        public function OsmfNetStreamClient(flowplayerNetStreamClient:NetStreamClient) {
            _fpClient = flowplayerNetStreamClient;
            addHandler(NetStreamCodes.ON_PLAY_STATUS, playStatusHandler);
        }

        public function onMetaData(infoObject:Object):void {
            log.debug("onMetaData", infoObject);
            _fpClient.onMetaData(infoObject);
        }

        public function onXMPData(infoObject:Object):void {
            _fpClient.onXMPData(infoObject);
        }

        public function onCaption(cps:String, spk:Number):void {
            _fpClient.onCaption(cps, spk);
        }

        public function onCaptionInfo(obj:Object):void {
            _fpClient.onCaptionINfo(obj);
        }

        public function onImageData(obj:Object):void {
            _fpClient.onImageData(obj);
        }

        public function RtmpSampleAccess(obj:Object):void {
            _fpClient.RtmpSampleAccess(obj);
        }

        public function onTextData(obj:Object):void {
            _fpClient.onTextData(obj);
        }

        public function set onTransitionComplete(onTransitionComplete:Function):void {
            _onTransitionComplete = onTransitionComplete;
        }

        public function playStatusHandler(info:Object):void {
            log.debug("playStatusHandler() -- " + info.code, info);
            if (info.code == "NetStream.Play.TransitionComplete" && _onTransitionComplete != null) {
                _onTransitionComplete();
                return;
            }
        }
    }
}