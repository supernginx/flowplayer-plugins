/*    
 *    Copyright (c) 2008-2011 Flowplayer Oy *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    Flowplayer is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with Flowplayer.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.flowplayer.model {
	import org.flowplayer.model.DisplayPropertiesImpl;

	/**
	 * @author api
	 */
	public class BufferingOverlay extends DisplayPluginModelImpl {


        private var _backgroundColor:String;
        private var _backgroundAlpha:Number;
        private var _backgroundMaskColor:String;
        private var _backgroundMaskAlpha:Number;
        private var _animationInterval:Number;

		public function BufferingOverlay() {
			super(null, "buffering", false);

			backgroundColor = "#FFFFFF";
            backgroundAlpha = 0.5;
            backgroundMaskAlpha = 1;
            animationInterval = 200;

		}

        override public function clone():Cloneable {
            var copy:BufferingOverlay = new BufferingOverlay();
            copyFields(this, copy);
            copy.backgroundColor = this.backgroundColor;
            copy.backgroundMaskColor = this.backgroundMaskColor;
            copy.backgroundAlpha = this.backgroundAlpha;
            copy.backgroundMaskAlpha = this.backgroundMaskAlpha;
            copy.animationInterval = this.animationInterval;
            return copy;
        }

        [Value]
		public function get animationInterval():Number {
			return _animationInterval;
		}

		public function set animationInterval(value:Number):void {
			_animationInterval = value;
		}

        [Value]
		public function get backgroundAlpha():Number {
			return _backgroundAlpha;
		}

		public function set backgroundAlpha(value:Number):void {
			_backgroundAlpha = value;
		}

        [Value]
		public function get backgroundMaskAlpha():Number {
			return _backgroundMaskAlpha;
		}

		public function set backgroundMaskAlpha(value:Number):void {
			_backgroundMaskAlpha = value;
		}
		
        [Value]
		public function get backgroundColor():String {
			return _backgroundColor;
		}
		
		public function set backgroundColor(value:String):void {
			_backgroundColor = value;
		}

        [Value]
		public function get backgroundMaskColor():String {
			return _backgroundMaskColor;
		}

		public function set backgroundMaskColor(value:String):void {
			_backgroundMaskColor = value;
		}
	}
}
