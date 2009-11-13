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
	

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;

	import com.ediblecode.util.StringUtil;

	import flash.net.navigateToURL;
	import flash.external.ExternalInterface;

	import org.flowplayer.shareembed.assets.MyspaceIcon;
	import org.flowplayer.shareembed.assets.TwitterIcon;
	import org.flowplayer.shareembed.assets.FacebookIcon;
	import org.flowplayer.shareembed.assets.BeboIcon;
	import org.flowplayer.shareembed.assets.DiggIcon;
	import org.flowplayer.shareembed.assets.LivespacesIcon;
	import org.flowplayer.shareembed.assets.OrkutIcon;
	import org.flowplayer.shareembed.assets.StumbleuponIcon;

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

		

		public function set closeImage(image:DisplayObject):void {
			if (_closeButton) {
				removeChild(_closeButton);
			}
			createCloseButton(image);
		}
		
	
            
       public function setupShareIcons():void
       {
       		
            //_videoURL = ExternalInterface.call('function () { return window.location.href; }');
            _videoURL = URLUtil.pageUrl;
            
            _facebookIcon = new FacebookIcon() as Sprite;
            _facebookIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareFacebook);
			addChild(_facebookIcon);
            
            _myspaceIcon = new MyspaceIcon() as Sprite;
            _myspaceIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareMyspace);
            addChild(_myspaceIcon);
            
            _twitterIcon = new TwitterIcon() as Sprite;
            _twitterIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareTwitter);
            addChild(_twitterIcon);
            
            _beboIcon = new BeboIcon() as Sprite;
            _beboIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareBebo);
            addChild(_beboIcon);
            
            _diggIcon = new DiggIcon() as Sprite;
            _diggIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareDigg);
            addChild(_diggIcon);
            
            _orkutIcon = new OrkutIcon() as Sprite;
            _orkutIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareOrkut);
            addChild(_orkutIcon);
            
            _stumbleUponIcon = new StumbleuponIcon() as Sprite;
            _stumbleUponIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareStumbleUpon);
            addChild(_stumbleUponIcon);
            
            _liveSpacesIcon = new LivespacesIcon() as Sprite;
            _liveSpacesIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareLiveSpaces);
            addChild(_liveSpacesIcon);
            
            arrangeIcons();
			
		}
		
		private function shareFacebook(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_facebookURL, _config.shareSubject, _videoURL);
			launchURL(url, _config.popUpDimensions.facebook);
		}
		
		private function shareMyspace(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_myspaceURL,_config.shareSubject, _embedCode, _videoURL);
			launchURL(url,_config.popUpDimensions.myspace);
		}
		
		private function shareDigg(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_diggURL, _config.shareSubject, _videoURL,_config.shareBody, _config.shareCategory);
			launchURL(url,_config.popUpDimensions.digg);
		}
		
		private function shareBebo(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_beboURL, _config.shareSubject, _videoURL);
			launchURL(url,_config.popUpDimensions.bebo);
		}
		
		private function shareOrkut(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_orkutURL, _videoURL);
			launchURL(url, _config.popUpDimensions.orkut);
		}
		
		private function shareTwitter(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_twitterURL, _config.shareSubject, _videoURL);
			launchURL(url, _config.popUpDimensions.twitter);
		}
		
		private function shareStumbleUpon(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_stumbleUponURL, _config.shareSubject, _videoURL);
			launchURL(url, _config.popUpDimensions.stumbleupon);
		}
		
		private function shareLiveSpaces(event:MouseEvent):void
		{
			var url:String = StringUtil.formatString(_liveSpacesURL, _config.shareSubject, _videoURL, _embedCode);
			launchURL(url, _config.popUpDimensions.livespaces);
		}
		
		private function launchURL(url:String, popUpDimensions:Array):void
		{
			url = escape(url);
			var request:URLRequest;
			
			if (_config.usePopup)
			{
				var jscommand:String = "window.open('" + url + "','PopUpWindow','height=" + popUpDimensions[0] + ",width=" + popUpDimensions[1] + ",toolbar=no,scrollbars=yes');";
            	request = new URLRequest("javascript:" + jscommand + " void(0);");
            	navigateToURL(request, "_self");
			} else {
				request = new URLRequest(url);
				navigateToURL(request, "_blank");
			};
			
		}
		
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
