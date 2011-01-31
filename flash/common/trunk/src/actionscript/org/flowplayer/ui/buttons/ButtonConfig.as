/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.ui.buttons {
    import org.flowplayer.util.StyleSheetUtil;

    public class ButtonConfig {
        private var _color:String;
        private var _overColor:String;
        private var _fontColor:String;
        private var _lineColor:String;
		private var _enabled:Boolean = true;


		public static function get defaultConfig():ButtonConfig {
			var config:ButtonConfig = new ButtonConfig;
			config.setColor("#ffffff");
			config.setOverColor("#ffffff");
			config.setFontColor("#000000");
			config.setLineColor("transparent");
			config.setEnabled(true);
			
			return config;
		}

        /*
         * Color.
         */

        public function get color():Number {
            return StyleSheetUtil.colorValue(_color);
        }

        public function get alpha():Number {
            return StyleSheetUtil.colorAlpha(_color);
        }

        public function get colorRGB():Array {
            return StyleSheetUtil.rgbValue(color);
        }

        public function get colorRGBA():Array {
            var rgba:Array = colorRGB;
            rgba.push(alpha);
            return rgba;
        }

        public function setColor(color:String):void {
            _color = color;
        }

        /*
         * Over color.
         */


        public function get overColor():Number {
            return StyleSheetUtil.colorValue(_overColor);
        }

        public function get overAlpha():Number {
            return StyleSheetUtil.colorAlpha(_overColor);
        }

        public function get overColorRGB():Array {
            return StyleSheetUtil.rgbValue(overColor);
        }

        public function get overColorRGBA():Array {
            var rgba:Array = overColorRGB;
            rgba.push(overAlpha);
            return rgba;
        }

        public function setOverColor(color:String):void {
            _overColor = color;
        }
		

        /*
         * Line color.
         */

        public function setLineColor(color:String):void {
            _lineColor = color;
        }

        public function get lineColor():Number {
            return StyleSheetUtil.colorValue(_lineColor);
        }

        public function get lineAlpha():Number {
            return StyleSheetUtil.colorAlpha(_lineColor);
        }

        public function get lineColorRGB():Array {
            return StyleSheetUtil.rgbValue(lineColor);
        }

        public function get lineColorRGBA():Array {
            var rgba:Array = lineColorRGB;
            rgba.push(lineAlpha);
            return rgba;
        }

        /*
         * Font color.
         */

        public function get fontColor():Number {
            return StyleSheetUtil.colorValue(_fontColor);
        }

        public function setFontColor(color:String):void {
            _fontColor = color;
        }

		/*
		 * Enabled 
		 */
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function setEnabled(value:Boolean):void {
			_enabled = value;
		}
        
    }
}