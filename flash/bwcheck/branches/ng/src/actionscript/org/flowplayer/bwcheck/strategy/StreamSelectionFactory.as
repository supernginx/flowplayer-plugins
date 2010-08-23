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

    import org.flowplayer.bwcheck.Config;
    import org.flowplayer.bwcheck.model.BitrateItem;
    import org.flowplayer.bwcheck.util.FactoryMethodUtil;
    import org.flowplayer.view.Flowplayer;
	
	import __AS3__.vec.Vector;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.SwitchingRuleBase;

    /**
	 * @author danielr
	 */
	public class StreamSelectionFactory implements StreamSelection {
		
		private var _strategy:StreamSelection;
		private var _resizable:StreamSelectionResizable;
		
		public function StreamSelectionFactory(config:Config) {
			try {
				var strategyCls:Class = getStrategy(config.streamSelectionStrategy);
				_strategy = new strategyCls(config);
			} catch (e:Error) {
				
			}
			if (_strategy == null) _strategy = new StreamSelectionDefault(config);
		}
		
		public function getStreamIndex(bandwidth:Number, bitrateProperties:Vector.<DynamicStreamingItem>, player:Flowplayer):Number {
			return _strategy.getStreamIndex(bandwidth, bitrateProperties, player);
		}
		
		public function getStream(bandwidth:Number, bitrateProperties:Vector.<DynamicStreamingItem>, player:Flowplayer):DynamicStreamingItem {
			return _strategy.getStream(bandwidth, bitrateProperties, player);
		}

        public function getDefaultStream(bitrateProperties:Vector.<DynamicStreamingItem>, player:Flowplayer):DynamicStreamingItem {
            return _strategy.getDefaultStream(bitrateProperties, player);
        }
		
		private function getStrategy(strategy:String):Class {
			return FactoryMethodUtil.getFactoryMethod("org.flowplayer.bwcheck.strategy.StreamSelection", strategy);
		}
    }
}
