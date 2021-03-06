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
    import fp.*;

    import org.flowplayer.bwcheck.BitrateProvider;
    import org.flowplayer.bwcheck.HDEvent;
    import org.flowplayer.ui.buttons.ButtonEvent;
    import org.flowplayer.ui.buttons.ToggleButton;
    import org.flowplayer.ui.controllers.AbstractToggleButtonController;

    public class HDToggleController extends AbstractToggleButtonController {

		private var _dockButton:Boolean;
		private var _provider:BitrateProvider;

		public function HDToggleController(dockButton:Boolean, provider:BitrateProvider) {
			super();
			_dockButton = dockButton;
			
			_provider = provider;
			_provider.addEventListener(HDEvent.HD_AVAILABILITY, onHDAvailable);
			_provider.addEventListener(HDEvent.HD_SWITCHED, onHD);
		}
		
		override public function get name():String {
			return "sd";
		}
		
		override public function get defaults():Object {
			return {
				tooltipEnabled: ! _dockButton,
				tooltipLabel: "HD is off",
				visible: true,
				enabled: false
			};
		}

        override protected function setDefaultState():void {
            (_widget as ToggleButton).setToggledColor(false);
        }

		override public function get downName():String {
			return "hd";
		}
		
		override public function get downDefaults():Object {
			return {
				tooltipEnabled: ! _dockButton,
				tooltipLabel: "SD is on",
				visible: true,
				enabled: false
			};
		}

		override protected function get faceClass():Class {
			return _dockButton ? HDDockButton : SDButton;
		}
		
		override protected function get downFaceClass():Class {
            return _dockButton ? HDDockButton : HDButton;
		}
		
		override protected function onButtonClicked(event:ButtonEvent):void {

			log.debug("HD button clicked");
			_provider.hd = ! isDown;
		}
		
		private function onHD(event:HDEvent):void {
			log.debug("Stream switched to HD? "+ event.hasHD);
			(_widget as ToggleButton).isDown = event.hasHD;
            (_widget as ToggleButton).setToggledColor(event.hasHD);
		}
		
		private function onHDAvailable(event:HDEvent):void {
			log.debug("HD Available ? "+ event.hasHD);
			_widget.enabled = event.hasHD;
		}
	}
}
