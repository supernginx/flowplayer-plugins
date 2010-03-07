/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.shareembed {
    import flash.system.System;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.view.FlowStyleSheet;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.StyleableSprite;

    import flash.display.BlendMode;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;

    import flash.text.AntiAliasType;


    /**
     * @author danielr
     */
    internal class Tab extends StyleableSprite {

        private var _player:Flowplayer;
        private var _plugin:DisplayPluginModel;
        public var _field:TextField
        private var _text:String;

        public function Tab(plugin:DisplayPluginModel, player:Flowplayer, text:String) {
            super("viral-tab", player, player.createLoader());
            rootStyle = { backgroundGradient: 'medium', border: 'none', borderRadius: 15 };

            _plugin = plugin;
            _player = player;
            _text = text;
            createTextField(text);
            this.addEventListener(MouseEvent.CLICK, onThisClicked);
        }

        public function get html():String {
            return _text;
        }

        private function createTextField(htmlText:String):void {
            log.debug("creating text field for text " + htmlText);
            if (_field) {
                removeChild(_field);
            }

            _field = _player.createTextField();
            _field.width = this.width - 20;
            _field.selectable = false;
            _field.height = 20;
            _field.x = 5;
            _field.antiAliasType = AntiAliasType.ADVANCED;

            _field.htmlText = htmlText;
            addChild(_field);
        }

        public function onThisClicked(event:MouseEvent):void {
            ShareEmbed(_plugin.getDisplayObject()).switchTabs(html);
        }

        public function closePanel():void {
            _player.animationEngine.fadeOut(this, 0, closePanel2);
        }

        public function closePanel2():void {
            ShareEmbed(_plugin.getDisplayObject()).removeChild(this);
        }

    }
}
