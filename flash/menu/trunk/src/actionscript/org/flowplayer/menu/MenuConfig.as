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
    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.DisplayPluginModelImpl;
    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.model.DisplayPropertiesImpl;
    import org.flowplayer.util.PropertyBinder;

    public class MenuConfig {
        private var _displayProps:DisplayPluginModel;
        private var _button:MenuButtonConfig = new MenuButtonConfig();
        private var _items:Array;
        private var _defaultItemConfig:Object;

        public function MenuConfig() {
            _items = new Array();
            _displayProps = new DisplayPluginModelImpl(null, "menudock");

            _defaultItemConfig = {
//                color: "rgba(140,142,140,1)",
                color: "rgba(255,255,255,1)",
                overColor: "rgba(1,95,213,1)",
                fontColor: "rgb(0,0,0)",
                disabledColor: "rgba(150,150,150,1)"
            };
        }

        public function get items():Array {
            return _items;
        }

        public function set items(value:Array):void {
            for (var i:int; i < value.length; i++) {
                var item:ItemConfig;

                // is the value and itemConfig object set from Flash?
                if (value[i] is ItemConfig) {
                    item = value[i];

                } else {
                    item = new ItemConfig();

                    if (value[i] is String) {
                        item.label = value[i] as String;
                    } else {
                        new PropertyBinder(item, "customProperties").copyProperties(value[i], true);
                    }
                }
                setDefaultProps(item);
                _items.push(item);
            }
        }

        public function addItem(itemConf:Object):ItemConfig {
            var item:ItemConfig;
            if (itemConf is ItemConfig) {
                item = itemConf as ItemConfig;
            } else {
                item = new PropertyBinder(new ItemConfig()).copyProperties(itemConf) as ItemConfig;
            }
            setDefaultProps(item);
            _items.push(item);
            return item;
        }

        /**
         * Returns the items that belong to the specified group.
         * @param group
         * @return the item's whose group property == to the specified group parameter
         */
        public function itemsIn(group:String):Array {
            if (! group) return [];
            return _items.filter(function(item:*, index:int, array:Array):Boolean {
                return (item as ItemConfig).group == group;
            });
        }

        private function setDefaultProps(item:ItemConfig):void {
            new PropertyBinder(item, "customProperties").copyProperties(_defaultItemConfig);
        }

        public function setStyle(styleObj:Object):void {
            if (styleObj == null) {
                _defaultItemConfig = null;
                return;
            }
            for (var prop:String in styleObj) {
                _defaultItemConfig[prop] = styleObj[prop];
            }

            // apply the style to existing items
            if (_items) {
                for (var i:int; i < _items.length; i++) {
                    var item:ItemConfig = _items[i] as ItemConfig;
                    setDefaultProps(item);
                }
            }
        }

        public function get button():MenuButtonConfig {
            return _button;
        }

        public function setButton(value:Object):void {
            new PropertyBinder(_button).copyProperties(value);
        }

        public function get displayProps():DisplayPluginModel {
            return _displayProps;
        }
    }
}
