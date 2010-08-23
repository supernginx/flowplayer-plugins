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
package org.flowplayer.bwcheck.strategy {
    import org.osmf.net.DynamicStreamingItem;

    public class AbstractStreamSelection {
        protected var _bitrates:Vector.<DynamicStreamingItem>;

        public function AbstractStreamSelection(bitrates:Vector.<DynamicStreamingItem>) {
            _bitrates = sort(bitrates);
        }

        private function sort(bitrates:Vector.<DynamicStreamingItem>):Vector.<DynamicStreamingItem> {
            var sorter:Function = function (a:DynamicStreamingItem, b:DynamicStreamingItem):Number {
                if (a.bitrate == b.bitrate) {
                    return 0;
                } else if (a.bitrate < b.bitrate) {
                    return 1;
                }
                return -1;
            };
            return bitrates.concat().sort(sorter);
        }

        public function get bitrates():Vector.<DynamicStreamingItem> {
            return _bitrates;
        }
    }
}