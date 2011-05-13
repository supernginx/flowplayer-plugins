/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009-2011 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.bwcheck.detect {
    import flash.display.Stage;
    import flash.display.StageDisplayState;

    import org.flowplayer.bwcheck.config.Config;
    import org.flowplayer.bwcheck.BitrateItem;
    
    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.util.Arrange;
    import org.flowplayer.util.Log;
    import org.flowplayer.view.Flowplayer;
    
    import org.osmf.net.DynamicStreamingItem;

    public class StreamSelector {
        private static var log:Log = new Log("org.flowplayer.bwcheck.detect::StreamSelector");
        private var _streamItems:Vector.<DynamicStreamingItem>;
        private var _player:Flowplayer;
        private var _config:Config;
        private var _currentIndex:Number = -1;

        public function StreamSelector(streamItems:Vector.<DynamicStreamingItem>, player:Flowplayer, config:Config) {
            _streamItems = sort(streamItems);
            _player = player;
            _config = config;
        }

        private function sort(bitrates:Vector.<DynamicStreamingItem>):Vector.<DynamicStreamingItem> {
            var sorter:Function = function (a:DynamicStreamingItem, b:DynamicStreamingItem):Number {
                // increasing bitrate order
                if (a.bitrate == b.bitrate) {
                    // decreasing width inside the same bitrate
                    if (a.width == b.width) {
                        return 0;
                    } else if (a.width < b.width) {
                        return 1;
                    }
                    return -1;


                } else if (a.bitrate > b.bitrate) {
                    return 1;
                }
                return -1;
            };
            return bitrates.concat().sort(sorter);
        }

        public function get bitrates():Vector.<DynamicStreamingItem> {
            return _streamItems;
        }

        public function getStreamIndex(bandwidth:Number):Number {
            for (var i:Number = _streamItems.length - 1; i >= 0; i--) {
                var item:DynamicStreamingItem = _streamItems[i];

                log.debug("candidate '" + item.streamName + "' has width " + item.width + ", bitrate " + item.bitrate);

                var enoughBw:Boolean = bandwidth >= item.bitrate;
                var bitrateSpecified:Boolean = item.bitrate > 0;
                log.info("fits screen? " + fitsScreen(item, _player, _config) + ", enough BW? " + enoughBw + ", bitrate specified? " + bitrateSpecified);

                if (fitsScreen(item, _player, _config) && enoughBw && bitrateSpecified) {
                    log.debug("selecting bitrate with width " + item.width + " and bitrate " + item.bitrate);
                    _currentIndex = i;
                    return i;
                    break;
                }
            }
            return -1;
        }

        internal static function fitsScreen(item:DynamicStreamingItem, player:Flowplayer, config:Config):Boolean {
            if (! item.width) return true;

            var screen:DisplayProperties = player.screen;
            var stage:Stage = screen.getDisplayObject().stage;
            // take the size from screen when the screen width is 100% --> by default works on HW scaled mode also
            var screenWidth:Number = stage.displayState == StageDisplayState.FULL_SCREEN && screen.widthPct == 100 ? stage.fullScreenWidth : screen.getDisplayObject().width;

            log.debug("screen width is " + screenWidth);

            // max container width specified --> allows for resizing the player or for going above the current screen width
            if (config.maxWidth > 0 && ! player.isFullscreen()) {
                return config.maxWidth >= item.width;
            }
            return screenWidth >= item.width;
        }

        public function getStream(bandwidth:Number):DynamicStreamingItem {
            var index:Number = getStreamIndex(bandwidth);
            if (index == -1) return getDefaultStream();
            return _streamItems[index] as BitrateItem;
        }


        public function getDefaultStream():DynamicStreamingItem {
            log.debug("getDefaultStream()");
            var item:DynamicStreamingItem;
            for (var i:Number = 0; i < _streamItems.length; i++) {
                if (_streamItems[i]["isDefault"]) {
                    item = _streamItems[i];
                    _currentIndex = i;
                    break;
                }
            }
            if (! item) {
                //fix for #241 lowest item is the first index not the last once ordered.
                item = _streamItems[0];
                _currentIndex = 0;
                log.debug("getDefaultStream(), did not find a default stream -> using the one with lowest bitrate " + item);
            } else {
                log.debug("getDefaultStream(), found default item " + item);
            }
            return item;
        }

        public function getItem(index:uint):DynamicStreamingItem {
            return _streamItems[index];
        }

        public function get currentIndex():Number {
            return _currentIndex;
        }
        
        public function set currentIndex(value:Number):void {
            log.debug("set currentIndex() setting to " + value);
            _currentIndex = value;
        }

        public function get streamItems():Vector.<DynamicStreamingItem> {
            return _streamItems;
        }

        public function fromName(name:String):DynamicStreamingItem {
            for (var i:Number = 0; i < _streamItems.length; i++) {
                if (_streamItems[i].streamName.indexOf(name) == 0 ||
                    _streamItems[i].streamName.indexOf("mp4:" + name) == 0) {  
                    return _streamItems[i];
                }
            }
            return null;
        }
    }
}