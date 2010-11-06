/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.playlist.config
{
    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.model.DisplayPropertiesImpl;
    import org.flowplayer.ui.AutoHideConfig;
    import org.flowplayer.ui.ButtonConfig;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.util.URLUtil;


    public class Config {
        private var _autoHide:AutoHideConfig;
        private var _canvas:Object;
        private var _buttonConfig:ButtonConfig;
        private var _closeButton:ButtonConfig;
        private var _icons:IconConfig = new IconConfig();
        private var _playlistConfig:PlaylistConfig = new PlaylistConfig();
        private var _itemTemplate:String;

        public function Config() {						
            _autoHide = new AutoHideConfig();
            _autoHide.fullscreenOnly = false;
            _autoHide.hideStyle = "fade";
            _autoHide.delay = 2000;
            _autoHide.duration = 1000;
        }

       


        public function get canvas():Object {
            if (! _canvas) {
                _canvas = {
                    backgroundGradient: 'none',
                    border: 'none',
              
                    //borderRadius: 15,
                    //backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    backgroundColor: 'transparent',
                    '.item': {
                        fontSize: 30,
                        color: '#FFFFFF',
                        fontWeight: 'normal',
                        fontFamily: 'Arial',
                        textAlign: 'left'
                        
                    },
                    '.time': {
                    	
                    }
                    
                };
            }
            return _canvas;
        }

        public function set canvas(value:Object):void {
            var canvasConfig:Object = canvas;
            for (var prop:String in value) {
                canvasConfig[prop] = value[prop];
            }
        }

        public function get buttons():ButtonConfig {
            if (! _buttonConfig) {
                _buttonConfig = new ButtonConfig();
                _buttonConfig.setColor("rgba(140,142,140,1)");
                _buttonConfig.setOverColor("rgba(140,142,140,1)");
                _buttonConfig.setFontColor("rgb(255,255,255)");
            }
            return _buttonConfig;
        }

        public function get closeButton():ButtonConfig {
            if (! _closeButton) {
                _closeButton = new ButtonConfig();
                _closeButton.setColor("rgba(80,80,80,0.8)");
                _closeButton.setOverColor("rgba(120,120,120,1)");
            }
            return _closeButton;
        }
        
        public function get items():ButtonConfig {
            if (! _buttonConfig) {                            
                _buttonConfig = new ButtonConfig();
                _buttonConfig.setFontColor("#FFFFFF");
                _buttonConfig.setColor("rgba(140,142,140,1)");
                _buttonConfig.setOverColor("rgba(140,142,140,1)");
                _buttonConfig.setFontColor("rgb(255,255,255)");
                _buttonConfig.setToggleOnColor("#999999");
            }
            return _buttonConfig;
        }

        public function setItems(config:Object):void {
            new PropertyBinder(buttons).copyProperties(config);
        }

        public function setCloseButton(config:Object):void {
            new PropertyBinder(closeButton).copyProperties(config);
        }

        public function get iconButtons():ButtonConfig {
            return _icons.buttons;
        }
        
        public function get playlistButtons():ButtonConfig {
            return _playlistConfig.buttons;
        }

        public function get iconDisplayProperties():DisplayProperties {
            return _icons.displayProps;
        }
        
        public function get playlistDisplayProperties():DisplayProperties {
            return _playlistConfig.displayProps;
        }

        public function set icons(config:Object):void {
            new PropertyBinder(_icons.displayProps).copyProperties(config);
            new PropertyBinder(_icons.buttons).copyProperties(config);
        }
        
        public function set playlists(config:Object):void {
            new PropertyBinder(_playlistConfig.displayProps).copyProperties(config);
            new PropertyBinder(_playlistConfig.buttons).copyProperties(config);
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
        
        public function set itemTemplate(template:String):void {
            _itemTemplate = template;
        }
        
        public function get itemTemplate():String {
            return _itemTemplate;
        }
    }
}



