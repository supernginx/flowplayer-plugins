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
    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.DisplayPluginModelImpl;
    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.model.DisplayPropertiesImpl;
    import org.flowplayer.util.PropertyBinder;

    public class DockConfig {
        private var _model:DisplayPluginModel;
        private var _autoHide:AutoHideConfig;
        private var _horizontal:Boolean = false;

        public function DockConfig():void {
            _autoHide = new AutoHideConfig();
            _autoHide.fullscreenOnly = false;
            _autoHide.hideStyle = "fade";
            _autoHide.delay = 2000;
            _autoHide.duration = 1000;

            _model = new DisplayPluginModelImpl(null, Dock.DOCK_PLUGIN_NAME, false);
            _model.top = "20%";
            _model.right = "7%";
            _model.width = "10%";
            _model.height = "30%";
        }

        public function get model():DisplayPluginModel {
            return _model;
        }

        public function set model(value:DisplayPluginModel):void {
            _model = value;
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