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
	import org.flowplayer.util.URLUtil;
	
	public class Config {
		
		// max amount of visible items
		private var _emailScriptURL:String;
		private var _emailScriptTokenURL:String;
		private var _emailScriptToken:String;
		private var _emailSubject:String = "Video you might be interested in";
		private var _emailTemplate:String = "{0} \n\n Video Link: <a href=\"{1}\">{2}</a>";
		private var _usePopup:Boolean = true;
		private var _shareTitle:String;
		private var _shareBody:String = "";
		private var _shareCategory:String = "";
		
		private var _baseURL:String = URLUtil.pageUrl;
		
		
		// screen display properties when plugin is shown
		private var _screen:Object = {
	    	left: 0,
			top: 0,
			opacity: 0.8,
			height: "50%",
			width: "50%"
		}
		
		private var _popUpDimensions:Object = {
			facebook: [440,620],
			myspace: [650,1024],
			twitter: [650,1024],
			bebo: [436,626],
			orkut: [650,1024],
			digg: [650,1024],
			stumbleupon: [650,1024],
			livespaces: [650,1024]
		};
		
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
		
		public function get emailScriptTokenURL():String {
			return _emailScriptTokenURL;
		}
		
		public function set emailScriptTokenURL(token:String):void {
			_emailScriptTokenURL = token;
		}
		
		public function get emailScriptToken():String {
			return _emailScriptToken;
		}
		
		public function set emailScriptToken(token:String):void {
			_emailScriptToken = token;
		}
		
		
		public function get emailSubject():String {
			return _emailSubject;
		}
		
		public function set emailSubject(value:String):void {
			_emailSubject = value;
		}
		
		public function set emailTemplate(value:String):void {
			_emailTemplate = value;
		}
		
		public function get emailTemplate():String {
			return _emailTemplate;
		}
		
		public function set usePopup(value:Boolean):void {
			_usePopup = value;
		}
		
		public function get usePopup():Boolean
		{
			return _usePopup;
		}
		
		public function set shareTitle(value:String):void {
			_shareTitle = value;
		}
		
		public function get shareTitle():String {
			return _shareTitle;
		}
		
		public function set shareBody(value:String):void {
			_shareBody = value;
		}
		
		public function get shareBody():String {
			return _shareBody;
		}
		
		public function set shareCategory(value:String):void {
			_shareCategory = value;
		}
		
		public function get shareCategory():String {
			return _shareCategory;
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
		
		public function get baseURL():String {
			return _baseURL;
		}
		
		public function set baseURL(value:String):void {
			_baseURL = value;
		}
		
		public function get popUpDimensions():Object {
			return _popUpDimensions;
		}
	}
}



