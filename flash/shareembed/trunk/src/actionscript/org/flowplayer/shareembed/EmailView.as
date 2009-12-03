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

	import org.flowplayer.model.DisplayPluginModel;
	import org.flowplayer.view.FlowStyleSheet;
	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.view.StyleableSprite;
	import org.flowplayer.util.URLUtil;
	
	import com.adobe.serialization.json.JSON;
	import com.ediblecode.util.StringUtil;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	
	import flash.events.MouseEvent;
	import flash.events.FocusEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;	
	import flash.text.TextFieldType;
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.URLLoaderDataFormat;
	import flash.net.navigateToURL;
	
	

	import org.flowplayer.shareembed.assets.SendBtn;

	/**
	 * @author danielr
	 */
	internal class EmailView extends StyleableSprite {

		private var _config:Config;
		private var _closeButton:CloseButton;
		private var _player:Flowplayer;
		private var _plugin:DisplayPluginModel;
		
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
		
		/**
		 * Constructor
		 * 
		 * @param plugin DisplayPluginModel 
		 * @param player Flowplayer
		 * @param config Config
		 */
		 
		public function EmailView(plugin:DisplayPluginModel, player:Flowplayer, config:Config) {
			super(null, player, player.createLoader());
			_plugin = plugin;
			_player = player;
			_config = config;

			createCloseButton();
			
			this.addEventListener(Event.ADDED_TO_STAGE, setTextFocus);
		}
		
		/**
		 * When added to stage, set the focus to the email to text input.
		 * 
		 * @param event Event
		 * @return void
		 */
		public function setTextFocus(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, setTextFocus);
			stage.focus = _emailToInput;
		}

		/**
		 * Style listener handler. Sets up the form on completion.
		 * 
		 * @param style FlowStyleSheet
		 * @return void
		 */
		 
		override protected function onSetStyle(style:FlowStyleSheet):void {
			log.debug("onSetStyle");
			setupForm();
		}
		
		/**
		 * Style object listener handler. Sets up the form on completion.
		 * 
		 * @param style FlowStyleSheet
		 * @return void
		 */
		override protected function onSetStyleObject(styleName:String, style:Object):void {
			log.debug("onSetStyleObject");
			setupForm();
		}
	
		/**
		 * Create a label text field
		 * 
		 * @return TextField 
		 */
		 	
		private function createLabelField():TextField
		{
			var field:TextField = _player.createTextField();
			field.selectable = false;
			field.focusRect = false;            
			field.tabEnabled = false;
			field.autoSize = TextFieldAutoSize.LEFT;
			field.styleSheet = style.styleSheet;
			return field;
		}
		
		/**
		 * Create an input text field
		 * 
		 * @return TextField 
		 */
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
		
		/**
		 * Text Focus In handler
		 * Changes the text input border color to CCCCCC on focus.
		 * 
		 * @param event FocusEvent
		 * @return void
		 */
		private function onTextInputFocusIn(event:FocusEvent):void
		{
			var field:TextField = event.target as TextField;
			field.borderColor = 0xCCCCCC;
		}
		
		/**
		 * Text Focus Out handler
		 * Changes the text input border color to 000000 on focus.
		 * 
		 * @param event FocusEvent
		 * @return void
		 */
		private function onTextInputFocusOut(event:FocusEvent):void
		{
			var field:TextField = event.target as TextField;
			field.borderColor = 0x000000;
		}
		
		/**
		 * The title label
		 * 
		 * @return TextField
		 */
		private function titleLabel():TextField
		{
			var field:TextField = createLabelField();
			field.focusRect = false;
			field.width = 100;
            field.height = 20;            
            field.htmlText = "<span class=\"title\">Email this video</span>";
            return field;
		}
		
		/**
		 * The email label
		 * 
		 * @return TextField
		 */
		private function emailToLabel():TextField
		{
			var field:TextField = createLabelField();
			field.width = 150;
            field.height = 15;
            field.htmlText = "<span class=\"label\">Type in an email address <span class=" + 
            		"\"small\">(multiple addresses with commas)</span></span>";
            return field;
		}
		
		/**
		 * The email input
		 * 
		 * @return TextField
		 */
		private function emailToInput():TextField
		{
			var field:TextField = createInputField();  
			field.tabIndex = 1;
			field.mouseWheelEnabled	= true;
			field.width = 0.9 * width;
            field.height = 20;          
            return field;
		}
		
		/**
		 * The message label
		 * 
		 * @return TextField
		 */
		private function messageLabel():TextField
		{
			var field:TextField = createLabelField();        
			field.width = 150;
            field.height = 15;     
            field.htmlText = "<span class=\"label\">Personal message <span class=" + 
            		"\"small\">(optional)</span></span>";
            return field;
		}
		
		/**
		 * The message input
		 * 
		 * @return TextField
		 */
		private function messageInput():TextField
		{
			var field:TextField = createInputField();    
			field.tabIndex = 2;
			field.multiline = true;    
			field.wordWrap = true;    
			field.mouseWheelEnabled	= true;
            field.width = 0.9 * width;
            field.height = 100;
            return field;
		}
		
		/**
		 * The name from label
		 * 
		 * @return TextField
		 */
		private function nameFromLabel():TextField
		{
			var field:TextField = createLabelField();            
			field.width = 100;
            field.height = 15;
            field.htmlText = "<span class=\"label\">Your name <span class=" + 
            		"\"small\">(optional)</span></span>";
            return field;
		}
		
		/**
		 * The name from input
		 * 
		 * @return TextField
		 */
		private function nameFromInput():TextField
		{
			var field:TextField = createInputField();     
			field.tabIndex = 3;
			field.width = 0.5 * (width - (3 * _xPadding));
           	field.height = 20;      
            return field;
		}
		
		/**
		 * The email from label
		 * 
		 * @return TextField
		 */
		private function emailFromLabel():TextField
		{
			var field:TextField = createLabelField();     
			field.width = 100;
            field.height = 15;       
            field.htmlText = "<span class=\"label\">Your email address <span class=" + 
            		"\"small\">(optional)</span></span>";
            return field;
		}
		
		/**
		 * The email from input
		 * 
		 * @return TextField
		 */
		private function emailFromInput():TextField
		{
			var field:TextField = createInputField();  
			field.tabIndex = 4;
			field.width = 0.5 * (width - (3 * _xPadding));
            field.height = 20;    
            return field;
		}
		
		/**
		 * The email success / error label
		 * 
		 * @return TextField
		 */
		private function emailSuccessLabel():TextField
		{
			var field:TextField = createLabelField();     
			field.width = 100;
            field.height = 15;       
            return field;
		}
		
		/**
		 * Setup the form elements
		 * 
		 * @return void
		 */
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
            _sendBtn.tabEnabled = true;
            _sendBtn.tabIndex = 5;
            _sendBtn.buttonMode = true;
            _sendBtn.addEventListener(MouseEvent.MOUSE_DOWN, onSubmit);
            
            _formContainer.addChild(_sendBtn);
            
            //set the video url to the current page
            _videoURL = URLUtil.pageUrl;
            
            //arrange the form elements
            arrangeForm();

		}
		
		/**
		 * Request the email script token to be used to submit to the email system
		 * 
		 * @return void
		 */
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
		
		/**
		 * Send the form to the email server side system
		 * 
		 * @return void
		 */
		private function sendServerEmail():void
		{
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(_config.emailScriptURL);
			request.method = URLRequestMethod.POST;	
			
			//set the post variables from the form elements
			var param:URLVariables = new URLVariables();
			param.name = _nameFromInput.text;
			param.email = _emailFromInput.text;
			param.to = _emailToInput.text;
			//format the message from the message template
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
		
		/**
		 * Send the email locally, launching an email client using mailto:
		 * 
		 * @return void
		 */
		private function sendLocalEmail():void
		{
			var request:URLRequest = new URLRequest(StringUtil.formatString("mailto:{0}?subject={1}&body={2}",_emailToInput.text, escape(_config.emailSubject), escape(StringUtil.formatString(_config.emailTemplate, _messageInput.text, _videoURL, _videoURL))));
			navigateToURL(request, "_self");
		}
		
		/**
		 * Set the error message for the form
		 * 
		 * @param error String
		 * @return void
		 */
		private function formError(error:String):void
		{
			_emailSuccessLabel.htmlText = '<span class="error">' + error + '</span>';	
		}
		
		/**
		 * Set the send success message for the form
		 * 
		 * @param error String
		 * @return void
		 */
		private function formSuccess(value:String):void
		{
			_emailSuccessLabel.htmlText = '<span class="success">' + value + '</span>';	
		}
		
		/**
		 * Submit handler for the submit button
		 * First checks against an array of required fields, to validate the form input 
		 * Then checks if the email script url is enabled
		 * If the email script token is set, post the form or else request the token from the token script
		 * If the email script url is disabled, a local email is sent
		 * 
		 * 
		 * @return void
		 */
		private function onSubmit(event:MouseEvent):void
		{
			var required:Array = _config.requiredFields;
			var requiredFields:Array = [];
			
			//validate the form input
			if (required.length > 0)
			{
				if (!_nameFromInput.text && required.indexOf("name") !== -1) requiredFields.push("name");
				if (!_emailFromInput.text && required.indexOf("email") !== -1) requiredFields.push("email");
				if (!_emailToInput.text && required.indexOf("to") !== -1) requiredFields.push("to");
				if (!_messageInput.text && required.indexOf("message") !== -1) requiredFields.push("message");
				if (!_config.emailSubject && required.indexOf("subject") !== -1) requiredFields.push("subject");	
			}
			
			//send message required fields are missing
			if (requiredFields.length > 0)
			{
				formError('Following are required ' + requiredFields.join(","));
			} else if (_config.emailScriptURL)
			{
				//email token is already set , post the form
				if (_config.emailScriptToken && !_config.emailScriptTokenURL)
				{
					formSuccess("Sending email ..");
					sendServerEmail();
				} else if (_config.emailScriptTokenURL) {
					//request the email script token to be able to post the form
					formSuccess("Sending email ..");
					getEmailToken();
				} else {
					//email script token url is not enabled just post the form
					formSuccess("Sending email ..");
					sendServerEmail();
				}
				
			} else {
				//send a local email instead
				formSuccess("Sending email ..");
				sendLocalEmail();
			}
		}
		
		/**
		 * Error handler for the email system
		 * 
		 * @param event IOErrorEvent 
		 * @return void
		 */
		private function onSendError(event:IOErrorEvent):void
		{
			log.debug("Error: " + event.text);
			
			formError(event.text);
		}
		
		/**
		 * Success handler for the email system
		 * Messages returned are in the form of a json object with either a success or error key
		 * 
		 * @param event Event 
		 * @return void
		 */
		private function onSendSuccess(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			
			loader.removeEventListener(Event.COMPLETE, onSendSuccess);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onSendError);
			
			
			log.debug(loader.data.toString());
			var message:Object = null;
			
			try {
				message = JSON.decode(loader.data.toString());
			} catch(e:Error) {
				formError("Error sending mail");
			}
			
			loader.close();
			loader = null;
			
			if (message !=null)
			{
				//if we have a error json object key returned
				if (message.error)
				{
					log.debug(message.error);
					formError(message.error);
				}
				
				//if we have a success json object key returned
				if (message.success)
				{
					log.debug(message.success);
					formSuccess(message.success);
				}
			}
			
		}
		
		/**
		 * Error handler for the token script
		 * 
		 * @param event IOErrorEvent 
		 * @return void
		 */
		private function onTokenError(event:IOErrorEvent):void
		{
			log.debug("Error: " + event.text);
			
			formError(event.text);
		}
		
		/**
		 * Success handler for the token script
		 * 
		 * @param event Event 
		 * @return void
		 */
		private function onTokenSuccess(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			
			loader.removeEventListener(Event.COMPLETE, onTokenSuccess);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onTokenError);
			
			log.debug("Loading Token");
			
			log.debug(loader.data.toString());
			
			var data:Object = null;
			
			try {
				data = JSON.decode(loader.data.toString());
			} catch(e:Error) {
				formError("Error requesting token");	
			}

			loader.close();
			loader = null;
			
			if (data !=null)
			{
				//if a json object key is error an error is returned
				if (data.error)
				{
					formError(data.error);	
				} else {
					//we have a token, set the email script token and post the form
					_config.emailScriptToken = data.token;
					sendServerEmail();
				}
			}
			
		}
		
		/**
		 * Arrange the form
		 * 
		 * @return void
		 */
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
		
		/**
		 * Create the close button
		 * 
		 * @return void
		 */
		private function createCloseButton():void {
			_closeButton = new CloseButton(null);
			_closeButton.tabEnabled = false;
			_closeButton.focusRect = false;
			addChild(_closeButton);
			_closeButton.addEventListener(MouseEvent.CLICK, onCloseClicked);
		}
		
		/**
		 * Close button click event handler
		 * Fade the panel
		 * 
		 * @param event MouseEvent 
		 * @return void
		 */
		 
		private function onCloseClicked(event:MouseEvent):void {
			_player.animationEngine.fadeOut(this, 500, onFadeOut);
		}
		
		/**
		 * Fade animate handler
		 * When the panel is faded out, remove it from the parent
		 * 
		 * @return void
		 */
		private function onFadeOut():void {
			ShareEmbed(_plugin.getDisplayObject()).removeChild(this);
		}
	}
}
