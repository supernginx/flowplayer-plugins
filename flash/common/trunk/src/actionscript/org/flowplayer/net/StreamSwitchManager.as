/**
 * Created by IntelliJ IDEA.
 * User: danielr
 * Date: 18/05/11
 * Time: 11:19 PM
 * To change this template use File | Settings | File Templates.
 */
package org.flowplayer.net {

    import flash.net.NetStream;
    import flash.net.NetStreamPlayOptions;
    import flash.net.NetStreamPlayTransitions;

    import flash.events.NetStatusEvent;

    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.util.Log;


    public class StreamSwitchManager {

        private var _netStream:NetStream;
        private var _streamSelectionManager:StreamSelectionManager;
        private var _player:Flowplayer;
        private var _previousStreamName:String;
        private var _dynamicOldStreamName:String;
        private var _previousBitrateItem:BitrateItem;

        private var log:Log = new Log("org.flowplayer.net.StreamSwitchManager");

        public function StreamSwitchManager(netStream:NetStream, streamSelectionManager:StreamSelectionManager, player:Flowplayer) {
            _netStream = netStream;
            _streamSelectionManager = streamSelectionManager;
            _player = player;
        }

        public function get previousBitrateItem():BitrateItem {
            return _previousBitrateItem;
        }

        public function switchStream(mappedBitrate:BitrateItem):void {
            _previousBitrateItem = _streamSelectionManager.currentBitrateItem;
            _streamSelectionManager.changeStreamNames(mappedBitrate);
            if (_netStream && _netStream.hasOwnProperty("play2")) {
                switchStreamDynamic(mappedBitrate);
            } else {
                switchStreamNative(mappedBitrate);
            }
        }

        private function switchStreamNative(mappedBitrate:BitrateItem):void {
            _player.switchStream(_player.currentClip);
        }

        private function switchStreamDynamic(bitrateItem:BitrateItem):void {
            log.debug("switchStreamDynamic()");

            var options:NetStreamPlayOptions = new NetStreamPlayOptions();
            if (_previousBitrateItem) {
                options.oldStreamName = _previousBitrateItem.url;
                options.transition = NetStreamPlayTransitions.SWITCH;
            } else {
                options.transition = NetStreamPlayTransitions.RESET;
            }
            options.streamName = bitrateItem.url;

            log.debug("calling switchStream with Dynamic Switch Streaming, stream name is " + options.streamName);
            _player.switchStream(_player.currentClip, options);
        }
    }
}
