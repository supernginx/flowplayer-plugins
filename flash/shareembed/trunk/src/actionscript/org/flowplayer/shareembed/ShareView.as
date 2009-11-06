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
    import flash.filters.GlowFilter;
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
	import flash.text.TextFieldType;
	import flash.events.FocusEvent;
	import flash.net.URLRequest;

	import com.ediblecode.util.StringUtil;

	import flash.net.navigateToURL;
	import flash.external.ExternalInterface;

	import org.flowplayer.shareembed.assets.MyspaceIcon;
	import org.flowplayer.shareembed.assets.TwitterIcon;
	import org.flowplayer.shareembed.assets.FacebookIcon;

	/**
	 * @author api
	 */
	internal class ShareView extends StyleableSprite {

		private var _config:Config;
		private var _closeButton:CloseButton;
		private var _player:Flowplayer;
		private var _plugin:DisplayPluginModel;
		private var _originalAlpha:Number;
		
	

		
		private var _videoURL:String;
		private var _facebookURL:String = "http://www.facebook.com/share.php?t={0}&u={1}";
		private var _twitterURL:String = "http://twitter.com/home?status={0}: {1}";
		private var _myspaceURL:String = "http://www.myspace.com/Modules/PostTo/Pages/?t={0}&u={1}";
		private var _beboURL:String = "http://www.bebo.com/c/share?Url={1}&Title={0}";
		private var _orkutURL:String = "http://www.orkut.com/FavoriteVideos.aspx?u={0}";
		private var _diggURL:String = "http://digg.com/submit?phase=2&amp;url={1];title={0}&amp;bodytext={2}&amp;topic={3}";
		private var _stumbleUpon:String = "http://www.stumbleupon.com/submit?url={1}&amp;title={0}";
		
		private var _facebookIcon:Sprite;
		private var _myspaceIcon:Sprite;
		private var _twitterIcon:Sprite;
		
	
		
		public function ShareView(plugin:DisplayPluginModel, player:Flowplayer, config:Config) {
			super(null, player, player.createLoader());
			_plugin = plugin;
			_player = player;
			_config = config;
		

			createCloseButton();
		
		}

		override protected function onSetStyle(style:FlowStyleSheet):void {
			log.debug("onSetStyle");
			setupShareIcons();
		
		}

		override protected function onSetStyleObject(styleName:String, style:Object):void {
			log.debug("onSetStyleObject");
			setupShareIcons();
		
		}

		

		public function set closeImage(image:DisplayObject):void {
			if (_closeButton) {
				removeChild(_closeButton);
			}
			createCloseButton(image);
		}
		
	
            
       public function setupShareIcons():void
       {
       		
            _videoURL = ExternalInterface.call('function () { return window.location.href; }');
            
            _facebookIcon = new FacebookIcon() as Sprite;
            _facebookIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareFacebook);
			addChild(_facebookIcon);
            
            _myspaceIcon = new MyspaceIcon() as Sprite;
            _myspaceIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareMyspace);
            addChild(_myspaceIcon);
            
            _twitterIcon = new TwitterIcon() as Sprite;
            _twitterIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareTwitter);
            addChild(_twitterIcon);
            
            arrangeIcons();
			
		}
		
		private function shareFacebook(event:MouseEvent):void
		{
		
			var url:String = StringUtil.formatString(_facebookURL, "The video", _videoURL);
	
			
			navigateToURL(new URLRequest(url), "_blank");
		}
		
		private function shareMyspace(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_myspaceURL, "The video", _videoURL);
			
			navigateToURL(new URLRequest(url), "_blank");
		}
		
		private function shareTwitter(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_twitterURL, "The video", _videoURL);
			
			navigateToURL(new URLRequest(url), "_blank");
		}
		
		private function arrangeIcons():void
		{
			_facebookIcon.x = 10;
			_facebookIcon.y = 10;
			
			_myspaceIcon.x = _facebookIcon.x + _facebookIcon.width + 10;
			_twitterIcon.x = _myspaceIcon.x + _myspaceIcon.width + 10;
		}
		
		
		override protected function onResize():void {
			arrangeCloseButton();
			
			//_formContainer.x = 0;
			//_formContainer.y = 0;
			
			
			
			this.x = 0;
			this.y = 0;
		}

		override protected function onRedraw():void {
			//arrangeForm();
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
			//ShareEmbed(_plugin.getDisplayObject()).removeListeners();
			_originalAlpha = _plugin.getDisplayObject().alpha;
			_player.animationEngine.fadeOut(_plugin.getDisplayObject(), 500, onFadeOut);
		}
		
		private function onFadeOut():void {
			log.debug("faded out");
//
			// restore original alpha value
			_plugin.alpha = _originalAlpha;
			_plugin.getDisplayObject().alpha = _originalAlpha;
			// we need to update the properties to the registry, so that animations happen correctly after this
			_player.pluginRegistry.updateDisplayProperties(_plugin);
			
			//Content(_plugin.getDisplayObject()).addListeners();
		}

		override public function set alpha(value:Number):void {
			super.alpha = value;
			
		}
	}
}
