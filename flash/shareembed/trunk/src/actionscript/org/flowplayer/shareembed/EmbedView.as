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
    import flash.events.FocusEvent;
    import flash.system.System;

    import flash.text.TextFieldType;
    import flash.text.TextFormat;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.shareembed.config.EmbedConfig;
    import org.flowplayer.ui.DropdownMenu;
    import org.flowplayer.ui.DropdownMenuEvent;
    import org.flowplayer.util.Arrange;
    import org.flowplayer.view.AnimationEngine;
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
        private var _copyBtn:Sprite;
        private var _titleLabel:TextField;
        private var _optionsLabel:TextField;
        private var _buttonColorLabel:TextField;
        private var _bgColorLabel:TextField;
        private var _sizeDivLabel:TextField;
        private var _sizeLabel:TextField;
        private var _config:EmbedConfig;
        private var _bgColors:DropdownMenu;
        private var _buttonColors:DropdownMenu;
        private var _heightTxt:TextField;
        private var _widthTxt:TextField;
        private var _optionsContainer:Sprite;

        public function EmbedView(plugin:DisplayPluginModel, player:Flowplayer, config:EmbedConfig, style:Object) {
            super("viral-embed", plugin, player, style);
            _config = config;

            createCopyButton();
            createEmbedCode();
            createOptionsContainer();

            _titleLabel = createLabel("<span class=\"title\">" + _config.title + "</span>");
            _optionsLabel = createLabel("<span class=\"label\">" + _config.options + "</span>", _optionsContainer);
            _sizeLabel = createLabel("<span class=\"label\">" + _config.size + "</span>", _optionsContainer);
            _bgColorLabel = createLabel("<span class=\"label\">" + _config.backgroundColor + "</span>", _optionsContainer);
            _buttonColorLabel = createLabel("<span class=\"label\">" + _config.buttonColor + "</span>", _optionsContainer);
            _sizeDivLabel = createLabel("<span class=\"label\">x</span>", _optionsContainer);

            _widthTxt = createInput(_optionsContainer);
            log.debug("setting embed size to " + _config.playerEmbed.width + " x " + _config.playerEmbed.height);
            _widthTxt.text = _config.playerEmbed.width + "";
            _widthTxt.addEventListener(FocusEvent.FOCUS_OUT, function(event:FocusEvent):void {
                config.playerEmbed.width = value(_widthTxt);
                changeCode();
            });

            _heightTxt = createInput(_optionsContainer);
            _heightTxt.text = _config.playerEmbed.height + "";
            _heightTxt.addEventListener(FocusEvent.FOCUS_OUT, function(event:FocusEvent):void {
                config.playerEmbed.height = value(_heightTxt);
                changeCode();
            });

            createButtonColorMenu(player.animationEngine);
            createBackgroundColorMenu(player.animationEngine);
            initEmbedCodeSettings();
        }

        override public function set visible(value:Boolean):void {
            super.visible = value;
            _config.playerEmbed.applyControlsOptions(value);
        }

        private function value(field:TextField):int {
            try {
                return int(field.text);
            } catch (e:Error) {
                log.warn(e.message);
            }
            return 0;
        }

        private function createOptionsContainer():void {
            _optionsContainer = new Sprite();
            addChild(_optionsContainer);
        }


        private function createButtonColorMenu(animationEngine:AnimationEngine):void {
            _buttonColors = new DropdownMenu(animationEngine);
            _buttonColors.addItem("White", "#ffffff");
            _buttonColors.addItem("Red", "#ff0000");
            _buttonColors.addItem("Blue", "#0000ff");
            _buttonColors.addItem("Yellow", "#ffff00");
            _buttonColors.addItem("Green", "#00ff3c");
            _buttonColors.addEventListener(DropdownMenuEvent.CHANGE, function(event:DropdownMenuEvent):void {
                _config.playerEmbed.buttonColor = event.value;
                changeCode();
            });
            _optionsContainer.addChild(_buttonColors);
        }

        private function createBackgroundColorMenu(animationEngine:AnimationEngine):void {
            _bgColors = new DropdownMenu(animationEngine);
            _bgColors.addItem("Black", "#000000");
            _bgColors.addItem("Transparent", "rgba(0,0,0,0)");
            _bgColors.addItem("Red", "#ff0000");
            _bgColors.addItem("Blue", "#0000ff");
            _bgColors.addItem("Yellow", "#ffff00");
            _bgColors.addItem("Green", "#00ff3c");
            _bgColors.addEventListener(DropdownMenuEvent.CHANGE, function(event:DropdownMenuEvent):void {
                _config.playerEmbed.backgroundColor = event.value;
                changeCode();
            });
            _optionsContainer.addChild(_bgColors);
        }

        private function setSelection():void {
            _embedCode.setSelection(0, _embedCode.text.length);
            _embedCode.scrollH = _embedCode.scrollV = 0;
        }

        private function createLabel(htmlText:String, parent:DisplayObject = null):TextField {
            var field:TextField = createLabelField();
            field.htmlText = htmlText;
            (parent ? parent : this).addChild(field);
            return field;
        }

        private function createInput(parent:DisplayObject = null):TextField {
            var field:TextField = createInputField();
            (parent ? parent : this).addChild(field);
            return field;
        }

        private function changeCode():void {
            log.debug("changeCode");
            _embedCode.htmlText = '<span class="embed">' + _config.playerEmbed.getEmbedCode().replace(/\</g, "&lt;").replace(/\>/g, "&gt;") + '</span>';
        }

        private function initEmbedCodeSettings():void {
            _config.playerEmbed.width = _widthTxt.text as Number;
            _config.playerEmbed.height = _heightTxt.text as Number;
            changeCode();
        }

        private function createEmbedCode():void {
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
        }

        private function arrangeOptions():void {
            // Size: [width] x [height]
            const INPUT_LEFT:Number = 120;
            _optionsContainer.y = _copyBtn.y + _copyBtn.height + 10;

            _sizeLabel.y = _optionsLabel.height + PADDING_Y_TALL;
            _widthTxt.y = _optionsLabel.y;
            _widthTxt.x = INPUT_LEFT;
            _widthTxt.y = _sizeLabel.y;
            _widthTxt.width = 50;
            _sizeDivLabel.x = _widthTxt.x + _widthTxt.width + 3;
            _sizeDivLabel.y = _widthTxt.y;
            _heightTxt.x = _sizeDivLabel.x + _sizeDivLabel.width + 3;
            _heightTxt.y = _sizeLabel.y;
            _heightTxt.width = 50;

            _bgColorLabel.y = _widthTxt.y + _widthTxt.height + PADDING_Y_TALL;
            _bgColors.x = INPUT_LEFT;
            _bgColors.y = _bgColorLabel.y;
            _bgColors.width = _widthTxt.width + 6 + _heightTxt.width + _sizeDivLabel.width;
            _bgColors.height = 20;

            _buttonColorLabel.y = _bgColors.y + _bgColors.height + PADDING_Y_TALL;
            _buttonColors.x = INPUT_LEFT;
            _buttonColors.y = _buttonColorLabel.y;
            _buttonColors.width = _bgColors.width;
            _buttonColors.height = 20;

            Arrange.center(_optionsContainer, width);
        }

        override protected function onResize():void {
            log.debug("onResize " + width + " x " + height);
            _titleLabel.x = MARGIN_X;
            _titleLabel.y = 20;
            _titleLabel.width = width - 2 * MARGIN_X;

            _embedCode.width = width - 2 * MARGIN_X;
            _embedCode.height = 15;
            _embedCode.x = MARGIN_X;
            _embedCode.y = _titleLabel.y + _titleLabel.height + 10;

            _copyBtn.x = width - _copyBtn.width - MARGIN_X;
            _copyBtn.y = _embedCode.y + _embedCode.height + 10;

            arrangeOptions();
            setSelection();
        }

        private function createCopyButton():void {
            _copyBtn = new CopyBtn() as Sprite;
            _copyBtn.buttonMode = true;
            _copyBtn.addEventListener(MouseEvent.MOUSE_DOWN, onCopyToClipboard);
            addChild(_copyBtn);
        }

        private function onCopyToClipboard(event:MouseEvent):void {
            initEmbedCodeSettings();
            System.setClipboard(_config.playerEmbed.getEmbedCode());
            stage.focus = _embedCode;
            setSelection();
            _titleLabel.htmlText = '<span class="info">Copied to clipboard</span>';
        }
    }
}
