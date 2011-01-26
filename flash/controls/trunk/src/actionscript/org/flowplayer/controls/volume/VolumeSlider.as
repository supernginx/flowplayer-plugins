/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *Copyright (c) 2008, 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls.volume {
	
    import flash.display.DisplayObject;
	import flash.display.Sprite;
import org.flowplayer.view.AnimationEngine;
	import org.flowplayer.controls.config.Config;
	import org.flowplayer.controls.buttons.AbstractSlider;	
	import org.flowplayer.controls.buttons.SliderConfig;	
	
	import org.flowplayer.view.Flowplayer;

	/**
	 * @author api
	 */
	public class VolumeSlider extends AbstractSlider {
		public static const DRAG_EVENT:String = AbstractSlider.DRAG_EVENT;

		private var _volumeBar:Sprite;

        override public function get name():String {
            return "volume";
        }

		public function VolumeSlider(config:SliderConfig, player:Flowplayer, controlbar:DisplayObject) {
			super(config, player, controlbar);
			tooltipTextFunc = function(percentage:Number):String {
                if (percentage > 100) return "100%";
                if (percentage < 0) return "0%";
				return Math.round(percentage) + "%";
			};
			
			createBars();
		}
		
		private function createBars():void {
			_volumeBar = new Sprite();
			addChild(_volumeBar);
			swapChildren(_dragger, _volumeBar);
		}
		
		override public function configure(config:Object):void {
			super.configure(config);
			
			onSetValue();
		}
		
        override protected function onSetValue():void {
			var pos:Number = value/100 * (width - _dragger.width);			
            animationEngine.animateProperty(_dragger, "x", pos, 200);
			drawBar(_volumeBar, volumeColor, volumeAlpha, _config.gradient, 0, pos + _dragger.width / 2);
        }

		override protected function isToolTipEnabled():Boolean {
			return _config.draggerButtonConfig.tooltipEnabled;
		}

		protected function get volumeColor():Number {			
			if (isNaN(_config.backgroundColor) || _config.backgroundColor == -2 ) return sliderColor;
            return _config.backgroundColor;
        }

		protected function get volumeAlpha():Number {
			if (isNaN(_config.backgroundAlpha) || _config.backgroundAlpha == -2 ) return sliderAlpha;
            return _config.backgroundAlpha;
        }
	}
}
