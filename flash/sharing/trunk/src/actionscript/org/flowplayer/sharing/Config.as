/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.sharing {
    import org.flowplayer.ui.ButtonConfig;
    import org.flowplayer.util.PropertyBinder;

    public class Config {
        private var _buttons:ButtonConfig;

        public function Config() {
            _buttons = new ButtonConfig();
            _buttons.setColor("rgba(20,20,20,0.5)");
            _buttons.setOverColor("rgba(0,0,0,1)");
        }

        public function get buttons():ButtonConfig {
            return _buttons;
        }

        public function setButtons(config:Object):void {
            new PropertyBinder(_buttons).copyProperties(config);
        }
    }
}