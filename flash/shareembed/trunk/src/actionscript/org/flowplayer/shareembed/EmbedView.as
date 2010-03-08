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

    import flash.text.TextFieldType;
    import flash.text.TextFormat;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.shareembed.config.EmbedConfig;
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

    import org.flowplayer.shareembed.assets.CopyBtn;

    /**
     * @author danielr
     */
    internal class EmbedView extends StyleableView {

        private var _embedCode:TextField;
        private var _htmlText:String;
        private var _copyBtn:Sprite;
        private var _titleLabel:TextField;
        private var _config:EmbedConfig;

        public function EmbedView(plugin:DisplayPluginModel, player:Flowplayer, config:EmbedConfig, style:Object) {
            super("viral-embed", plugin, player, style);
            _config = config;

            createCopyButton();
            createEmbedCode();
            createTitle();
        }

        public function set html(htmlText:String):void {
            _htmlText = htmlText;
            if (! _htmlText) {
                _htmlText = "";
            }
            _embedCode.htmlText = '<span class="embed">' + _htmlText + '</span>';
            _embedCode.setSelection(0, _embedCode.text.length);
            _embedCode.scrollH = _embedCode.scrollV = 0;
            log.debug("set html to " + _embedCode.htmlText);

        }

        public function get html():String {
            return _htmlText;
        }

        private function createTitle():void {
            _titleLabel = createLabelField();
            _titleLabel.htmlText = "<span class=\"title\">" + _config.title + "</span>";
            addChild(_titleLabel);
        }

        private function createEmbedCode(htmlText:String = null):void {
            log.debug("creating text field for text " + htmlText);
            if (_embedCode) {
                removeChild(_embedCode);
            }
            _embedCode = createInputField(true);
            _embedCode.type = TextFieldType.DYNAMIC;
            _embedCode.selectable = false;
            var format:TextFormat = new TextFormat();
            format.size = 10;
            _embedCode.defaultTextFormat = format;

            addChild(_embedCode);
            if (htmlText) {
                log.debug("setting html to " + htmlText);
                html = htmlText;
            }
        }

        override protected function onResize():void {
            log.debug("onResize " + width + " x " + height);
            _titleLabel.x = MARGIN_X;
            _titleLabel.y = MARGIN_Y;
            _titleLabel.width = width - 2 * MARGIN_X;

            _embedCode.width = width - 2 * MARGIN_X;
            _embedCode.height = 15;
            _embedCode.x = MARGIN_X;
            _embedCode.y = _titleLabel.y + _titleLabel.height + 10;

            _copyBtn.x = width - _copyBtn.width - MARGIN_X;
            _copyBtn.y = _embedCode.y + _embedCode.height + 10;
        }

        private function createCopyButton():void {
            _copyBtn = new CopyBtn() as Sprite;
            _copyBtn.buttonMode = true;
            _copyBtn.addEventListener(MouseEvent.MOUSE_DOWN, onCopyToClipboard);
            addChild(_copyBtn);
        }

        private function onCopyToClipboard(event:MouseEvent):void
        {
            System.setClipboard(_embedCode.text);
            stage.focus = _embedCode;
            _embedCode.setSelection(0, _embedCode.text.length);
            _titleLabel.htmlText = '<span class="info">Copied to clipboard</span>';
        }
    }
}
