/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.viralvid {
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
	internal class EmbedView extends StyleableSprite {

		private var _text:TextField;
		private var _closeButton:CloseButton;
		private var _htmlText:String;
		private var _player:Flowplayer;
		private var _plugin:DisplayPluginModel;
		
		private var _copyBtn:Sprite;
		private var _infoText:TextField;

		public function EmbedView(plugin:DisplayPluginModel, player:Flowplayer) {
			super(null, player, player.createLoader());
			_plugin = plugin;
			_player = player;

			createCloseButton();
			createCopyButton();

		}

		override protected function onSetStyle(style:FlowStyleSheet):void {
			log.debug("onSetStyle");
			createTextField(_text ? _text.htmlText : null);
		}

		override protected function onSetStyleObject(styleName:String, style:Object):void {
			log.debug("onSetStyleObject");
			createTextField(_text ? _text.htmlText : null);
		}

		public function set html(htmlText:String):void {
			_htmlText = htmlText;
			if (! _htmlText) {
				_htmlText = "";
			}
			_text.htmlText = '<span class="embed">' + _htmlText + '</span>';
			log.debug("set html to " + _text.htmlText);
		}
		
		public function get html():String {
			return _htmlText;
		}
		
		
		private function createLabelField():TextField
		{
			var field:TextField = _player.createTextField();
			field.selectable = false;
			field.autoSize = TextFieldAutoSize.NONE;
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

		private function createTextField(htmlText:String = null):void {
			log.debug("creating text field for text " + htmlText);
			if (_text) {
				removeChild(_text);
			} 
			_text = createLabelField();
			_text.blendMode = BlendMode.LAYER;
			//_text.autoSize = TextFieldAutoSize.LEFT;
			_text.wordWrap = true;
			_text.multiline = true;
			_text.selectable = true;
			_text.antiAliasType = AntiAliasType.ADVANCED;
			_text.condenseWhite = true;
			_text.width = width - 15;
			_text.height = height - _copyBtn.height - 10;
      		_text.x = 5;
      		_text.y = 5;

			addChild(_text);
			if (style.styleSheet) {
				_text.styleSheet = style.styleSheet;
			}
			if (htmlText) {
				log.debug("setting html to " + htmlText);
				html = htmlText;
			}
			
			createInfoText();
		}
		
	

		override protected function onResize():void {
			arrangeCloseButton();
			arrangeCopyButton();
			arrangeInfoText();
			this.x = 0;
			this.y = 0;
		}

		override protected function onRedraw():void {
		
			arrangeCloseButton();
			arrangeCopyButton();
			arrangeInfoText();
		}
		
		private function arrangeCloseButton():void {
			if (_closeButton && style) {
				_closeButton.x = width - _closeButton.width - 1 - style.borderRadius/5;
				_closeButton.y = 1 + style.borderRadius/5;
				setChildIndex(_closeButton, numChildren-1);
			}
		}
		
		private function arrangeCopyButton():void {
			if (_copyBtn) {
				_copyBtn.y = height - _copyBtn.height - 5;
				_copyBtn.x = 10;		
			}
		}
		
		private function arrangeInfoText():void {
			if (_infoText && _copyBtn) {
				_infoText.y = height - _infoText.height - 5;
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
			System.setClipboard(_text.text);
			stage.focus = _text;
			_text.setSelection(0, _text.text.length);
			_infoText.htmlText = '<span class="info">Copied to clipboard</span>';
		}
		
		private function onCloseClicked(event:MouseEvent):void {
			_player.animationEngine.fadeOut(this, 500, onFadeOut);	
		}
		
		private function onFadeOut():void {
			ViralVideo(_plugin.getDisplayObject()).removeChild(this);
		}

	}
}
