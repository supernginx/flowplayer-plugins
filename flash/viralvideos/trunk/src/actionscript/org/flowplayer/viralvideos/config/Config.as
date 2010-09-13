/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.viralvideos.config
{
    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.model.DisplayPropertiesImpl;
    import org.flowplayer.ui.AutoHideConfig;
    import org.flowplayer.ui.ButtonConfig;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.util.URLUtil;
    import org.flowplayer.viralvideos.PlayerEmbed;

    public class Config {
        private var _email:EmailConfig = new EmailConfig();
        private var _share:ShareConfig = new ShareConfig();
        private var _embed:EmbedConfig = new EmbedConfig();
        private var _autoHide:AutoHideConfig;
        private var _canvas:Object;
        private var _buttonConfig:ButtonConfig;
        private var _closeButton:ButtonConfig;
        private var _icons:IconConfig = new IconConfig();
        private var _shareCurrentPlaylistItem:Boolean;

        public function Config() {						
            _autoHide = new AutoHideConfig();
            _autoHide.fullscreenOnly = false;
            _autoHide.hideStyle = "fade";
            _autoHide.delay = 2000;
            _autoHide.duration = 1000;
        }
        
        public function get shareCurrentPlaylistItem():Boolean {
            return _shareCurrentPlaylistItem;
        }
        
        public function set shareCurrentPlaylistItem(value:Boolean):void {
            _shareCurrentPlaylistItem = value;
        }

        public function get email():EmailConfig {
            return _email;
        }

        public function setEmail(value:Object):void {
            if (! value) {
                _email = null;
                return;
            }
            if (! _email) {
                _email = new EmailConfig();
            }
            if (value is Boolean) {
                return;
            }
            new PropertyBinder(_email).copyProperties(value);
        }

        public function get share():ShareConfig {
            return _share;
        }

        public function setShare(value:Object):void {
            if (! value) {
                _share = null;
                return;
            }
            if (! _share) {
                _share = new ShareConfig();
            }
            if (value is Boolean) {
                return;
            }
            new PropertyBinder(_share).copyProperties(value);
        }

        public function get embed():EmbedConfig {
            return _embed;
        }

        public function setEmbed(value:Object):void {
            if (! value) {
                _embed = null;
                return;
            }
            if (! _embed) {
                _embed = new EmbedConfig();
            }
            if (value is Boolean) {
                return;
            }
            new PropertyBinder(_embed).copyProperties(value);
        }

        public function get canvas():Object {
            if (! _canvas) {
                _canvas = {
                    backgroundGradient: 'medium',
                    border: 'none',
                    borderRadius: 15,
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    
                    '.title': {
                        fontSize: 12,
                        fontWeight: 'bold'
                    },
                    '.label': {
                        fontSize: 12
                    },
                    '.input': {
                        fontSize: 12,
                        color: '#000000',
                        backgroundColor: '#ffffff'
                    },
                    '.small': {
                        fontSize: 8
                    },
                    '.error': {
                        color: '#ff3333',
                        fontSize: 10,
                        fontWeight: 'normal',
                        fontFamily: 'Arial'
                    },
                    '.success': {
                        color: '#000000',
                        fontSize: 10,
                        fontWeight: 'normal',
                        fontFamily: 'Arial'
                    },
                    '.embed': {
                        color: '#000000',
                        fontSize: 6,
                        fontWeight: 'normal',
                        fontFamily: 'Arial',
                        textAlign: 'left'
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
                _buttonConfig.setFontColor("rgb(255,255,255)")
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

        public function setButtons(config:Object):void {
            new PropertyBinder(buttons).copyProperties(config);
        }

        public function setCloseButton(config:Object):void {
            new PropertyBinder(closeButton).copyProperties(config);
        }

        public function get iconButtons():ButtonConfig {
            return _icons.buttons;
        }

        public function get iconDisplayProperties():DisplayProperties {
            return _icons.displayProps;
        }
//
//        public function set iconProperties(config:Object):void {
//
//        	var props:DisplayProperties = iconDisplayProperties;
//        	if (config.top) props.top = config.top;
//            if (config.right) props.right = config.right;
//            if (config.left) props.left = config.left;
//            if (config.width) props.width = config.width;
//            if (config.height) props.height = config.height;
//            _iconDisplayProperties = props;
//        }

        public function set icons(config:Object):void {
            new PropertyBinder(_icons.displayProps).copyProperties(config);
            new PropertyBinder(_icons.buttons).copyProperties(config);
        }

        public function set playerEmbed(embed:PlayerEmbed):void {
            if (! _embed) return;
            _embed.playerEmbed = embed;
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
    }
}



