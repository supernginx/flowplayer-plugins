/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009-2011 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.ui {
    import flash.display.DisplayObject;

    import flash.display.StageDisplayState;

    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.util.Arrange;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.Flowplayer;

    public class Dock extends AbstractSprite {
        private static var log:Log = new Log("org.flowplayer.ui::Dock");
        public static const DOCK_PLUGIN_NAME:String = "dock";
        private var _icons:Array = [];
        private static var _player:Flowplayer;
        private var _config:DockConfig;
        private var _autoHide:AutoHide;

        /**
         * Creates a new dock.
         * @param player
         * @param config
         * @param pluginName the name used when binding the dock to the plugin registry
         */
        public function Dock(player:Flowplayer, config:DockConfig, pluginName:String) {
            _player = player;

            if (player.config.configObject.hasOwnProperty("plugins") && player.config.configObject["plugins"].hasOwnProperty(pluginName)) {
                var dockConfigObj:Object = player.config.configObject["plugins"][pluginName];
                _config = new PropertyBinder(config || new DockConfig()).copyProperties(dockConfigObj, true) as DockConfig;
                new PropertyBinder(_config.model).copyProperties(dockConfigObj);
            } else {
                _config = config || new DockConfig();
            }
            _config.model.setDisplayObject(this);
            _config.model.name = pluginName;

            player.pluginRegistry.registerDisplayPlugin(_config.model, this);
        }

        /**
         * Gets an instance of the Dock. If an instance already exists in the specified player, this instance is returned.
         * If there is not an existing instance already created a new one is created and registered to the PluginRegistry
         * under name "dock".
         * @param player
         */
        public static function getInstance(player:Flowplayer, config:DockConfig = null):Dock {
            log.debug("getInstance()");
            var plugin:DisplayProperties = player.pluginRegistry.getPlugin(DOCK_PLUGIN_NAME) as DisplayProperties;
            if (! plugin) {
                log.debug("getInstance(), creating new instance");
                return new Dock(player, config, DOCK_PLUGIN_NAME);
            }
            log.debug("getInstance(), returning existing instance");
            return plugin.getDisplayObject() as Dock;
        }

        /**
         * Adds an icon to the dock.
         * @param icon
         * @param id
         */
        public function addIcon(icon:DisplayObject, id:String = null):void {
            _icons.push(icon);
            addChild(icon);
            onResize();
        }

        /**
         * Gets the icons that have been added to this dock.
         */
        public function get icons():Array {
            return _icons;
        }

        public function addToPanel():void {
            log.debug("addToPanel()");
            _player.panel.addView(this, null, _config.model);

            if (_autoHide || ! _config.autoHide.enabled) return;

            log.debug("addToPanel(), creating autoHide with config", _config.autoHide);
            createAutoHide();
        }

        public function startAutoHide():void {
            createAutoHide();
            _autoHide.start();
        }

        private function createAutoHide():void {
            if (! _autoHide) {
                _autoHide = new AutoHide(_config.model, _config.autoHide, _player, stage, this);
            }
        }

        public function stopAutoHide(leaveVisible:Boolean = true):void {
            createAutoHide();
            _autoHide.stop(leaveVisible);
        }

        public function cancelAnimation():void {
            _autoHide.cancelAnimation();
        }

        private function resizeIcons():void {
            _icons.forEach(function(iconObj:Object, index:int, array:Array):void {
                var icon:DisplayObject = iconObj as DisplayObject;
//                var scaleFactor:Number = icon.height/icon.width;
                if (_config.horizontal) {
                    icon.height = height;
//                    icon.width  = height * scaleFactor;
                }
                else {
                    icon.width  = width;
//                    icon.height = width / scaleFactor;
                }
            }, this);
        }

        private function arrangeIcons():void {
            var nextPos:Number = 0;
            _icons.forEach(function(iconObj:Object, index:int, array:Array):void {
                var icon:DisplayObject = iconObj as DisplayObject;
                log.debug("icon " + index + ": " + Arrange.describeBounds(icon));
                if (_config.horizontal) {
                    icon.x = nextPos;
                    icon.y = 0;
                    nextPos += icon.width + _config.gap;
                } else {
                    icon.y = nextPos;
                    icon.x = 0;
                    nextPos += icon.height + _config.gap;
                }
            }, this);
        }

        override protected function onResize():void {
            resizeIcons();
            arrangeIcons();

            // set the managed size based on the last icon's position and size
            var lastIcon:DisplayObject = _icons[_icons.length - 1];
            if (_config.horizontal) {
                _width = lastIcon.x + lastIcon.width;
                _config.model.width = _width;
            } else {
                _height = lastIcon.y + lastIcon.height;
                _config.model.height = _height;
                log.debug("setting height to " + _height)
            }
            _player.pluginRegistry.update(_config.model);
        }

        public function onShow(callback:Function):void {
            _autoHide.onShow(callback);
        }

        public function onHide(callback:Function):void {
            if (! _autoHide) return;
            _autoHide.onHide(callback);
        }

        public function get config():DockConfig {
            return _config;
        }
    }
}
