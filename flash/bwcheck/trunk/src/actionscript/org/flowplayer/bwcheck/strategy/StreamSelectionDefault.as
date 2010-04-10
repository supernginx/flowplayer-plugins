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
	
	/**
	 * @author danielr
	 */
	public class StreamSelectionDefault implements StreamSelection {
		
        private var log:Log = new Log(this);
		
		public function StreamSelectionDefault(config:Config) {
		}
		
		public function getStreamIndex(bandwidth:Number, bitrateProperties:Array, player:Flowplayer):Number {
			var screenWidth:Number = player.screen.getDisplayObject().width;
			log.debug("screen width is " + screenWidth + ", bandwidth is " + bandwidth);

			for (var i:Number=0; i < bitrateProperties.length; i++) {
				log.debug("candidate stream has width " + bitrateProperties[i].width + ", bitrate " + bitrateProperties[i].bitrate);
				if (screenWidth >= bitrateProperties[i].width &&
					 bandwidth >= bitrateProperties[i].bitrate && bitrateProperties[i].bitrate) {
                    log.debug("selecting bitrate with width " + bitrateProperties[i].width);
                    return i;
					break;
				}
			}
			return 0;
		}
		
		public function getStream(bandwidth:Number, bitrateProperties:Array, player:Flowplayer):BitrateItem {
			return bitrateProperties[getStreamIndex(bandwidth, bitrateProperties, player)] as BitrateItem;
		}


        public function getDefaultStream(bitrateProperties:Array, player:Flowplayer):BitrateItem {
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
