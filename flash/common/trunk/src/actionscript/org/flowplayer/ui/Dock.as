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

        public function Dock(config:DockConfig) {
            _config = config;;
            _config.model.setDisplayObject(this);
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
                return createDock(player, config);
            }
            log.debug("getInstance(), returning existing instance");
            return plugin.getDisplayObject() as Dock;
        }

        public function addIcon(icon:DisplayObject, id:String = null):void {
            _icons.push(icon);
            addChild(icon);
        }

        public function addToPanel():void {
            log.debug("addToPanel()");
            _player.panel.addView(this, null, _config.model);

            if (_autoHide || ! _config.autoHide.enabled) return;

            log.debug("addToPanel(), creating autoHide with config", _config.autoHide);
            _autoHide = new AutoHide(_config.model, _config.autoHide, _player, stage, this);
        }

        public function startAutoHide():void {
            _autoHide.start();
        }

        public function stopAutoHide(leaveVisible:Boolean = true):void {
            _autoHide.stop(leaveVisible);
        }

        public function cancelAnimation():void {
            _autoHide.cancelAnimation();
        }

        private static function createDock(player:Flowplayer, config:DockConfig):Dock {
            log.debug("createDock()");
            var config:DockConfig;
            if (player.config.configObject.hasOwnProperty("plugins") && player.config.configObject["plugins"].hasOwnProperty(DOCK_PLUGIN_NAME)) {
                var dockConfigObj:Object = player.config.configObject["plugins"][DOCK_PLUGIN_NAME];
                config = new PropertyBinder(config || new DockConfig()).copyProperties(dockConfigObj, true) as DockConfig;
                new PropertyBinder(config.model).copyProperties(dockConfigObj);
            } else {
                config = config || new DockConfig();
            }

            var dock:Dock = new Dock(config);
            player.pluginRegistry.registerDisplayPlugin(config.model, dock);
            _player = player;
            return dock;
        }

        private function resizeIcons():void {
            _icons.forEach(function(iconObj:Object, index:int, array:Array):void {
                var icon:DisplayObject = iconObj as DisplayObject;
                icon.height = icon.width = _config.horizontal ? height : width;
            }, this);
        }

        private function arrangeIcons():void {
            var nextPos:Number = 0;
            _icons.forEach(function(iconObj:Object, index:int, array:Array):void {
                var icon:DisplayObject = iconObj as DisplayObject;
                if (_config.horizontal) {
                    icon.x = nextPos;
                    icon.y = 0;
                    nextPos += icon.width + 5;
                } else {
                    icon.y = nextPos;
                    icon.x = 0;
                    nextPos += icon.height + 5;
                }
            }, this);
        }

        override protected function onResize():void {
            log.debug("onResize() " + width + " x " + height + ", is fullscreen? " + (stage.displayState == StageDisplayState.FULL_SCREEN));

            var props:DisplayProperties = _player.pluginRegistry.getPluginByDisplay(this);
            log.debug("onResize() current dimensions " + props.dimensions);
            resizeIcons();
            arrangeIcons();

        }

        public function onShow(callback:Function):void {
            _autoHide.onShow(callback);
        }

        public function onHide(callback:Function):void {
            _autoHide.onHide(callback);
        }
    }
}