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
    import org.flowplayer.model.Extendable;
    import org.flowplayer.model.ExtendableHelper;
    import org.flowplayer.model.PluginEventType;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.ui.buttons.ButtonConfig;
    import org.flowplayer.util.ObjectConverter;

    public class ItemConfig extends ButtonConfig implements Extendable {
        private var _label:String;
        private var _extension:ExtendableHelper = new ExtendableHelper();
        private var _height:Number = 30;
        private var _width:Number = 70;
        private var _selectedCallback:Function;

        [Value]
        public function get label():String {
            return _label;
        }

        public function set label(value:String):void {
            _label = value;
        }

        public function set customProperties(props:Object):void {
            _extension.props = props;
        }

        public function get customProperties():Object {
            return _extension.props;
        }

        public function setCustomProperty(name:String, value:Object):void {
            _extension.setProp(name,  value);
        }

        public function getCustomProperty(name:String):Object {
            return _extension.getProp(name);
        }

        public function deleteCustomProperty(name:String):void {
            _extension.deleteProp(name);
        }

        [Value]
        public function get height():Number {
            return _height;
        }

        public function set height(value:Number):void {
            _height = value;
        }

        [Value]
        public function get width():Number {
            return _width;
        }

        public function set width(value:Number):void {
            _width = value;
        }

        public function set onSelected(value:Function):void {
            _selectedCallback = value;
        }

        public function fireCallback(model:PluginModel):void {
            if (_selectedCallback != null) {
                _selectedCallback(this);
            } else {
                model.dispatch(PluginEventType.PLUGIN_EVENT, "onSelect", new ObjectConverter(this).convert());
            }

        }
    }
}
