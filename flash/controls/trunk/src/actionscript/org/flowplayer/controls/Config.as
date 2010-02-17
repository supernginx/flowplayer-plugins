/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *Copyright (c) 2008, 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls {
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
		private var _autoHide:String = "fullscreen"; // never | fullscreen | always
		private var _hideDelay:Number = 4000;
        private var _hideDuration:Number = 800;
        private var _hideStyle:String = "move";
        private var _visible:WidgetBooleanStates = new WidgetBooleanStates();
		private var _enabled:WidgetBooleanStates = new WidgetEnabledStates();
		private var _tooltips:ToolTips = new ToolTips();

        [Value]
        public function get autoHide():String {
			return _autoHide;
		}

        public function set autoHide(autoHide:String):void {
            _autoHide = autoHide;
        }

        public function set state(autoHide:String):void {
            _autoHide = autoHide;
        }

        [Value]
		public function get style():Style {
			return _style || new Style();
		}
		
		public function addStyleProps(styleProps:Object):void {
			_style = new PropertyBinder(style, "bgStyle").copyProperties(styleProps) as Style;
		}
		
        [Value]
		public function get hideDelay():Number {
			return _hideDelay;
		}

        public function set hideDelay(hideDelay:Number):void {
            _hideDelay = hideDelay;
        }

        public function set delay(hideDelay:Number):void {
            _hideDelay = hideDelay;
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
        public function get hideDuration():Number {
            return _hideDuration;
        }

        public function set hideDuration(value:Number):void {
            _hideDuration = value;
        }

        public function set duration(value:Number):void {
            _hideDuration = value;
        }

        [Value]
        public function get hideStyle():String {
            return _hideStyle;
        }

        public function set hideStyle(value:String):void {
            _hideStyle = value;
        }

        /**
         * Synonym for set hideStyle()
         * @param value
         * @return
         */
        public function setStyle(value:String):void {
            _hideStyle = value;
        }
    }
}
