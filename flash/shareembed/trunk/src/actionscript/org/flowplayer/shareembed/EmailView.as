/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 * Copyright (c) 2008, 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.shareembed {

	import org.flowplayer.model.DisplayPluginModel;
	import org.flowplayer.view.FlowStyleSheet;
	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.view.StyleableSprite;
	import org.flowplayer.util.URLUtil;
	
	import com.adobe.serialization.json.JSON;
	
	import com.ediblecode.util.StringUtil;
	

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;	
	import flash.text.TextFieldType;
	import flash.events.FocusEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.URLLoaderDataFormat;
	import flash.net.navigateToURL;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	

	import org.flowplayer.shareembed.assets.SendBtn;

	/**
	 * @author api
	 */
	internal class EmailView extends StyleableSprite {

		private var _config:Config;
		private var _textMask:Sprite;
		private var _closeButton:CloseButton;
		private var _htmlText:String;
		private var _player:Flowplayer;
		private var _plugin:DisplayPluginModel;
		private var _originalAlpha:Number;
		
		private var _formContainer:Sprite;
		private var _titleLabel:TextField;
		private var _emailToLabel:TextField;
		private var _emailToInput:TextField;
		private var _messageLabel:TextField;
		private var _messageInput:TextField;
		private var _nameFromLabel:TextField;
		private var _nameFromInput:TextField;
		private var _emailFromLabel:TextField;
		private var _emailFromInput:TextField;
		private var _emailSuccessLabel:TextField;
		
		private var _sendBtn:Sprite;
		
		private var _videoURL:String;
		
		private var _xPadding:int = 10;
		private var _yPadding:int = 5;
		
		public function EmailView(plugin:DisplayPluginModel, player:Flowplayer, config:Config) {
			super(null, player, player.createLoader());
			_plugin = plugin;
			_player = player;
			_config = config;
		

			createCloseButton();
		
		}

		override protected function onSetStyle(style:FlowStyleSheet):void {
			log.debug("onSetStyle");
			setupForm();
		}

		override protected function onSetStyleObject(styleName:String, style:Object):void {
			log.debug("onSetStyleObject");
			setupForm();
		}

		public function set html(htmlText:String):void {
			_htmlText = htmlText;
			if (! _htmlText) {
				_htmlText = "";
			}
			
		
		}
		
		public function get html():String {
			return _htmlText;
		}
		
		public function append(htmlText:String):String {
			html = _htmlText + htmlText;
			
			return _htmlText;
		}

		public function set closeImage(image:DisplayObject):void {
			if (_closeButton) {
				removeChild(_closeButton);
			}
			createCloseButton(image);
		}
		
		private function createLabelField():TextField
		{
			var field:TextField = _player.createTextField();
			field.selectable = false;
			field.autoSize = TextFieldAutoSize.LEFT;
			field.styleSheet = style.styleSheet;
			return field;
		}
		
		private function createInputField():TextField
		{
			var field:TextField = _player.createTextField();
			field.addEventListener(FocusEvent.FOCUS_IN, onTextInputFocusIn);
			field.addEventListener(FocusEvent.FOCUS_OUT, onTextInputFocusOut);
			field.type = TextFieldType.INPUT;
			field.alwaysShowSelection = true;
			field.tabEnabled = true;
            field.border = true;
			return field;
		}
		
		private function onTextInputFocusIn(event:FocusEvent):void
		{
			var field:TextField = event.target as TextField;
			field.borderColor = 0xCCCCCC;
		}
		
		private function onTextInputFocusOut(event:FocusEvent):void
		{
			var field:TextField = event.target as TextField;
			field.borderColor = 0x000000;
		}
		
		private function titleLabel():TextField
		{
			var field:TextField = createLabelField();
			field.width = 100;
            field.height = 20;            
            field.htmlText = "<span class=\"title\">Email this video</span>";
            return field;
		}
		
		private function emailToLabel():TextField
		{
			var field:TextField = createLabelField();            
			field.width = 150;
            field.height = 15;
            field.htmlText = "<span class=\"label\">Type in an email address <span id=" + 
            		"\"small\">(multiple addresses with commas)</span></span>";
            return field;
		}
		
		private function emailToInput():TextField
		{
			var field:TextField = createInputField();  
			field.mouseWheelEnabled	= true;
			field.width = 0.9 * width;
            field.height = 20;          
            return field;
		}
		
		private function messageLabel():TextField
		{
			var field:TextField = createLabelField();        
			field.width = 150;
            field.height = 15;     
            field.htmlText = "<span class=\"label\">Personal message <span id=" + 
            		"\"small\">(optional)</span></span>";
            return field;
		}
		
		private function messageInput():TextField
		{
			var field:TextField = createInputField();    
			field.multiline = true;    
			field.wordWrap = true;    
			field.mouseWheelEnabled	= true;
            field.width = 0.9 * width;
            field.height = 100;
            return field;
		}
		
		private function nameFromLabel():TextField
		{
			var field:TextField = createLabelField();            
			field.width = 100;
            field.height = 15;
            field.htmlText = "<span class=\"label\">Your name <span id=" + 
            		"\"small\">(optional)</span></span>";
            return field;
		}
		
		private function nameFromInput():TextField
		{
			var field:TextField = createInputField();     
			field.width = 0.5 * (width - (3 * _xPadding));
           	field.height = 20;      
            return field;
		}
		
		private function emailFromLabel():TextField
		{
			var field:TextField = createLabelField();     
			field.width = 100;
            field.height = 15;       
            field.htmlText = "<span class=\"label\">Your email address <span id=" + 
            		"\"small\">(optional)</span></span>";
            return field;
		}
		
		private function emailFromInput():TextField
		{
			var field:TextField = createInputField();  
			field.width = 0.5 * (width - (3 * _xPadding));
            field.height = 20;    
            return field;
		}
		
		private function emailSuccessLabel():TextField
		{
			var field:TextField = createLabelField();     
			field.width = 100;
            field.height = 15;       
            return field;
		}

		private function setupForm():void
		{
			_formContainer = new Sprite();
			
			addChild(_formContainer);
			
			_formContainer.x = 0;
			_formContainer.y = 0;
			
			_titleLabel = titleLabel();
			_formContainer.addChild(_titleLabel);
       
       		_emailToLabel = emailToLabel();
			_formContainer.addChild(_emailToLabel);
        
			_emailToInput = emailToInput();
            _formContainer.addChild(_emailToInput);
            
            _messageLabel = messageLabel();
            addChild(_messageLabel);
            	
            _messageInput = messageInput();
            _formContainer.addChild(_messageInput);

            
            _nameFromLabel = nameFromLabel();
            addChild(_nameFromLabel);
            
			
			_emailFromLabel = emailFromLabel();
            addChild(_emailFromLabel);
			
            _nameFromInput = nameFromInput();
            _formContainer.addChild(_nameFromInput);
            
            _emailSuccessLabel = emailSuccessLabel();
            _formContainer.addChild(_emailSuccessLabel);
            
            
            _emailFromInput = emailFromInput();
            _formContainer.addChild(_emailFromInput);
            
            _sendBtn = new SendBtn() as Sprite;
            _sendBtn.buttonMode = true;
            _sendBtn.addEventListener(MouseEvent.MOUSE_DOWN, onSubmit);
            
            _formContainer.addChild(_sendBtn);
            
            _videoURL = URLUtil.pageUrl;
            
            arrangeForm();

		}
		
		private function getEmailToken():void
		{
			log.debug("Requesting " + _config.emailScriptTokenURL);
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(_config.emailScriptTokenURL);
			request.method = URLRequestMethod.GET;	
			
			loader.load(request);
		
			loader.addEventListener(Event.COMPLETE, onTokenSuccess);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onTokenError);
			
		}
		
		private function sendServerEmail():void
		{
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(_config.emailScriptURL);
			request.method = URLRequestMethod.POST;	
			
	
			var param:URLVariables = new URLVariables();
			param.name = _nameFromInput.text;
			param.email = _emailFromInput.text;
			param.to = _emailToInput.text;
			param.message = StringUtil.formatString(_config.emailTemplate, _messageInput.text, _videoURL, _config.shareTitle ? _config.shareTitle : _videoURL);
			param.subject = _config.emailSubject;
			param.token = _config.emailScriptToken;
			
			param.dataFormat = URLLoaderDataFormat.VARIABLES;
			request.data = param;
			
			log.debug("Loading request");
			loader.load(request);
			loader.addEventListener(Event.COMPLETE, onSendSuccess);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onSendError);
		}
		
		private function sendLocalEmail():void
		{
			var request:URLRequest = new URLRequest(StringUtil.formatString("mailto:{0}?subject={1}&body={2}",_emailToInput.text, escape(_config.emailSubject), escape(StringUtil.formatString(_config.emailTemplate, _messageInput.text, _videoURL, _videoURL))));
			navigateToURL(request, "_self");
		}
		
		private function onSubmit(event:MouseEvent):void
		{
			if (_config.emailScriptURL)
			{
				if (_config.emailScriptToken && !_config.emailScriptTokenURL)
				{
					sendServerEmail();
				} else if (_config.emailScriptTokenURL) {
					getEmailToken();
				} else {
					sendServerEmail();
				}
				
			} else {
				sendLocalEmail();
			}
		}
		
		private function onSendError(event:IOErrorEvent):void
		{
			log.debug("Error: " + event.text);
			
			_emailSuccessLabel.text = event.text;
		}
		
		private function onSendSuccess(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			
			loader.removeEventListener(Event.COMPLETE, onSendSuccess);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onSendError);
			
			var message:Object = JSON.decode(loader.data.toString());
			log.debug(loader.data.toString());
			
			loader.close();
			loader = null;
			
			
			
			if (message.error)
			{
				log.debug(message.error);
				_emailSuccessLabel.text = message.error;
			}
			
			if (message.success)
			{
				log.debug(message.success);
				_emailSuccessLabel.text = message.success;
			}
			
		}
		
		private function onTokenError(event:IOErrorEvent):void
		{
			log.debug("Error: " + event.text);
			
			_emailSuccessLabel.text = event.text;
		}
		
		private function onTokenSuccess(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			
			loader.removeEventListener(Event.COMPLETE, onTokenSuccess);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onTokenError);
			
			log.debug("Loading Token");
			
			
			
			var data:Object = JSON.decode(loader.data.toString());
			
			loader.close();
			loader = null;
			
			
			if (data.error)
			{
				_emailSuccessLabel.text = data.error;	
			} else {
				_config.emailScriptToken = data.token;
				sendServerEmail();
			}
			
		}
		
		private function arrangeForm():void {
			_titleLabel.x = _xPadding;
            _titleLabel.y = _xPadding;
            
            _emailToLabel.x = _xPadding;
            _emailToLabel.y = _titleLabel.y + _titleLabel.height + (_yPadding * 2);
            
            _emailToInput.x = _xPadding;
            _emailToInput.y = _emailToLabel.y + _emailToLabel.height + _yPadding;
            
            _messageLabel.x = _xPadding;
            _messageLabel.y = _emailToInput.y + _emailToInput.height + _yPadding;
            
            _messageInput.x = _xPadding;
            _messageInput.y = _messageLabel.y + _messageLabel.height + _yPadding;
            
            _nameFromLabel.x = _xPadding;
            _nameFromLabel.y = _messageInput.y + _messageInput.height + _yPadding;
            
             _emailFromLabel.x = _nameFromLabel.x + _nameFromLabel.width + _xPadding;
            _emailFromLabel.y = _messageInput.y + _messageInput.height + _yPadding;
            
            _nameFromInput.x = _xPadding;
            _nameFromInput.y = _nameFromLabel.y + _nameFromLabel.height + _yPadding;
            
             _emailFromInput.x = _nameFromInput.x + _nameFromInput.width + _xPadding;
            _emailFromInput.y = _emailFromLabel.y + _emailFromLabel.height + _yPadding;
            
            _sendBtn.x = _xPadding;
            _sendBtn.y = _nameFromInput.y + _nameFromInput.height + (_yPadding * 2);
            
            _emailSuccessLabel.x = _sendBtn.x + _sendBtn.width + _xPadding;
            _emailSuccessLabel.y = _sendBtn.y;
		}

		override protected function onResize():void {
			arrangeCloseButton();
			
			//_formContainer.x = 0;
			//_formContainer.y = 0;
			
			
			
			this.x = 0;
			this.y = 0;
		}

		override protected function onRedraw():void {
			arrangeCloseButton();
		}
		
		private function arrangeCloseButton():void {
			if (_closeButton && style) {
				_closeButton.x = width - _closeButton.width - 1 - style.borderRadius/5;
				_closeButton.y = 1 + style.borderRadius/5;
				setChildIndex(_closeButton, numChildren-1);
			}
		}
		
		private function createCloseButton(icon:DisplayObject = null):void {
			_closeButton = new CloseButton(icon);
			addChild(_closeButton);
			_closeButton.addEventListener(MouseEvent.CLICK, onCloseClicked);
		}
		
		private function onCloseClicked(event:MouseEvent):void {
			_player.animationEngine.fadeOut(this, 500, onFadeOut);
		}
		
		private function onFadeOut():void {
			ShareEmbed(_plugin.getDisplayObject()).removeChild(this);
		}

		override public function set alpha(value:Number):void {
			super.alpha = value;
			
		}
	}
}
