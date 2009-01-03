/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 * Copyright (c) 2008 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls.slider {
	import org.flowplayer.view.AnimationEngine;	
	import org.flowplayer.controls.Config;
	import org.flowplayer.controls.slider.AbstractSlider;	

	/**
	 * @author api
	 */
	public class VolumeSlider extends AbstractSlider {
		public static const DRAG_EVENT:String = AbstractSlider.DRAG_EVENT;
		
		public function VolumeSlider(config:Config, animationEngine:AnimationEngine) {
			super(config, animationEngine);
			tooltipTextFunc = function(percentage:Number):String {
				return Math.round(percentage) + "%";
			};
		}
		
		override protected function isToolTipEnabled():Boolean {
			return _config.tooltips.volume;
		}
	}
}
