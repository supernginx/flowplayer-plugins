package org.flowplayer.bwcheck.strategy {


	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.bwcheck.model.BitrateItem;
	import org.flowplayer.bwcheck.Config;
	
	public class StreamSelectionDefault implements StreamSelection {
		

		
		public function StreamSelectionDefault(config:Config) {
	
		}
		
		public function getStreamIndex(bandwidth:Number, bitrateProperties:Array, player:Flowplayer):Number {
			
			var screenWidth:Number = player.screen.getDisplayObject().width;
			
			var index:Number = bitrateProperties.length - 1;
			
			for (var i:Number=0; i < bitrateProperties.length; i++) {
				
				if (screenWidth >= bitrateProperties[i].width && 
					 bandwidth >= bitrateProperties[i].bitrate && bitrateProperties[i].bitrate) {
					return i;	 	
					break;
				}
			}
			return index;
		}
		
		public function getStream(bandwidth:Number, bitrateProperties:Array, player:Flowplayer):BitrateItem {
			return bitrateProperties[getStreamIndex(bandwidth, bitrateProperties, player)] as BitrateItem;
		}
		
	
		
		
	}
}
