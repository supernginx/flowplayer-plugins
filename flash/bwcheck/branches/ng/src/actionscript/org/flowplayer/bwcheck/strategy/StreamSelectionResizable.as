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
	public class StreamSelectionResizable implements StreamSelection {
		
		private var _config:Config;
		private var log:Log = new Log(this);
		
		public function StreamSelectionResizable(config:Config) {
			_config = config;
		}
		
		public function getStreamIndex(bandwidth:Number, bitrateProperties:Vector.<DynamicStreamingItem>, player:Flowplayer):Number {
			
			var screenWidth:Number = player.screen.getDisplayObject().width;
			
			
			var index:Number = bitrateProperties.length - 1;
			
			for (var i:Number=0; i < bitrateProperties.length; i++) {
				
				if (!player.isFullscreen()) {
					if (bitrateProperties[i].width <= _config.maxContainerWidth && 
					    bandwidth >= bitrateProperties[i].bitrate && bitrateProperties[i].bitrate) {
					    return i;
					    break;
				    }
				} else {
					if (screenWidth >= bitrateProperties[i].width && 
						 bandwidth >= bitrateProperties[i].bitrate && bitrateProperties[i].bitrate) {
						return i;	 	
						break;
					}
				}
			}
			return index;
		}
		
		public function getStream(bandwidth:Number, bitrateProperties:Vector.<DynamicStreamingItem>, player:Flowplayer):DynamicStreamingItem {
			return bitrateProperties[getStreamIndex(bandwidth, bitrateProperties, player)] as BitrateItem;
		}
		
	
		public function getDefaultStream(bitrateProperties:Vector.<DynamicStreamingItem>, player:Flowplayer):DynamicStreamingItem {
            log.debug("getDefaultStream()");
            for (var i:Number=0; i < bitrateProperties.length; i++) {
                if (bitrateProperties[i]["isDefault"]) {
                    return bitrateProperties[i];
                    break;
                }
            }
            log.debug("getDefaultStream(), did not find a default stream");
            return bitrateProperties[0];
        }
		
	}
}
