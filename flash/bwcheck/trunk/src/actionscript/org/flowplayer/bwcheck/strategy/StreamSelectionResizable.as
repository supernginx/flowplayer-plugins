package org.flowplayer.bwcheck.strategy {


	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.bwcheck.Bitrate;
	import org.flowplayer.bwcheck.BWConfig;
	
	public class StreamSelectionResizable implements StreamSelection {
		
		private var _config:BWConfig;
		
		public function StreamSelectionResizable(config:BWConfig) {
			_config = config;
		}
		
		public function getStreamIndex(bandwidth:Number, bitrateProperties:Array, player:Flowplayer):Number {
			
			var screenWidth:Number = player.screen.getDisplayObject().width;
			
			
			var index:Number = bitrateProperties.length - 1;
			
			for (var i:Number=0; i < bitrateProperties.length; i++) {
				
				if (!player.isFullscreen()) {
					if (bitrateProperties[i].width <= _config.maxContainerWidth && 
					    bandwidth >= bitrateProperties[i].bitrate && bitrateProperties[i].bitrate) {
					    	
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
		
		public function getStream(bandwidth:Number, bitrateProperties:Array, player:Flowplayer):Bitrate {
			return bitrateProperties[getStreamIndex(bandwidth, bitrateProperties, player)] as Bitrate;
		}
		
	
		
		
	}
}
