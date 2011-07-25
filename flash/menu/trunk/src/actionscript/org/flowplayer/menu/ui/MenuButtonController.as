/*
 * Author: Anssi Piirainen, api@iki.fi
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.menu.ui {

    import flash.display.DisplayObject;

    import fp.MenuButton;

    import org.flowplayer.ui.Dock;

    import org.flowplayer.ui.buttons.ButtonEvent;
    import org.flowplayer.ui.controllers.AbstractButtonController;

    public class MenuButtonController extends AbstractButtonController {
        private var _menu:Dock;

		public function MenuButtonController(menu:Dock) {
            _menu = menu;
		}
		
		override public function get name():String {
			return "menu";
		}

		override public function get defaults():Object {
			return {
				tooltipEnabled: true,
				tooltipLabel: "Menu",
				visible: true,
				enabled: true
			};
		}

		override protected function get faceClass():Class {
			// we could have return fp.NextButton but we need it as string for skinless controls
			return MenuButton;
		}
		
		override protected function onButtonClicked(event:ButtonEvent):void {
            if (_menu.alpha == 0 || ! _menu.visible) {
                _player.animationEngine.fadeIn(_menu);
            } else {
                _player.animationEngine.fadeOut(_menu);
            }
		}
	}
}

