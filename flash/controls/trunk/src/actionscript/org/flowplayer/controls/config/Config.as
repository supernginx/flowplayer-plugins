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

    /**
	 * @author api
	 */
	public class Config {
		private var log:Log = new Log(this);
        private var _player:Flowplayer;
		private var _skin:String;
		private var _style:Style;
        private var _autoHide:AutoHideConfig = new AutoHideConfig();
        private var _visible:WidgetBooleanStates = new WidgetBooleanStates();
		private var _enabled:WidgetBooleanStates = new WidgetEnabledStates();
		private var _tooltips:ToolTips = new ToolTips();
        private var _spacing:WidgetSpacing = new WidgetSpacing();

		public function get style():Style {
			return _style || new Style();
		}
		
		public function addStyleProps(styleProps:Object):void {
			_style = new PropertyBinder(style, "bgStyle").copyProperties(styleProps) as Style;
		}

        [Value]
		public function get visible():WidgetBooleanStates {
			return _visible;
		}
		
		public function set visible(visible:WidgetBooleanStates):void {
			_visible = visible;
		}
		
        [Value]
		public function get enabled():WidgetBooleanStates {
			return _enabled;
		}
		
		public function set enabled(enabled:WidgetBooleanStates):void {
			_enabled = enabled;
		}
		
        [Value]
		public function get skin():String {
			return _skin;
		}
		
		public function set skin(skin:String):void {
			_skin = skin;
		}
		
        [Value]
		public function get tooltips():ToolTips {
			return _tooltips;
		}
		
		public function set tooltips(tooltips:ToolTips):void {
			_tooltips = tooltips;
		}

        public function get player():Flowplayer {
            return _player;
        }

        public function set player(value:Flowplayer):void {
            _player = value;
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

        [Value]
        public function get spacing():WidgetSpacing {
            return _spacing;
        }

        public function set spacing(value:WidgetSpacing):void {
            _spacing = value;
        }
    }
}
