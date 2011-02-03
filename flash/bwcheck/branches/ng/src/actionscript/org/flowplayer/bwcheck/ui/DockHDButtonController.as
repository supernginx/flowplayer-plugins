/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2010 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.bwcheck.ui {
    import org.flowplayer.bwcheck.BitrateProvider;
    import org.flowplayer.bwcheck.assets.HDToggleOff;
    import org.flowplayer.bwcheck.assets.HDToggleOn;
    import org.flowplayer.ui.buttons.ButtonEvent;
    import org.flowplayer.ui.controllers.AbstractToggleButtonController;

    public class DockHDButtonController extends AbstractToggleButtonController {
        private var _provider:BitrateProvider;

        public function DockHDButtonController(provider:BitrateProvider)
        {
            _provider = provider;
        }

        override public function get name():String
        {
            return "dock-hd";
        }

        override public function get defaults():Object
        {
            return {
                tooltipEnabled: true,
                tooltipLabel: "HD on",
                visible: true,
                enabled: true
            };
        }

        override public function get downName():String
        {
            return "hd";
        }

        override public function get downDefaults():Object
        {
            return {
                tooltipEnabled: false,
                tooltipLabel: "HD off",
                visible: true,
                enabled: true
            };
        }

        // get it included in swc
        override protected function get faceClass():Class
        {
            return HDToggleOff;
        }

        override protected function get downFaceClass():Class
        {
            return HDToggleOn;
        }

        override protected function onButtonClicked(event:ButtonEvent):void
        {
			var down:Boolean = ! isDown;
            log.error("onButtonClicked(), button down? " + down + ", can switch? " + _provider.canSwitchToHD());

            if (down && ! _provider.canSwitchToHD()) {
                isDown = false;
                return;
            }

			isDown = down;
            _provider.hd = down;
        }

    }
}