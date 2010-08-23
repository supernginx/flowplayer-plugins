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


    import org.flowplayer.util.Log;
    import org.flowplayer.view.Flowplayer;
	import org.flowplayer.bwcheck.model.BitrateItem;
	import org.flowplayer.bwcheck.Config;
	
	import __AS3__.vec.Vector;
	import org.osmf.net.DynamicStreamingItem;
	
	/**
	 * @author danielr
	 */
	public class StreamSelectionDefault implements StreamSelection {
		
        private var log:Log = new Log(this);
		
		public function StreamSelectionDefault(config:Config) {
		}
		
		public function getStreamIndex(bandwidth:Number, bitrateProperties:Vector.<DynamicStreamingItem>, player:Flowplayer):Number {
			var screenWidth:Number = player.screen.getDisplayObject().width;
			log.debug("screen width is " + screenWidth + ", bandwidth is " + bandwidth);

			for (var i:Number=0; i < bitrateProperties.length; i++) {
                var item:DynamicStreamingItem = bitrateProperties[i];

				log.debug("candidate stream has width " + item.width + ", bitrate " + item.bitrate);
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
		
		public function getStream(bandwidth:Number, bitrateProperties:Vector.<DynamicStreamingItem>, player:Flowplayer):DynamicStreamingItem {
            var index:Number = getStreamIndex(bandwidth, bitrateProperties, player);
            if (index == -1) return getDefaultStream(bitrateProperties, player);
            return bitrateProperties[index] as BitrateItem;
		}


        public function getDefaultStream(bitrateProperties:Vector.<DynamicStreamingItem>, player:Flowplayer):DynamicStreamingItem {
            log.debug("getDefaultStream()");
            var item:DynamicStreamingItem;           
            for (var i:Number=0; i < bitrateProperties.length; i++) {
                if (bitrateProperties[i]["isDefault"]) {
                    item = bitrateProperties[i];
                    break;
                }
            }
            if (! item) {
                item = bitrateProperties[bitrateProperties.length - 1];
                log.debug("getDefaultStream(), did not find a default stream -> using the one with lowest bitrate " + item);
            } else {
                log.debug("getDefaultStream(), found default item " + item);
            }
            return item;
        }
    }
}
