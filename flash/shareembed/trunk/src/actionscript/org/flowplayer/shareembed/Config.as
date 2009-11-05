/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
 
package org.flowplayer.shareembed
{
	public class Config {
		
		// max amount of visible items
		private var _emailScriptURL:String = "email.php";
		private var _emailSubject:String = "Video you might be interested in";
		
		
		// screen display properties when plugin is shown
		private var _screen:Object = {
	    	left: 0,
			top: 0,
			opacity: 0.8,
			height: "50%",
			width: "50%"
		}
		
		private var _style:Object = {
			body: { 
				fontSize: 14, 
				fontWeight: 'normal',
				fontFamily: 'Arial',
				left: 0,
				bottom: 0,
				textAlign: 'left',
				color: '#ffffff'
			},
			title: {
				fontSize: 23	
			},
			label: {
				fontSize: 12	
			},
			input: {
				fontSize: 12
			},
			small: {
				fontSize: 8		
			}
		}
		

		public function get emailScriptURL():String {
			return _emailScriptURL;
		}
		
		public function set emailScriptURL(url:String):void {
			_emailScriptURL = url;
		}
		
		public function get emailSubject():String {
			return _emailSubject;
		}
		
		public function set emailSubject(url:String):void {
			_emailSubject = url;
		}
		
	
		public function get screen():Object {
			return _screen;
		}
		
		public function set screen(screen:Object):void {
			_screen = screen;
		}
		
		public function get style():Object {
			return _screen;
		}
		
		public function set style(style:Object):void {
			_style = style;
		}
		
		
	}
}



