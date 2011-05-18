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

    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.view.Flowplayer;


    import org.flowplayer.util.Log;


    public class StreamSwitchManager {

        private var _netStream:NetStream;
        private var _streamSelectionManager:StreamSelectionManager;
        private var _provider:StreamProvider;
        private var _player:Flowplayer;
        private var _resolver:ClipURLResolver;
        private var _previousStreamName:String;
        private var _dynamicOldStreamName:String;

        private var log:Log = new Log("org.flowplayer.net.StreamSwitchManager");

        public function StreamSwitchManager(netStream:NetStream, streamSelectionManager:StreamSelectionManager, provider:StreamProvider, player:Flowplayer, resolver:ClipURLResolver) {
            _netStream = netStream;
            _streamSelectionManager = streamSelectionManager;
            _provider = provider;
            _player = player;
            _resolver = resolver;
        }

        public function changeStreamNames(mappedBitrate:BitrateItem):void {
            var url:String = mappedBitrate.url;
            //we need to pickup the first actual resolved clip not what is set in clip.url.
            _previousStreamName = _previousStreamName ? _player.currentClip.url : url;

            _player.currentClip.setResolvedUrl(_resolver, url);
            _player.currentClip.setCustomProperty("bwcheckResolvedUrl", url);
            _player.currentClip.setCustomProperty("mappedBitrate", mappedBitrate);
            log.debug("mappedUrl " + url + ", clip.url now " + _player.currentClip.url);
        }

        public function switchStream(mappedBitrate:BitrateItem):void {
            _streamSelectionManager.currentIndex = mappedBitrate.index;
            changeStreamNames(mappedBitrate);
            //if (_netStream && _netStream.hasOwnProperty("play2") && (_provider.type == "rtmp" || _provider.type == "httpstreaming")) {

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
            _player.switchStream(_player.currentClip, options);
            //_netStream.play2(options);
        }
    }
}
