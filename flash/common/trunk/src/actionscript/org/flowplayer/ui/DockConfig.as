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
package org.flowplayer.ui {
    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.model.DisplayPropertiesImpl;
    import org.flowplayer.util.PropertyBinder;

    public class DockConfig {
        private var _displayProperties:DisplayProperties;
        private var _autoHide:AutoHideConfig;
        private var _horizontal:Boolean = false;

        public function DockConfig():void {
            _autoHide = new AutoHideConfig();
            _autoHide.fullscreenOnly = false;
            _autoHide.hideStyle = "fade";
            _autoHide.delay = 2000;
            _autoHide.duration = 1000;
            _displayProperties = new DisplayPropertiesImpl(null, Dock.DOCK_PLUGIN_NAME, false);
            _displayProperties.top = "20%";
            _displayProperties.right = "7%";
            _displayProperties.width = "10%";
            _displayProperties.height = "30%";
        }

        public function get displayProperties():DisplayProperties {
            return _displayProperties;
        }

        public function set displayProperties(value:DisplayProperties):void {
            _displayProperties = value;
        }

        public function get autoHide():AutoHideConfig {
            return _autoHide;
        }

        public function setAutoHide(value:Object):void {
            if (value is String) {
                _autoHide.state = value as String;
                return;
            }
            if (value is Boolean) {
                _autoHide.enabled = value as Boolean;
                _autoHide.fullscreenOnly = Boolean(! value);
                return;
            }
            new PropertyBinder(_autoHide).copyProperties(value);
        }

        public function get horizontal():Boolean {
            return _horizontal;
        }

        public function set horizontal(value:Boolean):void {
            _horizontal = value;
        }
    }
}