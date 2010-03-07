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
    import org.flowplayer.shareembed.config.Config;
    import org.flowplayer.shareembed.config.ShareConfig;
    import org.flowplayer.view.FlowStyleSheet;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.StyleableSprite;
    import org.flowplayer.util.URLUtil;


    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;


    import flash.utils.getDefinitionByName;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.display.Stage;

    import org.flowplayer.view.FlowStyleSheet;


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

    import flash.text.AntiAliasType;

    internal class ShareView extends StyleableView {

        private var _config:ShareConfig;
        private var _closeButton:CloseButton;

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
        private var _infoField:TextField;

        private var _iconArray:Array;
//        private var button_line_size:Number;
//        private var scale_percentage:Number;

        private var _embedCode:String;

        public function ShareView(plugin:DisplayPluginModel, player:Flowplayer, config:ShareConfig, style:Object) {
            super("viral-share", plugin, player, style);
            rootStyle = style;
            _config = config;
            createCloseButton();
            createIcons();
        }

        public function set embedCode(value:String):void
        {
            _embedCode = escape(value.replace(/\n/g, ""));
        }

        /**
         * Setup social network share icon buttons
         *
         * @return void
         */
        public function createIcons():void
        {
            //get the current video page
            _videoURL = URLUtil.pageUrl;
            _iconArray = new Array();
            _facebookIcon = new FacebookIcon() as Sprite;

            _infoField = player.createTextField();
            _infoField.antiAliasType = AntiAliasType.ADVANCED;
            addChild(_infoField);

            // TODO: Refactor repeated code

            _facebookIcon = new FacebookIcon() as Sprite;
            _facebookIcon.buttonMode = true;
            _facebookIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareFacebook);
            addChild(_facebookIcon);
            _iconArray.push(_facebookIcon);

            //setup myspace
            _myspaceIcon = new MyspaceIcon() as Sprite;
            _myspaceIcon.buttonMode = true;
            _myspaceIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareMyspace);
            addChild(_myspaceIcon);
            _iconArray.push(_myspaceIcon);

            //setup twitter
            _twitterIcon = new TwitterIcon() as Sprite;
            _twitterIcon.buttonMode = true;
            _twitterIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareTwitter);
            addChild(_twitterIcon);
            _iconArray.push(_twitterIcon);

            //setup bebo
            _beboIcon = new BeboIcon() as Sprite;
            _beboIcon.buttonMode = true;
            _beboIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareBebo);
            addChild(_beboIcon);
            _iconArray.push(_beboIcon);

            //setup digg
            _diggIcon = new DiggIcon() as Sprite;
            _diggIcon.buttonMode = true;
            _diggIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareDigg);
            addChild(_diggIcon);
            _iconArray.push(_diggIcon);

            //setup orkut
            _orkutIcon = new OrkutIcon() as Sprite;
            _orkutIcon.buttonMode = true;
            _orkutIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareOrkut);
            addChild(_orkutIcon);
            _iconArray.push(_orkutIcon);

            //setup stumbleupon
            _stumbleUponIcon = new StumbleuponIcon() as Sprite;
            _stumbleUponIcon.buttonMode = true;
            _stumbleUponIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareStumbleUpon);
            addChild(_stumbleUponIcon);
            _iconArray.push(_stumbleUponIcon);

            //setu livespaces
            _liveSpacesIcon = new LivespacesIcon() as Sprite;
            _liveSpacesIcon.buttonMode = true;
            _liveSpacesIcon.addEventListener(MouseEvent.MOUSE_DOWN, shareLiveSpaces);
            addChild(_liveSpacesIcon);
            _iconArray.push(_liveSpacesIcon);
        }

        /**
         * Launch video sharing to facebook
         *
         * @param event MouseEvent
         * @return void
         */
        private function shareFacebook(event:MouseEvent):void
        {
            var url:String = StringUtil.formatString(_facebookURL, _config.title, _videoURL);
            launchURL(url, _config.icons.facebook);
        }

        /**
         * Launch video sharing to myspace
         *
         * @param event MouseEvent
         * @return void
         */
        private function shareMyspace(event:MouseEvent):void
        {
            var url:String = StringUtil.formatString(_myspaceURL, _config.title, _embedCode, _videoURL);
            launchURL(url, _config.icons.myspace);
        }

        /**
         * Launch video sharing to digg
         *
         * @param event MouseEvent
         * @return void
         */
        private function shareDigg(event:MouseEvent):void
        {
            var url:String = StringUtil.formatString(_diggURL, _config.title, _videoURL, _config.body, _config.category);
            launchURL(url, _config.icons.digg);
        }

        /**
         * Launch video sharing to bebo
         *
         * @param event MouseEvent
         * @return void
         */
        private function shareBebo(event:MouseEvent):void
        {
            var url:String = StringUtil.formatString(_beboURL, _config.title, _videoURL);
            launchURL(url, _config.icons.bebo);
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
            launchURL(url, _config.icons.orkut);
        }

        /**
         * Launch video sharing to twitter
         *
         * @param event MouseEvent
         * @return void
         */
        private function shareTwitter(event:MouseEvent):void
        {
            var url:String = StringUtil.formatString(_twitterURL, _config.title, _videoURL);
            launchURL(url, _config.icons.twitter);
        }

        /**
         * Launch video sharing to stumbleupon
         *
         * @param event MouseEvent
         * @return void
         */
        private function shareStumbleUpon(event:MouseEvent):void
        {
            var url:String = StringUtil.formatString(_stumbleUponURL, _config.title, _videoURL);
            launchURL(url, _config.icons.stumbleupon);
        }

        /**
         * Launch video sharing to livespaces
         *
         * @param event MouseEvent
         * @return void
         */
        private function shareLiveSpaces(event:MouseEvent):void
        {
            var url:String = StringUtil.formatString(_liveSpacesURL, _config.title, _videoURL, _embedCode);
            launchURL(url, _config.icons.livespaces);
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
            if (_config.popupOnClick)
            {
                var jscommand:String = "window.open('" + url + "','PopUpWindow','height=" + popUpDimensions[0] + ",width=" + popUpDimensions[1] + ",toolbar=no,scrollbars=yes');";
                request = new URLRequest("javascript:" + jscommand + " void(0);");
                navigateToURL(request, "_self");
            } else {
                //request a blank page
                request = new URLRequest(url);
                navigateToURL(request, "_blank");
            }
        }

        /**
         * Arrange the icon buttons
         *
         * @return void
         */
        private function arrangeIcons():void
        {
            var lineSize:Number = (_facebookIcon.width * 4) + 50;
            var scalePct:Number = _width / lineSize;
            var padding:Number = 10 * scalePct;

//            var tmp_x:int = ((width) / 2) - (((_iconArray[0].width * 2) + (padding * 3)) * scalePct);
//            var tmp_x:int = padding;
            var xPos:int = padding;
            var yPos:int = padding;
            //var init_y:int = 20;

            var rowcounter:int = 0;
            for (var i:String in _iconArray) {
                _iconArray[i].scaleX = _iconArray[i].scaleY = scalePct;
                //if (init_x > _stageWidth - _iconArray[i].width) {
                rowcounter++;
                if (rowcounter > 4) {
                    rowcounter = 0
                    xPos = padding;
                    yPos += _iconArray[i].height + padding;
                }
                _iconArray[i].x = xPos;
                _iconArray[i].y = yPos;
                xPos += _iconArray[i].width + padding;
            }

        }


        override protected function onResize():void {
            _infoField.width = width - 20;
            _infoField.height = 20;

            arrangeCloseButton();
            arrangeIcons();
        }

        private function arrangeCloseButton():void {
            if (_closeButton && style) {
                //_closeButton.x = width - _closeButton.width - 1 - style.borderRadius/5;
                _closeButton.x = width - _closeButton.width;
                //_closeButton.y = 1 + style.borderRadius/5;
                _closeButton.y = _closeButton.height / 3;
                setChildIndex(_closeButton, numChildren - 1);
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
            ShareEmbed(model.getDisplayObject()).removeTabs();
            player.animationEngine.fadeOut(this, 500, onFadeOut);
        }

        /**
         * Fade animate handler
         * When the panel is faded out, remove it from the parent
         *
         * @return void
         */
        private function onFadeOut():void {
            ShareEmbed(model.getDisplayObject()).displayButtons(true);
            //ShareEmbed(_plugin.getDisplayObject()).removeChild(this);
            //ShareEmbed(_plugin.getDisplayObject()).hideSharePanel(this);
        }

        public function closePanel():void {
            ShareEmbed(model.getDisplayObject()).removeChild(this);
            //_player.animationEngine.fadeOut(this, 0, closePanel2);
        }

        public function closePanel2():void {
        }

    }
}
