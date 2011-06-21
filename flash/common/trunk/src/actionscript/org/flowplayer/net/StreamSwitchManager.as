/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>, Anssi Piirainen <api@iki.fi> Flowplayer Oy
 * Copyright (c) 2009, 2010 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
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
        private var _streamSelectionManager:IStreamSelectionManager;
        private var _player:Flowplayer;
        private var _previousBitrateItem:BitrateItem;

        protected var log:Log = new Log(this);

        public function StreamSwitchManager(netStream:NetStream, streamSelectionManager:IStreamSelectionManager, player:Flowplayer) {
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

            if (_player.isPaused()) _player.resume();

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
