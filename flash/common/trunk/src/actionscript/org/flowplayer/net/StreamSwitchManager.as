/**
 * Created by IntelliJ IDEA.
 * User: danielr
 * Date: 18/05/11
 * Time: 11:19 PM
 * To change this template use File | Settings | File Templates.
 */
package org.flowplayer.net {

    import flash.net.NetStream;
    import flash.events.NetStatusEvent;
    import flash.net.NetStreamPlayOptions;
    import flash.net.NetStreamPlayTransitions;

    import org.flowplayer.view.Flowplayer;


    import org.flowplayer.util.Log;


    public class StreamSwitchManager {

        private var _netStream:NetStream;
        private var _streamSelectionManager:StreamSelectionManager;
        private var _player:Flowplayer;
        private var _previousStreamName:String;
        private var _dynamicOldStreamName:String;

        private var log:Log = new Log("org.flowplayer.net.StreamSwitchManager");

        public function StreamSwitchManager(netStream:NetStream, streamSelectionManager:StreamSelectionManager, player:Flowplayer) {
            _netStream = netStream;
            _streamSelectionManager = streamSelectionManager;
            _player = player;
        }

        public function switchStream(mappedBitrate:BitrateItem):void {
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

        private function switchStreamDynamic(bitrate:BitrateItem):void {
            log.debug("switchStreamDynamic()");
            //_netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamStatus);
            var options:NetStreamPlayOptions = new NetStreamPlayOptions();
            if (_previousStreamName) {
                options.oldStreamName = _previousStreamName;
                options.transition = NetStreamPlayTransitions.SWITCH;
            } else {
                options.transition = NetStreamPlayTransitions.RESET;
            }
            options.streamName = _player.currentClip.url;

            _dynamicOldStreamName = options.oldStreamName;
            log.debug("calling switchStream with Dynamic Switch Streaming, stream name is " + options.streamName);
            //_player.switchStream(_player.currentClip, options);
            _netStream.play2(options);
        }
    }
}
