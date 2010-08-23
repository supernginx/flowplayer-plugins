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
		
		public function StreamSelectionFactory(config:Config, bitrates:Vector.<DynamicStreamingItem>) {
			try {
				var strategyCls:Class = getStrategy(config.streamSelectionStrategy);
				_strategy = new strategyCls(config, bitrates);
			} catch (e:Error) {
				
			}
			if (_strategy == null) _strategy = new StreamSelectionDefault(config, bitrates);
		}
		
		public function getStreamIndex(bandwidth:Number, player:Flowplayer):Number {
			return _strategy.getStreamIndex(bandwidth, player);
		}
		
		public function getStream(bandwidth:Number, player:Flowplayer):DynamicStreamingItem {
			return _strategy.getStream(bandwidth, player);
		}

        public function getDefaultStream(player:Flowplayer):DynamicStreamingItem {
            return _strategy.getDefaultStream(player);
        }
		
		private function getStrategy(strategy:String):Class {
			return FactoryMethodUtil.getFactoryMethod("org.flowplayer.bwcheck.strategy.StreamSelection", strategy);
		}

        public function get bitrates():Vector.<org.osmf.net.DynamicStreamingItem> {
            // return a defensive copy
            return _strategy.bitrates.concat();
        }
    }
}
