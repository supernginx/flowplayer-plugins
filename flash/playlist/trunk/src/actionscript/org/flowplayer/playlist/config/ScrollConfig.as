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
package org.flowplayer.playlist.config {
    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.model.DisplayPropertiesImpl;
    import org.flowplayer.ui.ButtonConfig;

    public class ScrollConfig {
        private var _buttons:ButtonConfig;
        private var _displayProps:DisplayProperties;

        public function ScrollConfig() {
            _displayProps = new DisplayPropertiesImpl()
            _displayProps = new DisplayPropertiesImpl(null, "playlist-scroll", false);
            _displayProps.top = "20%";
            _displayProps.left = "7%";
            _displayProps.width = "10";
            _displayProps.height = "150";

            _buttons = new ButtonConfig();
            _buttons.setColor("rgba(20,20,20,0.5)");
            _buttons.setOverColor("rgba(0,0,0,1)");        }

        public function get buttons():ButtonConfig {
            return _buttons;
        }

        public function set buttons(value:ButtonConfig):void {
            _buttons = value;
        }

        public function get displayProps():DisplayProperties {
            return _displayProps;
        }

        public function set displayProps(value:DisplayProperties):void {
            _displayProps = value;
        }
    }
}