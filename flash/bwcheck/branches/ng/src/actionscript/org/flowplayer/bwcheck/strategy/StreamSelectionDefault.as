/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.bwcheck.strategy {
    import org.flowplayer.bwcheck.Config;
    import org.flowplayer.bwcheck.model.BitrateItem;
    import org.flowplayer.util.Log;
    import org.flowplayer.view.Flowplayer;
    import org.osmf.net.DynamicStreamingItem;

    /**
     * @author danielr
     */
    public class StreamSelectionDefault extends AbstractStreamSelection implements StreamSelection {

        private var log:Log = new Log(this);

        public function StreamSelectionDefault(config:Config, bitrates:Vector.<DynamicStreamingItem>) {
            super(bitrates);
        }


        public function getStreamIndex(bandwidth:Number, player:Flowplayer):Number {
            var screenWidth:Number = player.screen.getDisplayObject().width;
            log.debug("screen width is " + screenWidth + ", bandwidth is " + bandwidth);

            for (var i:Number = _bitrates.length - 1; i >= 0; i--) {
                var item:DynamicStreamingItem = _bitrates[i];

                log.debug("candidate '" + item.streamName + "' has width " + item.width + ", bitrate " + item.bitrate);
                var fitsScreen:Boolean = ! item.width || screenWidth >= item.width;
                var enoughBw:Boolean = bandwidth >= item.bitrate;
                var bitrateSpecified:Boolean = item.bitrate > 0;
                log.info("fits screen? " + fitsScreen + ", enough BW? " + enoughBw + ", bitrate specified? " + bitrateSpecified);

                if (fitsScreen && enoughBw && bitrateSpecified) {
                    log.debug("selecting bitrate with width " + item.width + " and bitrate " + item.bitrate);
                    return i;
                    break;
                }
            }
            return -1;
        }

        public function getStream(bandwidth:Number, player:Flowplayer):DynamicStreamingItem {
            var index:Number = getStreamIndex(bandwidth, player);
            if (index == -1) return getDefaultStream(player);
            return _bitrates[index] as BitrateItem;
        }


        public function getDefaultStream(player:Flowplayer):DynamicStreamingItem {
            log.debug("getDefaultStream()");
            var item:DynamicStreamingItem;
            for (var i:Number = 0; i < _bitrates.length; i++) {
                if (_bitrates[i]["isDefault"]) {
                    item = _bitrates[i];
                    break;
                }
            }
            if (! item) {
                item = _bitrates[_bitrates.length - 1];
                log.debug("getDefaultStream(), did not find a default stream -> using the one with lowest bitrate " + item);
            } else {
                log.debug("getDefaultStream(), found default item " + item);
            }
            return item;
        }

    }
}
