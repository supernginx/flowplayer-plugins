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
    import org.flowplayer.bwcheck.strategy.AbstractStreamSelection;
    import org.flowplayer.util.Log;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.bwcheck.model.BitrateItem;
    import org.flowplayer.bwcheck.Config;

    import __AS3__.vec.Vector;

    import org.osmf.net.DynamicStreamingItem;

    /**
     * @author danielr
     */
    public class StreamSelectionResizable extends AbstractStreamSelection implements StreamSelection {

        private var _config:Config;
        private var log:Log = new Log(this);

        public function StreamSelectionResizable(config:Config, bitrates:Vector.<DynamicStreamingItem>) {
            super(bitrates);
            _config = config;
        }

        public function getStreamIndex(bandwidth:Number, player:Flowplayer):Number {

            var screenWidth:Number = player.screen.getDisplayObject().width;


            var index:Number = bitrates.length - 1;

            for (var i:Number = 0; i < bitrates.length; i++) {

                if (!player.isFullscreen()) {
                    if (bitrates[i].width <= _config.maxContainerWidth &&
                            bandwidth >= bitrates[i].bitrate && bitrates[i].bitrate) {
                        return i;
                        break;
                    }
                } else {
                    if (screenWidth >= bitrates[i].width &&
                            bandwidth >= bitrates[i].bitrate && bitrates[i].bitrate) {
                        return i;
                        break;
                    }
                }
            }
            return index;
        }

        public function getStream(bandwidth:Number, player:Flowplayer):DynamicStreamingItem {
            return bitrates[getStreamIndex(bandwidth, player)] as BitrateItem;
        }


        public function getDefaultStream(player:Flowplayer):DynamicStreamingItem {
            log.debug("getDefaultStream()");
            for (var i:Number = 0; i < bitrates.length; i++) {
                if (bitrates[i]["isDefault"]) {
                    return bitrates[i];
                    break;
                }
            }
            log.debug("getDefaultStream(), did not find a default stream");
            return bitrates[0];
        }

    }
}
