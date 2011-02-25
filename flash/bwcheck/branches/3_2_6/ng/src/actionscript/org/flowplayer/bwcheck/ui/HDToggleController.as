/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.bwcheck.ui {
    
	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.model.PlayerEvent;
	import org.flowplayer.model.ClipEvent;
	
	import org.flowplayer.ui.controllers.AbstractToggleButtonController;
	import org.flowplayer.ui.buttons.ToggleButtonConfig;
	import org.flowplayer.ui.buttons.ButtonEvent;
	import org.flowplayer.ui.buttons.ToggleButton;
	
	import org.flowplayer.bwcheck.HDEvent;
	import org.flowplayer.bwcheck.BitrateProvider;
	
	import flash.display.DisplayObjectContainer;
	
	import fp.*;
	
	public class HDToggleController extends AbstractToggleButtonController {

		private var _isIcon:Boolean;
		private var _provider:BitrateProvider;

		public function HDToggleController(isIcon:Boolean, provider:BitrateProvider) {
			super();
			_isIcon = isIcon;
			
			_provider = provider;
			_provider.addEventListener(HDEvent.HD_AVAILABILITY, onHDAvailable);
			_provider.addEventListener(HDEvent.HD_SWITCHED, onHD);
		}
		
		override public function get name():String {
			return "hd";
		}
		
		override public function get defaults():Object {
			return {
				tooltipEnabled: ! _isIcon,
				tooltipLabel: "High Quality",
				visible: true,
				enabled: false
			};
		}
		
		override public function get downName():String {
			return "sd";
		}
		
		override public function get downDefaults():Object {
			return {
				tooltipEnabled: ! _isIcon,
				tooltipLabel: "Standard Quality",
				visible: true,
				enabled: false
			};
		}

		// get it included in swc
		override protected function get faceClass():Class {
			return _isIcon ? fp.HDIcon : fp.HDButton;
		}
		
		override protected function get downFaceClass():Class {
			return _isIcon ? fp.SDIcon : fp.SDButton;
		}
		
		override protected function onButtonClicked(event:ButtonEvent):void {
			log.debug("HD button clicked");
			_provider.hd = ! isDown;
		}
		
		private function onHD(event:HDEvent):void {
			log.debug("Stream switched to HD ? "+ event.hasHD);
			(_widget as ToggleButton).isDown = event.hasHD;
		}
		
		private function onHDAvailable(event:HDEvent):void {
			log.debug("HD Available ? "+ event.hasHD);
			_widget.enabled = event.hasHD;
		}
	}
}
