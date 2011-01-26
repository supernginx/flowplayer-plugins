/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.controls.controllers {
    
	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.view.AbstractSprite;
	import org.flowplayer.model.Clip;
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.Status;
	
	import org.flowplayer.controls.buttons.SurroundedButton;
	
	import org.flowplayer.ui.buttons.TooltipButtonConfig;
	import org.flowplayer.ui.buttons.GenericTooltipButton;
	import org.flowplayer.ui.buttons.ButtonConfig;
	import org.flowplayer.ui.buttons.ToggleButton;
	import org.flowplayer.ui.buttons.ToggleButtonConfig;
	
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	import flash.display.DisplayObjectContainer;
	

	public class AbstractToggleButtonController extends AbstractButtonController {
			
		public function AbstractToggleButtonController(config:ToggleButtonConfig, player:Flowplayer, controlbar:DisplayObjectContainer) {
			super(config, player, controlbar);
			setDefaultState();
		}
		
		
		
		override public function configure(config:Object):void {
			_config = config;
												
			view.configure(_config);
		}

		override protected function createWidget():void {
			var button:SurroundedButton = new SurroundedButton(
					new GenericTooltipButton(	name, 
												new faceClass(), 
												((_config as ToggleButtonConfig).config as TooltipButtonConfig), 
												_player.animationEngine));
												
			var downButton:SurroundedButton = new SurroundedButton(
					new GenericTooltipButton(	downName, 
												new downFaceClass(), 
												((_config as ToggleButtonConfig).downConfig as TooltipButtonConfig), 
												_player.animationEngine));
			
			_widget = new ToggleButton(button, downButton);
		}
		
		public function get downName():String {
			return Object(this).constructor['DOWN_NAME'];
		}
		
	
		/* This is what you should override */
		protected function get downFaceClass():Class {
			throw new Error("You need to override downFaceClass accessor");
			return Object;
		}

		protected function setDefaultState():void {
			// do something here ... or not
		}
	}
}

