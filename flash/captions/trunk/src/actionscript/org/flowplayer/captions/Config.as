/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2008 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
 
package org.flowplayer.captions
{
	public class Config {
		private var _captions:Array = new Array();
		private var _autoLayout:Boolean = true;
		private var _simpleFormatting:Boolean = false;
		private var _showCaptions:Boolean = true;
		private var _captionTarget:String;
		private var _template:String;
		
		public function get captions():Array {
			return _captions;
		}
		
		public function set captions(captions:Array):void {
			_captions = captions;
		}
		
		public function get captionTarget():String {
			return _captionTarget;
		}
		
		public function set captionTarget(captionTarget:String):void {
			_captionTarget = captionTarget;
		}
		
		public function get template():String {
			return _template;
		}
		
		public function set template(template:String):void {
			_template = template;
		}
		
		public function get autoLayout():Boolean {
			return _autoLayout;
		}
		
		public function set autoLayout(autoLayout:Boolean):void {
			_autoLayout = autoLayout;
		}
		
		public function get simpleFormatting():Boolean {
			return _simpleFormatting;
		}
		
		public function set simpleFormatting(simpleFormatting:Boolean):void {
			_simpleFormatting = simpleFormatting;
		}
		
		public function get showCaptions():Boolean {
			return _showCaptions;
		}
		
		public function set showCaptions(showCaptions:Boolean):void {
			_showCaptions = showCaptions;
		}
	}
}



