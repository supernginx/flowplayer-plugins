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

    import org.flowplayer.shareembed.assets.CopyBtn;

    /**
     * @author danielr
     */
    internal class EmbedView extends StyleableView {
        private const PADDING:int = 5;

        private var _emedText:TextField;
        private var _closeButton:CloseButton;
        private var _htmlText:String;

        private var _copyBtn:Sprite;
        private var _infoText:TextField;

        public function EmbedView(plugin:DisplayPluginModel, player:Flowplayer, style:Object) {
            super("viral-embed", plugin, player, style);
            rootStyle = style;

            createCloseButton();
            createCopyButton();
            createEmbedText();
            createInfoText();
        }

        public function set html(htmlText:String):void {
            _htmlText = htmlText;
            if (! _htmlText) {
                _htmlText = "";
            }
            _emedText.htmlText = '<span class="embed">' + _htmlText + '</span>';
            log.debug("set html to " + _emedText.htmlText);

        }

        public function get html():String {
            return _htmlText;
        }


        private function createLabelField():TextField
        {
            var field:TextField = player.createTextField();
            field.selectable = false;
            field.autoSize = TextFieldAutoSize.NONE;
            field.antiAliasType = AntiAliasType.ADVANCED;

            field.styleSheet = style.styleSheet;
            return field;
        }

        private function createInfoText():void
        {
            _infoText = createLabelField();
            _infoText.width = 150;
            _infoText.height = 20;
            addChild(_infoText);
        }

        private function createEmbedText(htmlText:String = null):void {
            log.debug("creating text field for text " + htmlText);
            if (_emedText) {
                removeChild(_emedText);
            }
            _emedText = createLabelField();
            _emedText.blendMode = BlendMode.LAYER;
            //_text.autoSize = TextFieldAutoSize.LEFT;
            _emedText.wordWrap = true;
            _emedText.multiline = true;
            _emedText.selectable = true;
            _emedText.antiAliasType = AntiAliasType.ADVANCED;
            _emedText.condenseWhite = true;
            //ShareEmbed(_plugin.getDisplayObject()).field.text = "height: " + _stageHeight

            addChild(_emedText);
            if (style.styleSheet) {
                _emedText.styleSheet = style.styleSheet;
            }
            if (htmlText) {
                log.debug("setting html to " + htmlText);
                html = htmlText;
            }
        }


        override protected function onResize():void {
            log.debug("onResize " + width + " x " + height);
            arrangeCloseButton();
            arrangeCopyButton();
            arrangeInfoText();
            arranggeEmbedText();
        }

        private function arranggeEmbedText():void {
            _emedText.width = width - 40;
            _emedText.height = _width - _copyBtn.height - 30;
            _emedText.x = PADDING;
            _emedText.y = PADDING;
        }

        override protected function onRedraw():void {
            arrangeCloseButton();
            arrangeCopyButton();
            arrangeInfoText();
        }

        private function arrangeCloseButton():void {
            if (_closeButton) {
                //_closeButton.x = width - _closeButton.width - 1 - style.borderRadius/5;
                _closeButton.x = width - _closeButton.width;
                //_closeButton.y = 1 + style.borderRadius/5;
                _closeButton.y = _closeButton.height / 3;
                setChildIndex(_closeButton, numChildren - 1);
            }
        }

        private function arrangeCopyButton():void {
            if (_copyBtn) {
                _copyBtn.y = height - _copyBtn.height - PADDING;
                _copyBtn.x = this.width - _copyBtn.width - PADDING;
            }
        }

        private function arrangeInfoText():void {
            if (_infoText && _copyBtn) {
                _infoText.y = height - _infoText.height - PADDING;
                _infoText.x = _copyBtn.x + _copyBtn.width + 40;
            }
        }

        private function createCloseButton(icon:DisplayObject = null):void {
            _closeButton = new CloseButton(icon);
            addChild(_closeButton);
            _closeButton.addEventListener(MouseEvent.CLICK, onCloseClicked);
        }

        private function createCopyButton():void {
            _copyBtn = new CopyBtn() as Sprite;
            _copyBtn.buttonMode = true;
            _copyBtn.addEventListener(MouseEvent.MOUSE_DOWN, onCopyToClipboard);
            addChild(_copyBtn);
        }

        private function onCopyToClipboard(event:MouseEvent):void
        {
            System.setClipboard(_emedText.text);
            stage.focus = _emedText;
            _emedText.setSelection(0, _emedText.text.length);
            _infoText.htmlText = '<span class="info">Copied to clipboard</span>';
        }

        private function onCloseClicked(event:MouseEvent):void {
            ShareEmbed(model.getDisplayObject()).removeTabs();
            player.animationEngine.fadeOut(this, 500, onFadeOut);
        }

        private function onFadeOut():void {
            ShareEmbed(model.getDisplayObject()).displayButtons(true);
            //ShareEmbed(_plugin.getDisplayObject()).removeChild(this);
            //ShareEmbed(_plugin.getDisplayObject()).hideEmbedPanel(this);
        }

        public function closePanel():void {
            ShareEmbed(model.getDisplayObject()).removeChild(this);
            //_player.animationEngine.fadeOut(this, 0, closePanel2);
        }

        public function closePanel2():void {
        }

    }
}
