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
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    import flash.filters.DropShadowFilter;

    import org.flowplayer.menu.*;
    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginEvent;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.ui.containers.WidgetContainer;
    import org.flowplayer.ui.containers.WidgetContainerEvent;
    import org.flowplayer.ui.dock.Dock;
    import org.flowplayer.ui.dock.DockConfig;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.Styleable;

    public class Menu extends AbstractSprite implements Plugin, Styleable {
//        private static const MENU_PLUGIN_NAME:String = "menudock";

        private var _config:MenuConfig;
        private var _dock:Dock;
        private var _player:Flowplayer;
        private var _model:DisplayPluginModel;
        private var _menuButtonController:MenuButtonController;
        private var _menuButtonContainer:WidgetContainer;

        /**
         * Adds menu items.
         * @param items an array of MenuConfig instances
         */
        public function addItems(items:Array):void {
            _config.items = items;
            createItems();
            updateModelHeight();
        }

        /**
         * Adds an item to the menu.
         * @param itemConf and Object with with properties for a ItemConfig object. Or an instance of ItemConfig.
         * @return the index of the item the item in the menu, zero based
         */
        public function addItem(itemConf:Object):int {
            var itemConfig:MenuItemConfig = _config.addItem(itemConf);
            log.debug("addItem(), color == " + itemConfig.color + ", overColor == " + itemConfig.overColor);
            createItem(itemConfig);
            if (_menuButtonContainer) {
                adjustDockPosition();
            }
            updateModelHeight();
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
            _model = model as DisplayPluginModel;
            _config = new PropertyBinder(new MenuConfig()).copyProperties(model.config) as MenuConfig;
            log.debug("config", _config.items);
        }

        public function onLoad(player:Flowplayer):void {
            _player = player;
            createDock();
            updateModelHeight();
            createMenuButton(player);
            _model.dispatchOnLoad();
        }

        override protected function onResize():void {
            _dock.setSize(width, height);
            updateModelHeight();
        }

        private function updateModelHeight():void {
            // in scrollable mode the height is set by the plugin configuration
            if (_config.scrollable) return;

            // the dock's height is actually determined on the heights of the menu items, update our model to reflect the real values
            _model.height = _dock.height;
            _player.pluginRegistry.updateDisplayProperties(_model);
        }

        private function get horizontalPosConfigured():Boolean {
            var confObj:Object = _player.config.getObject("plugins")[_model.name];
            log.debug("verticalPosConfigured", confObj);
            return confObj && (confObj.hasOwnProperty("left") || confObj.hasOwnProperty("right"));
        }

        private function get verticalPosConfigured():Boolean {
            var confObj:Object = _player.config.getObject("plugins")[_model.name];
            log.debug("verticalPosConfigured", confObj);
            return confObj && (confObj.hasOwnProperty("top") || confObj.hasOwnProperty("bottom"));
        }

        public function getDefaultConfig():Object {
            return { width: 150, height: 100 };
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
            _menuButtonController = new MenuButtonController(_player,  _model);
            _menuButtonContainer.addWidget(_menuButtonController, "time", false);
            adjustDockPosition();
        }

        private function adjustDockPosition():void {
            if (horizontalPosConfigured && verticalPosConfigured) return;

            if (! horizontalPosConfigured) {
                _model.position.leftValue = _menuButtonController.view.x;
                log.debug("adjustDockPosition(), horizontal menu position adjusted to " + _dock.config.model.position);
            }
            if (! verticalPosConfigured) {
                _model.position.bottomValue = DisplayObject(_menuButtonContainer).stage.height - DisplayObject(_menuButtonContainer).y;
                log.debug("adjustDockPosition(), vertical menu position adjusted to " + _dock.config.model.position);
            }
            _player.animationEngine.animate(this, _model, 0);
//            _player.pluginRegistry.updateDisplayProperties(_model, true);
        }

        private function createDock():void {
            log.debug("createDock()");
            var dockConfig:DockConfig = new DockConfig();
            dockConfig.model = DisplayPluginModel(_model.clone());
            dockConfig.model.display = "block";
            dockConfig.gap = 0;
            dockConfig.setButtons(_config.buttons);

            if (_config.button.dockedOrControls) {
                log.debug("createDock() using a menu button, disabling autoHide");
                _model.display = "none";
            }
            dockConfig.scrollable = _config.scrollable;

            _dock = new Dock(_player, dockConfig);
            addChild(_dock);

            createItems();

            // distance, angle, color, alpha, blurX, blurY, strength,quality,inner,knockout ) all as type Number accept 'inner','knockout' and 'hideObject' (as Boolean).
            this.filters = [new DropShadowFilter(3, 270, 0x777777, 0.8, 15, 15, 2, 3)];

        }

        private function createItems():void {
            log.debug("createItems(), creating " + _config.items.length + " menu items");
            for (var i:uint = 0; i < _config.items.length; i++) {
                createItem(_config.items[i] as MenuItemConfig, i);
            }
        }

        private function createItem(itemConfig:MenuItemConfig, tabIndex:uint = 0):void {
            log.debug("createItem(), label == " + itemConfig.label);

            itemConfig.width = _model.widthPx;
            var item:MenuItem = new MenuItem(_player, itemConfig, _player.animationEngine, _dock.icons.length == 0);
            itemConfig.view = item;
            item.tabEnabled = true;
            item.tabIndex = tabIndex;

            var menu:Menu = this;
            item.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                if (! item.enabled) return;
                _player.animationEngine.fadeOut(menu);
                itemConfig.fireCallback(_model);
                deselectOtherItemsInGroup(itemConfig);
            });
            item.height = itemConfig.height;

            _dock.addIcon(item);
        }

        private function deselectOtherItemsInGroup(itemConfig:MenuItemConfig):void {
            var itemsInGroup:Array = _config.itemsIn(itemConfig.group);
            for (var i:int; i < itemsInGroup.length; i++) {
                var relatedItem:MenuItemConfig = itemsInGroup[i] as MenuItemConfig;
                if (relatedItem != itemConfig) {
                    relatedItem.view.selected = false;
                }
            }
        }

        public function onBeforeCss(styleProps:Object = null):void {
        }

        public function css(styleProps:Object = null):Object {
            return null;
        }

        public function onBeforeAnimate(styleProps:Object):void {
        }

        public function animate(styleProps:Object):Object {
            return null;
        }
    }
}
