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
package org.flowplayer.ui {
    import org.flowplayer.util.StyleSheetUtil;

    public class ButtonConfig {
        private var _color:String;
        private var _overColor:String;

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
            rgba.push(alpha);
            return rgba;
        }

        public function setOverColor(color:String):void {
            _overColor = color;
        }
    }
}