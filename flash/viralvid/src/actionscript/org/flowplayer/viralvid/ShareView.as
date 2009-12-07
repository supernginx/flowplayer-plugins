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

	import org.flowplayer.model.DisplayPluginModel;
	import org.flowplayer.view.FlowStyleSheet;
	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.view.StyleableSprite;
	import org.flowplayer.util.URLUtil;
	

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;

	import com.ediblecode.util.StringUtil;

	import flash.net.navigateToURL;

	import org.flowplayer.shareembed.assets.MyspaceIcon;
	import org.flowplayer.shareembed.assets.TwitterIcon;
	import org.flowplayer.shareembed.assets.FacebookIcon;
	import org.flowplayer.shareembed.assets.BeboIcon;
	import org.flowplayer.shareembed.assets.DiggIcon;
	import org.flowplayer.shareembed.assets.LivespacesIcon;
	import org.flowplayer.shareembed.assets.OrkutIcon;
	import org.flowplayer.shareembed.assets.StumbleuponIcon;

	/**
	 * @author danielr
	 */
	internal class ShareView extends StyleableSprite {

		private var _config:Config;
		private var _closeButton:CloseButton;
		private var _player:Flowplayer;
		private var _plugin:DisplayPluginModel;
				
		private var _videoURL:String;
		private var _facebookURL:String = "http://www.facebook.com/share.php?t={0}&u={1}";
		private var _twitterURL:String = "http://twitter.com/home?status={0}: {1}";
		private var _myspaceURL:String = "http://www.myspace.com/Modules/PostTo/Pages/?t={0}&c={1}&u={2}&l=1";
		private var _beboURL:String = "http://www.bebo.com/c/share?Url={1}&Title={0}";
		private var _orkutURL:String = "http://www.orkut.com/FavoriteVideos.aspx?u={0}";
		private var _diggURL:String = "http://digg.com/submit?phase=2&url={1];title={0}&bodytext={2}&topic={3}";
		private var _stumbleUponURL:String = "http://www.stumbleupon.com/submit?url={1}&title={0}";
		private var _liveSpacesURL:String = "http://spaces.live.com/BlogIt.aspx?Title={0}&SourceURL={1}&description={2}";
		
		private var _facebookIcon:Sprite;
		private var _myspaceIcon:Sprite;
		private var _twitterIcon:Sprite;
		private var _beboIcon:Sprite;
		private var _diggIcon:Sprite;
		private var _orkutIcon:Sprite;
		private var _stumbleUponIcon:Sprite;
		private var _liveSpacesIcon:Sprite;
		
		private var _embedCode:String;
		
		public function ShareView(plugin:DisplayPluginModel, player:Flowplayer, config:Config) {
			super(null, player, player.createLoader());
			_plugin = plugin;
			_player = player;
			_config = config;
	
			createCloseButton();
		}
		
		public function set embedCode(value:String):void
		{
			_embedCode = escape(value.replace(/\n/g, ""));
		}

		override protected function onSetStyle(style:FlowStyleSheet):void {
			log.debug("onSetStyle");
			setupShareIcons();
		}

		override protected function onSetStyleObject(styleName:String, style:Object):void {
			log.debug("onSetStyleObject");
			setupShareIcons();		
		}

       /**
        * Setup social network share icon buttons
        * 
        * @return void
        */     
       public function setupShareIcons():void
       {
			//get the current video page
            _videoURL = URLUtil.pageUrl;
            
            //setup facebook
            _facebookIcon = new FacebookIcon() as Sprite;
            _facebookIcon.buttonMode = true;
            _facebookIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareFacebook);
			addChild(_facebookIcon);
            
            //setup myspace
            _myspaceIcon = new MyspaceIcon() as Sprite;
            _myspaceIcon.buttonMode = true;
            _myspaceIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareMyspace);
            addChild(_myspaceIcon);
            
            //setup twitter
            _twitterIcon = new TwitterIcon() as Sprite;
            _twitterIcon.buttonMode = true;
            _twitterIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareTwitter);
            addChild(_twitterIcon);
            
            //setup bebo
            _beboIcon = new BeboIcon() as Sprite;
            _beboIcon.buttonMode = true;
            _beboIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareBebo);
            addChild(_beboIcon);
            
            //setup digg
            _diggIcon = new DiggIcon() as Sprite;
            _diggIcon.buttonMode = true;
            _diggIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareDigg);
            addChild(_diggIcon);
            
            //setup orkut
            _orkutIcon = new OrkutIcon() as Sprite;
            _orkutIcon.buttonMode = true;
            _orkutIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareOrkut);
            addChild(_orkutIcon);
            
            //setup stumbleupon
            _stumbleUponIcon = new StumbleuponIcon() as Sprite;
            _stumbleUponIcon.buttonMode = true;
            _stumbleUponIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareStumbleUpon);
            addChild(_stumbleUponIcon);
            
            //setu livespaces
            _liveSpacesIcon = new LivespacesIcon() as Sprite;
            _liveSpacesIcon.buttonMode = true;
            _liveSpacesIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareLiveSpaces);
            addChild(_liveSpacesIcon);
            
            //arrange the icon buttons
            arrangeIcons();
			
		}
		
		/**
		 * Launch video sharing to facebook
		 * 
		 * @param event MouseEvent
		 * @return void
		 */
		private function shareFacebook(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_facebookURL, _config.shareTitle, _videoURL);
			launchURL(url, _config.popUpDimensions.facebook);
		}
		
		/**
		 * Launch video sharing to myspace
		 * 
		 * @param event MouseEvent
		 * @return void
		 */
		private function shareMyspace(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_myspaceURL,_config.shareTitle, _embedCode, _videoURL);
			launchURL(url,_config.popUpDimensions.myspace);
		}
		
		/**
		 * Launch video sharing to digg
		 * 
		 * @param event MouseEvent
		 * @return void
		 */
		private function shareDigg(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_diggURL, _config.shareTitle, _videoURL,_config.shareBody, _config.shareCategory);
			launchURL(url,_config.popUpDimensions.digg);
		}
		
		/**
		 * Launch video sharing to bebo
		 * 
		 * @param event MouseEvent
		 * @return void
		 */
		private function shareBebo(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_beboURL, _config.shareTitle, _videoURL);
			launchURL(url,_config.popUpDimensions.bebo);
		}
		
		/**
		 * Launch video sharing to orkut
		 * 
		 * @param event MouseEvent
		 * @return void
		 */
		private function shareOrkut(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_orkutURL, _videoURL);
			launchURL(url, _config.popUpDimensions.orkut);
		}
		
		/**
		 * Launch video sharing to twitter
		 * 
		 * @param event MouseEvent
		 * @return void
		 */
		private function shareTwitter(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_twitterURL, _config.shareTitle, _videoURL);
			launchURL(url, _config.popUpDimensions.twitter);
		}
		
		/**
		 * Launch video sharing to stumbleupon
		 * 
		 * @param event MouseEvent
		 * @return void
		 */
		private function shareStumbleUpon(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_stumbleUponURL, _config.shareTitle, _videoURL);
			launchURL(url, _config.popUpDimensions.stumbleupon);
		}
		
		/**
		 * Launch video sharing to livespaces
		 * 
		 * @param event MouseEvent
		 * @return void
		 */
		private function shareLiveSpaces(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_liveSpacesURL, _config.shareTitle, _videoURL, _embedCode);
			launchURL(url, _config.popUpDimensions.livespaces);
		}
		
		/**
		 * Launch the url
		 * 
		 * @param url String
		 * @param popUpDimensions Array The pre-configured popup window dimensions
		 * @return void
		 */
		private function launchURL(url:String, popUpDimensions:Array):void
		{
			url = escape(url);
			var request:URLRequest;
			
			//if we are using a popup window, launch javascript with window.open
			if (_config.usePopup)
			{
				var jscommand:String = "window.open('" + url + "','PopUpWindow','height=" + popUpDimensions[0] + ",width=" + popUpDimensions[1] + ",toolbar=no,scrollbars=yes');";
            	request = new URLRequest("javascript:" + jscommand + " void(0);");
            	navigateToURL(request, "_self");
			} else {
				//request a blank page
				request = new URLRequest(url);
				navigateToURL(request, "_blank");
			};
			
		}
		
		/**
		 * Arrange the icon buttons
		 * 
		 * @return void
		 */
		private function arrangeIcons():void
		{
			_facebookIcon.x = 0;
			_facebookIcon.y = 0;
			
			_myspaceIcon.x = _facebookIcon.x + _facebookIcon.width + 10;
			_twitterIcon.x = _myspaceIcon.x + _myspaceIcon.width + 10;
			_beboIcon.y = _myspaceIcon.y + _myspaceIcon.height + 5;
			_diggIcon.y = _myspaceIcon.y + _myspaceIcon.height + 5;
			_diggIcon.x = _beboIcon.x + _beboIcon.width + 5;
			_orkutIcon.y = _myspaceIcon.y + _myspaceIcon.height + 5;
			_orkutIcon.x = _diggIcon.x + _diggIcon.width + 5;
			_stumbleUponIcon.y = _beboIcon.y + _beboIcon.height + 5;
			_liveSpacesIcon.y = _beboIcon.y + _beboIcon.height + 5;
			_liveSpacesIcon.x = _stumbleUponIcon.x + _stumbleUponIcon.width + 5;
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
		private function createCloseButton(icon:DisplayObject = null):void {
			_closeButton = new CloseButton(icon);
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
