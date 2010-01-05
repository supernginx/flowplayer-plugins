package org.flowplayer.bwcheck.strategy {
	
	import org.flowplayer.bwcheck.util.FactoryMethodUtil;
	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.bwcheck.model.BitrateItem;
	import org.flowplayer.bwcheck.Config;
	
	public class StreamSelectionFactory implements StreamSelection {
		
		private var _strategy:StreamSelection;
		private var stategyDefaultImpl:StreamSelectionDefault;
		private var stategyResizableImpl:StreamSelectionResizable;
		
		public function StreamSelectionFactory(config:Config) {
			var strategyCls:Class = getStrategy(config.streamSelectionStrategy);
			_strategy = new strategyCls(config);
			
			if (_strategy == null) _strategy = new StreamSelectionDefault(config);
		}
		
		public function getStreamIndex(bandwidth:Number, bitrateProperties:Array, player:Flowplayer):Number {
			return _strategy.getStreamIndex(bandwidth, bitrateProperties, player);
		}
		
		public function getStream(bandwidth:Number, bitrateProperties:Array, player:Flowplayer):BitrateItem {
			return _strategy.getStream(bandwidth, bitrateProperties, player);
		}
		
		private function getStrategy(strategy:String):Class {
			return FactoryMethodUtil.getFactoryMethod("org.flowplayer.bwcheck.strategy.StreamSelection", strategy);
		}
		
	}
}
