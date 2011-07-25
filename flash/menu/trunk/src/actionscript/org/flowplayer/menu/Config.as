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
    import org.flowplayer.util.PropertyBinder;

    public class Config {
        private var _button:MenuButtonConfig = new MenuButtonConfig();
        private var _items:Array;
        private var _itemConfObj:Object;

        public function Config() {
            _items = new Array();

            _itemConfObj = {
                color: "rgba(140,142,140,1)",
                overColor: "rgba(1,95,213,1)",
                fontColor: "rgb(255,255,255)"
            };
        }

        public function get items():Array {
            return _items;
        }

        public function set items(value:Array):void {
            for (var i:int; i < value.length; i++) {
                var item:ItemConfig;

                if (value[i] is ItemConfig) {
                    item = value[i];
                    setDefaultProps(item);

                } else {
                    item = new ItemConfig();
                    setDefaultProps(item);

                    if (value[i] is String) {
                        item.label = value[i] as String;
                    } else {
                        new PropertyBinder(item, "customProperties").copyProperties(value[i], true);
                    }
                }
                _items.push(item);
            }
        }

        private function setDefaultProps(item:ItemConfig):void {
            new PropertyBinder(item, "customProperties").copyProperties(_itemConfObj);
        }

        public function setStyle(styleObj:Object):void {
            _itemConfObj = styleObj;
        }

        public function get button():MenuButtonConfig {
            return _button;
        }

        public function setButton(value:Object):void {
            new PropertyBinder(_button).copyProperties(value);
        }
    }
}
