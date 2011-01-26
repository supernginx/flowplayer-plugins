/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *Copyright (c) 2008, 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls.config {
    import flash.display.DisplayObject;

    import org.flowplayer.controls.*;
    import org.flowplayer.ui.AutoHide;
    import org.flowplayer.ui.AutoHideConfig;
    import org.flowplayer.util.Log;
	import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.Flowplayer;

	import org.flowplayer.ui.buttons.TooltipButtonConfig;
	import org.flowplayer.controls.buttons.SliderConfig;
	import org.flowplayer.controls.scrubber.ScrubberConfig;
	import org.flowplayer.util.StyleSheetUtil;
	import org.flowplayer.controls.time.TimeViewConfig;
	import org.flowplayer.controls.scrubber.ScrubberConfig;
	import org.flowplayer.controls.buttons.SliderConfig;
	import org.flowplayer.ui.buttons.TooltipButtonConfig;
	import org.flowplayer.ui.buttons.ToggleButtonConfig;
	import org.flowplayer.controls.controllers.*;
	import org.flowplayer.controls.time.TimeViewController;
	import org.flowplayer.controls.scrubber.ScrubberController;
	import org.flowplayer.controls.volume.VolumeController;	
	import flash.utils.*;
	

    /**
	 * @author api
	 */
	public class Config {
		private var log:Log = new Log(this);
        private var _player:Flowplayer;
		private var _skin:String;
		private var _style:Object = {};
		private var _bgStyle:Object = {};
        private var _autoHide:AutoHideConfig = new AutoHideConfig();
		
		private var _enabled:WidgetsEnabledStates = null;
		private var _visible:WidgetsVisibility = null;
		private var _tooltips:ToolTips = null;
        private var _spacing:WidgetsSpacing = null;

		// base guy
		public function get style():Object {
			return _style;
		}
		
		public function clearCaches():void {
			_visible  = null;
			_tooltips = null;
			_enabled  = null;
			_spacing  = null;
		}
		
		public function setNewProps(props:Object, to:String = null):void {
			
			clearCaches();
			
			var dest:Object = _style;
			if ( to ) {
				_style[to] = _style[to] || {};
				dest = _style[to];
			}
			
			for (var name:String in props) {
			//	log.error("Adding "+ name + " = "+ props[name]);
				dest[name] = props[name];
			}
			
			
			
			
			_bgStyle = _style;
		}
		
		public function completeStyleProps(styleProps:Object):Object {
			for (var name:String in _style) {
			//	log.error("Merging back "+ name + " = "+ styleProps[name]);
				styleProps[name] = _style[name];
			}
			
			return styleProps;
		}
		
		
		public function get bgStyle():Object {
			return _bgStyle;
		}

		
	
	
		private function decodeGradient(value:Object, defVal:String = "medium"):Array {
			if (! value) return decodeGradient(defVal);
			if (value is Array) return value as Array;
			if (value == "none") return null;
			if (value == "high") return [.1, 0.5, .1];
			if (value == "medium") return [0, .25, 0];
			return decodeGradient(defVal);
		}



		public function get timeConfig():TimeViewConfig {
			var config:TimeViewConfig = new TimeViewConfig();
			config.setBackgroundColor(_style["timeBgColor"]);
			config.setBorder(_style['timeBorder']);	// some work here to handle timeBorderWidth vs timeBorder
			config.setBorderRadius(_style['timeBorderRadius'])
			config.setDurationColor(_style['durationColor']);
			config.setFontSize(_style['timeFontSize'] || 0);
			config.setHeightRatio(_style['timeBgHeightRatio']);
			config.setSeparator(_style['timeSeparator'] || "/");
			config.setTimeColor(_style['timeColor']);

			return config;
		}

		public function get scrubberConfig():ScrubberConfig {
			var config:ScrubberConfig = new ScrubberConfig();

			config.setBufferColor(_style['bufferColor']);
			config.setBufferGradient(decodeGradient(_style['bufferGradient']));
			config.setColor(_style['progressColor']);
			config.setBackgroundGradient(decodeGradient(_style['sliderGradient']));
			config.setGradient(decodeGradient(_style['progressGradient']));
			config.setBufferGradient(decodeGradient(_style['bufferGradient']))
			config.setBarHeightRatio(_style['scrubberBarHeightRatio']);
			
			var draggerConfig:TooltipButtonConfig = buttonConfig;
			draggerConfig.setTooltipEnabled(tooltips.scrubber);	
			config.setDraggerButtonConfig(draggerConfig);
			
			config.setBackgroundColor(_style['sliderColor']);
			config.setBorder(_style['sliderBorder']);
			config.setBorderRadius(_style['scrubberBorderRadius']);
			config.setHeightRatio(_style['scrubberHeightRatio']);

			return config;
		}

		public function get volumeConfig():SliderConfig {
			var config:SliderConfig = new SliderConfig();

			config.setBarHeightRatio(_style['volumeBarHeightRatio']);
			
			var draggerConfig:TooltipButtonConfig = buttonConfig;
			draggerConfig.setTooltipEnabled(tooltips.volume);
					
			config.setDraggerButtonConfig(draggerConfig);
			
			config.setBackgroundColor(_style['volumeColor']);
			config.setBackgroundGradient(decodeGradient(_style['volumeSliderGradient']));
			config.setColor(_style['volumeSliderColor']);
			config.setGradient(decodeGradient(_style['sliderGradient']));
			config.setBorder(_style['volumeBorder']);
			config.setBorderRadius(_style['volumeBorderRadius']);
			config.setHeightRatio(_style['volumeSliderHeightRatio']);


			return config;
		}

		public function get buttonConfig():TooltipButtonConfig {
			var config:TooltipButtonConfig = new TooltipButtonConfig();
			config.setColor(_style['buttonColor']);
			config.setOverColor(_style['buttonOverColor']);
			config.setTooltipColor(_style['tooltipColor']);
			config.setTooltipTextColor(_style['tooltipTextColor']);
			
			return config;
		}
	
		public function getButtonConfig(name:String = null):TooltipButtonConfig {
			var config:TooltipButtonConfig = buttonConfig;
			config.setTooltipEnabled(tooltips.buttons);
			config.setTooltipLabel(tooltips[name]);
			
			return config;
		}
	
	
		public function getWidgetConfiguration(controller:Class):Object {
			if ( AbstractWidgetController.isKindOfClass(controller, VolumeController) ) {
				return volumeConfig;
			}
			else if ( AbstractWidgetController.isKindOfClass(controller, ScrubberController) ) {
				return scrubberConfig;
			}
			else if ( AbstractWidgetController.isKindOfClass(controller, TimeViewController) ) {
				return timeConfig;
			}
			// this needs to be before the AbstractButtonController
			else if ( AbstractWidgetController.isKindOfClass(controller, AbstractToggleButtonController) ) {
				return new ToggleButtonConfig(
								getButtonConfig(controller['NAME']), 
								getButtonConfig(controller['DOWN_NAME']));
			}
			else if ( AbstractWidgetController.isKindOfClass(controller, AbstractButtonController) ) {
				return getButtonConfig(controller['NAME']);
			}
			else {
				log.warn("Unknown widget "+ controller);
			}
			
			return null;
		}
					
        [Value]
		public function get visible():WidgetsVisibility {
			if ( ! _visible ) _visible = new WidgetsVisibility(_style);
			return _visible;
		}
		
        [Value]
		public function get enabled():WidgetsEnabledStates {
			if ( ! _enabled ) _enabled = new WidgetsEnabledStates(_style['enabled']);
			return _enabled;
		}
		
        [Value]
		public function get tooltips():ToolTips {
			if ( ! _tooltips ) _tooltips = new ToolTips(_style['tooltips']);
			return _tooltips;
		}

		[Value]
        public function get spacing():WidgetsSpacing {
            if ( ! _spacing ) _spacing = new WidgetsSpacing(_style['spacing']);
			return _spacing;
        }
  
		 [Value]
			public function get skin():String {
				return _skin;
			}

			public function set skin(skin:String):void {
				_skin = skin;
			}

        [Value]
        public function get autoHide():AutoHideConfig {
            return _autoHide;
        }

        public function setAutoHide(value:Object):void {
            if (value is String) {
                _autoHide.state = value as String;
            }
            if (value is Boolean) {
                _autoHide.enabled = value as Boolean;
                _autoHide.fullscreenOnly = ! value;
            }
        }
		
		// some backward compatibility
		public function set hideDelay(value:Number):void
		{
			_autoHide.hideDelay = value;
		}
		
		public function get hideDelay():Number
		{
			return _autoHide.hideDelay;
		}
    }
}
