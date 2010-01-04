package org.flowplayer.bwcheck.strategy {

	/**
	 * @author danielr
	 */
	import flash.utils.getDefinitionByName;
	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.bwcheck.Bitrate;
	import org.flowplayer.bwcheck.BWConfig;
	
	public class StreamSelectionFactory implements StreamSelection {
		
		private var _strategy:StreamSelection;
		private var stategyDefaultImpl:StreamSelectionDefault;
		private var stategyResizableImpl:StreamSelectionResizable;
		
		public function StreamSelectionFactory(config:BWConfig) {
			var strategyCls:Class = getStrategy(config.streamSelectionStrategy);
			_strategy = new strategyCls(config);
			
			if (_strategy == null) _strategy = new StreamSelectionDefault(config);
		}
		
		public function getStreamIndex(bandwidth:Number, bitrateProperties:Array, player:Flowplayer):Number {
			return _strategy.getStreamIndex(bandwidth, bitrateProperties, player);
		}
		
		public function getStream(bandwidth:Number, bitrateProperties:Array, player:Flowplayer):Bitrate {
			return _strategy.getStream(bandwidth, bitrateProperties, player);
		}
		
		private function getStrategy(strategy:String):Class {
			 return Class(getDefinitionByName("org.flowplayer.bwcheck.strategy.StreamSelection" + ucFirst(strategy)));
		}
		
		private function ucFirst(value:String):String {
			return String(value.toLowerCase().charAt( 0 ).toUpperCase() + value.substr( 1, value.length ).toLowerCase());
		}
		
		
		
	}
}
