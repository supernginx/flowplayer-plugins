/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *Copyright (c) 2008, 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls.slider {
    import flash.display.DisplayObject;
	import flash.display.Sprite;
import org.flowplayer.view.AnimationEngine;
	import org.flowplayer.controls.Config;
	import org.flowplayer.controls.slider.AbstractSlider;	

	/**
	 * @author api
	 */
	public class VolumeSlider extends AbstractSlider {
		public static const DRAG_EVENT:String = AbstractSlider.DRAG_EVENT;

		private var _volumeBar:Sprite;

        override public function get name():String {
            return "volume";
        }

		public function VolumeSlider(config:Config, animationEngine:AnimationEngine, controlbar:DisplayObject) {
			super(config, animationEngine, controlbar);
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
		
		override public function redraw(config:Config):void {
			super.redraw(config);
			
			onSetValue();
		}
		
        override protected function onSetValue():void {
			var pos:Number = value/100 * (width - _dragger.width);
            animationEngine.animateProperty(_dragger, "x", pos, 200);
			drawBar(_volumeBar, volumeColor, volumeAlpha, _config.style.bufferGradient, 0, pos + _dragger.width / 2);
        }

		override protected function isToolTipEnabled():Boolean {
			return _config.tooltips.volume;
		}

        override protected function get barHeight():Number {
            log.debug("bar height ratio is " + _config.style.volumeSliderHeightRatio);
            return height * _config.style.volumeBarHeightRatio;

        }

        override protected function get sliderGradient():Array {
            return _config.style.volumeSliderGradient;
        }

        override protected function get sliderColor():Number {
            return _config.style.volumeSliderColor;
        }

		override protected function get sliderAlpha():Number {
            return _config.style.volumeAlpha;
        }

		override protected function get borderWidth():Number {
			return _config.style.volumeBorderWidth;
		}
		
		override protected function get borderColor():Number {
			return _config.style.volumeBorderColor;
		}
		
		override protected function get borderAlpha():Number {
			return _config.style.volumeBorderAlpha;
		}

		protected function get volumeColor():Number {
			if (isNaN(_config.style.volumeColor) || _config.style.volumeColor == -2 ) return sliderColor;
            return _config.style.volumeColor;
        }

		protected function get volumeAlpha():Number {
			if (isNaN(_config.style.volumeSliderAlpha) || _config.style.volumeSliderAlpha == -2 ) return sliderAlpha;
            return _config.style.volumeSliderAlpha;
        }

        override protected function get barCornerRadius():Number {
            if (isNaN(_config.style.volumeBorderRadius)) return super.barCornerRadius;
            return _config.style.volumeBorderRadius;
        }
	}
}
