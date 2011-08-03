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
package org.flowplayer.menu.ui {
    import flash.filters.DropShadowFilter;

    import org.flowplayer.menu.*;
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.utils.Timer;

    import org.flowplayer.menu.ui.MenuItem;
    import org.flowplayer.menu.ui.MenuButtonController;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.DisplayPluginModelImpl;
    import org.flowplayer.model.PlayerEvent;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginEvent;
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
        private static const MENU_PLUGIN_NAME:String = "menudock";

        private var log:Log = new Log(this);
        private var _config:MenuConfig;
        private var _dock:Dock;
        private var _player:Flowplayer;
        private var _model:PluginModel;
        private var _menuButtonController:MenuButtonController;
        private var _menuButtonContainer:WidgetContainer;

        /**
         * Adds menu items.
         * @param items an array of MenuConfig instances
         */
        public function addItems(items:Array):void {
            _config.items = items;
            createItems();
        }

        /**
         * Adds an item to the menu.
         * @param itemConf and Object with with properties for a ItemConfig object. Or an instance of ItemConfig.
         * @return the index of the item the item in the menu, zero based
         */
        public function addItem(itemConf:Object):int {
            var itemConfig:ItemConfig = _config.addItem(itemConf);
            log.debug("addItem(), color == " + itemConfig.color + ", overColor == " + itemConfig.overColor);
            createItem(itemConfig);
            if (_menuButtonContainer) {
                adjustDockPosition();
            }
            return _config.items.indexOf(itemConfig);
        }

        [External]
        public function enableItems(enabled:Boolean,  items:Array = null):void {
            var itemViews:Array = _dock.icons;
            for (var i:int; i < itemViews.length; i++) {
                var view:MenuItem = itemViews[i];
                if (! items || (items && items.indexOf(i) >= 0)) {
                    view.enabled = enabled;
                }
            }
        }

        public function onConfig(model:PluginModel):void {
            _model = model;
            _config = new PropertyBinder(new MenuConfig()).copyProperties(model.config) as MenuConfig;
            new PropertyBinder(_config.displayProps).copyProperties(model.config) as MenuConfig;
            log.debug("config", _config.items);
        }

        public function onLoad(player:Flowplayer):void {
            _player = player;
            createDock();
            createMenuButton(player);

            if (! _config.button.dockedOrControls) {
                log.debug("onLoad(), will add dock to panel");
                _player.onLoad(function(event:PlayerEvent):void {
                    _dock.addToPanel();
                });
            }

            _model.dispatchOnLoad();
        }

        private function get horizontalPosConfigured():Boolean {
            var confObj:Object = _model.config;
            return confObj && (confObj.hasOwnProperty("left") || confObj.hasOwnProperty("right"));
        }

        private function get verticalPosConfigured():Boolean {
            var confObj:Object = _model.config;
            return confObj && (confObj.hasOwnProperty("top") || confObj.hasOwnProperty("bottom"));
        }

        public function getDefaultConfig():Object {
            return null;
        }

        private function createMenuButton(player:Flowplayer):void {
            if (! _config.button.dockedOrControls) return;

            if (_config.button.controls) {
                log.debug("onLoad() adding menu button to controls");
                var controlbar:* = player.pluginRegistry.plugins['controls'];

                // TODO: Container events should follow the same pattern as player, clip and plugin events
                controlbar.pluginObject.addEventListener(WidgetContainerEvent.CONTAINER_READY, addControlsMenuButton);

                PluginModel(controlbar).onPluginEvent(function(event:PluginEvent):void {
                            log.debug("onPluginEvent: " + event.id);
                            var lastItem:MenuItem = _dock.icons[_dock.icons.length - 1];
                            if (event.id == "onHidden") {
                                lastItem.roundBottom = true;
                            }
                            if (event.id == "onShowed") {
                                lastItem.roundBottom = false;
                            }
                        }
                );
            }
        }

        private function addControlsMenuButton(event:WidgetContainerEvent):void {
            log.debug("addControlsMenuButton()");
            _menuButtonContainer = event.container;
            _menuButtonController = new MenuButtonController(_dock);
            _menuButtonContainer.addWidget(_menuButtonController, "time", false);
            adjustDockPosition();
        }

        private function adjustDockPosition():void {
            if (horizontalPosConfigured && verticalPosConfigured) return;

            if (! horizontalPosConfigured) {
                _dock.config.model.position.leftValue = _menuButtonController.view.x;
            }
            if (! verticalPosConfigured) {
                _dock.config.model.position.topValue = DisplayObject(_menuButtonContainer).y - _dock.height;
            }
            log.debug("addControlsMenuButton(), menu position adjusted to " + _dock.config.model.position);
            _player.pluginRegistry.updateDisplayProperties(_dock.config.model, true);
        }

        private function createDock():void {
            log.debug("createDock()");
            var config:DockConfig = new DockConfig();
            config.model = _config.displayProps;
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

            // distance, angle, color, alpha, blurX, blurY, strength,quality,inner,knockout ) all as type Number accept 'inner','knockout' and 'hideObject' (as Boolean).
            _dock.filters = [new DropShadowFilter(3, 270, 0x777777, 0.8, 15, 15, 2, 3)];

        }

        private function createItems():void {
            log.debug("createItems(), creating " + _config.items.length + " menu items");
            for (var i:uint = 0; i < _config.items.length; i++) {
                createItem(_config.items[i] as ItemConfig, i);
            }
        }

        private function createItem(itemConfig:ItemConfig, tabIndex:uint = 0):void {
            log.debug("createItem(), label == " + itemConfig.label);

            var item:MenuItem = new MenuItem(_player.createLoader(), itemConfig, _player.animationEngine, _dock.icons.length == 0);
            itemConfig.view = item;
            item.tabEnabled = true;
            item.tabIndex = tabIndex;
            item.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                if (! item.enabled) return;
                _player.animationEngine.fadeOut(_dock);
                itemConfig.fireCallback(_model);
                deselectOtherItemsInGroup(itemConfig);
            });

            if (_dock.config.horizontal) {
                item.width = itemConfig.width;
            } else {
                item.height = itemConfig.height;
            }

            _dock.addIcon(item);
        }

        private function deselectOtherItemsInGroup(itemConfig:ItemConfig):void {
            var itemsInGroup:Array = _config.itemsIn(itemConfig.group);
            for (var i:int; i < itemsInGroup.length; i++) {
                var relatedItem:ItemConfig = itemsInGroup[i] as ItemConfig;
                if (relatedItem != itemConfig) {
                    relatedItem.view.selected = false;
                }
            }
        }

    }
}
