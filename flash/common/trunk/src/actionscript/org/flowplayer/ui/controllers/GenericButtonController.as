/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.ui.controllers {
    
	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.view.AbstractSprite;
	import org.flowplayer.model.Clip;
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.Status;
	
	import org.flowplayer.ui.buttons.GenericTooltipButton;
	import org.flowplayer.ui.buttons.TooltipButtonConfig;
	import org.flowplayer.ui.buttons.ButtonEvent;
	
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	import flash.display.DisplayObjectContainer;
	

	public class GenericButtonController extends AbstractButtonController {
		
		private var _name:String;
		private var _face:Class;
		private var _callback:Function;
		private var _defaults:Object;
		
		public function GenericButtonController(name:String, face:Class, defaults:Object = null, callback:Function = null) {
			super();
			
			_name 		= name;
			_face 		= face;
			_defaults	= defaults || {
				enabled: true,
				visible: true,
				tooltipEnabled : false,
				tooltipLabel: null
			};
			_callback 	= callback;
		}
		
	
		override protected function addWidgetListeners():void {
			_widget.addEventListener(ButtonEvent.CLICK, _callback ? _callback : onButtonClicked);
		}
				
		protected function get name():String {
			return _name;
		}
		
		protected function get faceClass():Class {
			return _face
		}
	}
}

