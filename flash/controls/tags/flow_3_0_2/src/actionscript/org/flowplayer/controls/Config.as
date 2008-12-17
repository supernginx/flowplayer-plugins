/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 * Copyright (c) 2008 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls {
	import org.flowplayer.util.Log;	
	import org.flowplayer.util.PropertyBinder;	
	
	/**
	 * @author api
	 */
	public class Config {
		private var log:Log = new Log(this);
		private var _style:Style;
		private var _autoHide:String = "fullscreen"; // never | fullscreen | always
		private var _hideDelay:Number = 4000;
		private var _visibilities:Object = new Object();
		private var _visibilityProperties:Array = ["play", "stop", "mute", "volume", "time", "scrubber", "playlist", "fullscreen"];

		public function resetVisibilities():void {
			_visibilities = new Object();
		}
		
		public function get autoHide():String {
			return _autoHide;
		}
		
		public function set autoHide(autoHide:String):void {
			_autoHide = autoHide;
		}
		
		public function get play():Boolean {
			return visibility("play");
		}
		
		private function visibility(prop:String, defaultVal:Boolean = true):Boolean {
			if (_visibilities[prop] == undefined) return defaultVal;
			return _visibilities[prop];
		}

		public function set play(play:Boolean):void {
			_visibilities["play"] = play;
		}

		public function get volume():Boolean {
			return visibility("volume");
		}

		public function set volume(volume:Boolean):void {
			_visibilities["volume"] = volume;
		}
		
		public function get mute():Boolean {
			return visibility("mute");
		}

		public function set mute(mute:Boolean):void {
			_visibilities["mute"] = mute;
		}

		public function get time():Boolean {
			return visibility("time");
		}

		public function set time(time:Boolean):void {
			_visibilities["time"] = time;
		}
		
		public function get scrubber():Boolean {
			return visibility("scrubber");
		}

		public function set scrubber(scrubber:Boolean):void {
			_visibilities["scrubber"] = scrubber;
		}

		public function get stop():Boolean {
			return visibility("stop", false);
		}

		public function set stop(stop:Boolean):void {
			_visibilities["stop"] = stop;
		}
		
		public function get playlist():Boolean {
			return visibility("playlist", false);
		}

		public function set playlist(playlist:Boolean):void {
			_visibilities["playlist"] = playlist;
		}
		
		public function get fullscreen():Boolean {
			return visibility("fullscreen");
		}

		public function set fullscreen(fullscreen:Boolean):void {
			_visibilities["fullscreen"] = fullscreen;
		}
		
		public function set all(visible:Boolean):void {
			for (var i:Number = 0;i < _visibilityProperties.length; i++) {
				if (_visibilities[_visibilityProperties[i]] == undefined) {
					_visibilities[_visibilityProperties[i]] = visible;
				}
			}
		}				public function get style():Style {
			return _style || new Style();		}				public function addStyleProps(styleProps:Object):void {
			_style = new PropertyBinder(style, "bgStyle").copyProperties(styleProps) as Style;		}		
		public function get hideDelay():Number {
			return _hideDelay;
		}
		
		public function set hideDelay(hideDelay:Number):void {
			_hideDelay = hideDelay;
		}
	}
}
