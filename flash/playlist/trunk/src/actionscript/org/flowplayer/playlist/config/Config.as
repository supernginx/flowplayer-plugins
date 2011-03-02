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
;
    import org.flowplayer.ui.buttons.TooltipButtonConfig;
    import org.flowplayer.ui.buttons.ButtonConfig;
    import org.flowplayer.util.PropertyBinder;


    public class Config {

        private var _canvas:Object;
        private var _iconConfig:IconConfig = new IconConfig();
        private var _closeButtonConfig:ButtonConfig = new ButtonConfig();
        private var _itemConfig:PlaylistItemConfig = new PlaylistItemConfig();
        private var _itemTemplate:String;

        public function Config() {						

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

        public function set icons(config:Object):void {
            new PropertyBinder(_iconConfig.buttons).copyProperties(config);
        }

        public function get iconConfig():TooltipButtonConfig {
            return _iconConfig.buttons;
        }

        public function set items(config:Object):void {
            new PropertyBinder(_itemConfig.buttons).copyProperties(config);
        }

        public function get itemConfig():TooltipButtonConfig {
            return _itemConfig.buttons;
        }

         public function get closeButton():ButtonConfig {
            if (! _closeButtonConfig) {
                _closeButtonConfig = new ButtonConfig();
                _closeButtonConfig.setColor("rgba(80,80,80,0.8)");
                _closeButtonConfig.setOverColor("rgba(120,120,120,1)");
            }
            return _closeButtonConfig;
        }

        public function setCloseButton(config:Object):void {
            new PropertyBinder(closeButton).copyProperties(config);
        }
        
        public function set itemTemplate(template:String):void {
            _itemTemplate = template;
        }
        
        public function get itemTemplate():String {
            return _itemTemplate;
        }
    }
}



