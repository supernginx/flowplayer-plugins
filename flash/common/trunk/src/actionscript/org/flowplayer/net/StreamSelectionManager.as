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

package org.flowplayer.net {
    import flash.display.Stage;
    import flash.display.StageDisplayState;

import mx.utils.object_proxy;

import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.util.Arrange;
    import org.flowplayer.util.Log;
    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.view.Flowplayer;
    
    import org.osmf.net.DynamicStreamingItem;

    public class StreamSelectionManager {
        private static var log:Log = new Log("org.flowplayer.net.StreamSelectionManager");
        private var _streamItems:Vector.<DynamicStreamingItem>;
        private var _currentIndex:Number = -1;
        private var _player:Flowplayer;
        private var _resolver:ClipURLResolver;
        private var _previousStreamName:String;
        private var _currentBitrateItem:BitrateItem;
        private var _bitrateResource:BitrateResource;

        public function StreamSelectionManager(bitrateResource:BitrateResource, player:Flowplayer, resolver:ClipURLResolver) {
            _bitrateResource = bitrateResource;
            _streamItems = _bitrateResource.addBitratesToClip(player.currentClip);
            _player = player;
            _resolver = resolver;
        }

        public function get bitrates():Vector.<DynamicStreamingItem> {
            return _streamItems;
        }

        public function get bitrateResource():BitrateResource {
            return _bitrateResource;
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

        public function getStreamIndex(bitrate:Number):Number {
            for (var i:Number = _streamItems.length - 1; i >= 0; i--) {
                var item:DynamicStreamingItem = _streamItems[i];

                if (item.bitrate == bitrate) {
                    return i;
                    break;
                }
            }
            return -1;
        }

        public function getStream(bitrate:Number):DynamicStreamingItem {
            var index:Number = getStreamIndex(bitrate);
            if (index == -1) return getDefaultStream();
            return _streamItems[index] as BitrateItem;
        }

        public function getMappedBitrate(bandwidth:Number = -1):BitrateItem {
            if (bandwidth == -1) return getDefaultStream() as BitrateItem;
            return getStream(bandwidth) as BitrateItem;
        }

        public function getItem(index:uint):DynamicStreamingItem {
            return _streamItems[index];
        }

        public function get currentIndex():Number {
            return _currentIndex;
        }

        public function set currentIndex(value:Number):void {
            _currentIndex = value;
        }

        public function get currentBitrateItem():BitrateItem {
            return _currentBitrateItem;
        }

        public function set currentBitrateItem(value:BitrateItem):void {
            _currentBitrateItem = value;
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

        public function changeStreamNames(mappedBitrate:BitrateItem):void {
            var url:String = mappedBitrate.url;

            _previousStreamName = _previousStreamName ? _player.currentClip.url : url;
            currentBitrateItem = mappedBitrate;
            currentIndex = mappedBitrate.index;

            _player.currentClip.setResolvedUrl(_resolver, url);
            _player.currentClip.setCustomProperty("bwcheckResolvedUrl", url);
            _player.currentClip.setCustomProperty("mappedBitrate", mappedBitrate);
            log.debug("mappedUrl " + url + ", clip.url now " + _player.currentClip.url);
        }

    }
}