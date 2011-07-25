/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <api@iki.fi>
 *
 * Copyright (c) 2008-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.menu {
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.utils.Timer;

    import org.flowplayer.menu.ui.ItemView;
    import org.flowplayer.menu.ui.MenuButtonController;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.DisplayPluginModelImpl;
    import org.flowplayer.model.PlayerEvent;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.ui.Dock;
    import org.flowplayer.ui.DockConfig;
    import org.flowplayer.ui.buttons.LabelButton;
    import org.flowplayer.ui.containers.WidgetContainer;
    import org.flowplayer.ui.containers.WidgetContainerEvent;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.Flowplayer;

    public class Menu implements Plugin {
        private static const MENU_PLUGIN_NAME:String = "fp_menu";

        private var log:Log = new Log(this);
        private var _config:Config;
        private var _dock:Dock;
        private var _player:Flowplayer;
        private var _model:PluginModel;
        private var _positionConfigured:Boolean;

        /**
         * Adds menu items.
         * @param items
         */
        [External]
        public function addItems(items:Array):void {
            _config.items = items;
            createItems();
        }

        public function onConfig(model:PluginModel):void {
            _model = model;
            _config = new PropertyBinder(new Config()).copyProperties(model.config) as Config;
        }

        public function onLoad(player:Flowplayer):void {
            _player = player;

            var dockConfObj:Object = player.config.configObject.dock;
            log.debug("onLoad(), dock conf", dockConfObj);
            _positionConfigured = dockConfObj && (
                    dockConfObj.hasOwnProperty("left") ||
                    dockConfObj.hasOwnProperty("right") ||
                    dockConfObj.hasOwnProperty("top") ||
                    dockConfObj.hasOwnProperty("bottom"));


            createDock();
            createMenuButton(player);

            if (! _config.button.dockedOrControls) {
                log.debug("onLoad(), will add dock to panel");
                _player.onLoad(function(event:PlayerEvent):void {
                    _dock.addToPanel();
                });
            }

            addListeners();
            _model.dispatchOnLoad();
        }

        public function getDefaultConfig():Object {
            return null;
        }

        private function createMenuButton(player:Flowplayer):void {
            if (! _config.button.dockedOrControls) return;

            if (_config.button.controls) {
                log.debug("onLoad() adding menu button to controls");
                var controlbar:* = player.pluginRegistry.plugins['controls'];
                controlbar.pluginObject.addEventListener(WidgetContainerEvent.CONTAINER_READY, addControlsMenuButton);
            }
        }

        private function addControlsMenuButton(event:WidgetContainerEvent):void {
            log.debug("addControlsMenuButton()");
            var container:WidgetContainer = event.container;
            var controller:MenuButtonController = new MenuButtonController(_dock);
            container.addWidget(controller, "time", false);

            if (! _positionConfigured) {
                _dock.config.model.position.leftValue = controller.view.x;
                _dock.config.model.position.topValue = DisplayObject(container).y - _dock.height;
                log.debug("addControlsMenuButton(), menu position adjusted to " + _dock.config.model.position);
                _player.pluginRegistry.updateDisplayProperties(_dock.config.model, true);
            }
        }

        private function createDock():void {
            log.debug("createDock()");
            var config:DockConfig = new DockConfig();
            var model:DisplayPluginModel = new DisplayPluginModelImpl(null, Dock.DOCK_PLUGIN_NAME, false);

            model.left =  15;
            model.top =  15;

            config.model = model;
            config.gap = 0;

            if (_config.button.dockedOrControls) {
                log.debug("createDock() using a menu button, disabling autoHide");
//                config.autoHide.enabled = false;
                config.model.display = "none";
            }

            _dock = new Dock(_player, config, MENU_PLUGIN_NAME);
            if (_config.button.dockedOrControls) {
                _dock.alpha = 0;
            }
            createItems();
        }

        private function createItems():void {
            log.debug("createItems(), creating " + _config.items.length + " menu items");
            for (var i:uint = 0; i < _config.items.length; i++) {
                createItem(_config.items[i] as ItemConfig, i);
            }
        }

        private function createItem(itemConfig:ItemConfig, tabIndex:uint):void {
            log.debug("createItem(), itemConfig == " + itemConfig + ", dock == " + _dock);
            var item:ItemView = new ItemView(itemConfig.label, itemConfig, _player.animationEngine);
            item.tabEnabled = true;
            item.tabIndex = tabIndex;
            item.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                itemConfig.fireCallback(_model);
                _player.animationEngine.fadeOut(_dock);
            });

            if (_dock.config.horizontal) {
                item.width = itemConfig.width;
            } else {
                item.height = itemConfig.height;
            }

            _dock.addIcon(item);
        }

        private function addListeners():void {
            _dock.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
            _dock.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
        }

        private function onRollOut(event:MouseEvent):void {
//            var hideTimer:Timer = new Timer();
            log.debug("onRollOut()");
            _dock.startAutoHide();
            _dock.onHide(onDockHidden);
        }

        private function onRollOver(event:MouseEvent):void {
//            _dock.stopAutoHide(true);
        }

        private function onDockHidden():void {
            log.debug("onDockHidden()");
            _dock.onHide(null);
            _dock.stopAutoHide(false);
        }

    }
}
