/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.viralvideos {

    import flash.events.MouseEvent;
    import flash.external.ExternalInterface;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.text.TextField;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.PluginError;
    import org.flowplayer.ui.AbstractButton;
    import org.flowplayer.util.Arrange;
    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.viralvideos.config.ShareConfig;
    import org.flowplayer.viralvideos.icons.AbstractIcon;
    import org.flowplayer.viralvideos.icons.BeboIcon;
    import org.flowplayer.viralvideos.icons.DiggIcon;
    import org.flowplayer.viralvideos.icons.FacebookIcon;
    import org.flowplayer.viralvideos.icons.LivespacesIcon;
    import org.flowplayer.viralvideos.icons.MyspaceIcon;
    import org.flowplayer.viralvideos.icons.OrkutIcon;
    import org.flowplayer.viralvideos.icons.StumbleuponIcon;
    import org.flowplayer.viralvideos.icons.TwitterIcon;

    internal class ShareView extends StyleableView {

        private var _config:ShareConfig;

        private var _videoURL:String;
        private var _facebookURL:String = "http://www.facebook.com/share.php?t={0}&u={1}";
        private var _twitterURL:String = "http://twitter.com/home?status={0}: {1}";
        private var _myspaceURL:String = "http://www.myspace.com/Modules/PostTo/Pages/?t={0}&c={1}&u={2}&l=1";
        private var _beboURL:String = "http://www.bebo.com/c/share?Url={1}&Title={0}";
        private var _orkutURL:String = "http://www.orkut.com/FavoriteVideos.aspx?u={0}";
        private var _diggURL:String = "http://digg.com/submit?phase=2&url={1];title={0}&bodytext={2}&topic={3}";
        private var _stumbleUponURL:String = "http://www.stumbleupon.com/submit?url={1}&title={0}";
        private var _liveSpacesURL:String = "http://spaces.live.com/BlogIt.aspx?Title={0}&SourceURL={1}&description={2}";

        private var _facebookIcon:AbstractIcon;
        private var _myspaceIcon:AbstractButton;
        private var _twitterIcon:AbstractButton;
        private var _beboIcon:AbstractButton;
        private var _diggIcon:AbstractButton;
        private var _orkutIcon:AbstractButton;
        private var _stumbleUponIcon:AbstractButton;
        private var _liveSpacesIcon:AbstractButton;
        
        private var _title:TextField;
        private var _embedCode:String;
        private var _iconArray:Array;
        private var _originalIconHeight:Number;
        private var _originalIconWidth:Number;

        public function ShareView(plugin:DisplayPluginModel, player:Flowplayer, config:ShareConfig, style:Object) {
            super("viral-share", plugin, player, style);
            rootStyle = style;
            _config = config;
            createIcons();
        }

        public function set embedCode(value:String):void {
            _embedCode = escape(value.replace(/\n/g, ""));
        }

        private function initIcon(enabled:Boolean, icon:AbstractButton, listener:Function):AbstractButton {
            if (! enabled) return null;
            icon.buttonMode = true;
            icon.addEventListener(MouseEvent.MOUSE_DOWN, listener);
            addChild(icon);
            _iconArray.push(icon);
            return icon;
        }

        public function createIcons():void {
            //get the current video page
            if (! ExternalInterface.available) {
                model.dispatchError(PluginError.ERROR, "ExternalInterface not available, social site sharing not possible");
            }
            _videoURL = ExternalInterface.call("self.location.href.toString");
            log.debug("Page URL to share is " + _videoURL);
            _iconArray = new Array();
//            _facebookIcon = new FacebookIcon() as Sprite;

            _title = createLabelField();
            _title.htmlText = "<span class=\"title\">" + _config.title + "</span>";
            addChild(_title);

            _facebookIcon = AbstractIcon(initIcon(_config.facebook, new FacebookIcon(_config.icons, player.animationEngine), shareFacebook));
            _originalIconWidth = _facebookIcon.width;
            _originalIconHeight = _facebookIcon.height;
            _twitterIcon = initIcon(_config.twitter, new TwitterIcon(_config.icons, player.animationEngine), shareTwitter);
            _myspaceIcon = initIcon(_config.myspace, new MyspaceIcon(_config.icons, player.animationEngine), shareMyspace);
            _liveSpacesIcon = initIcon(_config.livespaces, new LivespacesIcon(_config.icons, player.animationEngine), shareLiveSpaces);
            
            _beboIcon = initIcon(_config.bebo, new BeboIcon(_config.icons, player.animationEngine), shareBebo);
            _diggIcon = initIcon(_config.digg, new DiggIcon(_config.icons, player.animationEngine), shareDigg);
            _orkutIcon = initIcon(_config.orkut, new OrkutIcon(_config.icons, player.animationEngine), shareOrkut);
            _stumbleUponIcon = initIcon(_config.stubmbleupon, new StumbleuponIcon(_config.icons, player.animationEngine), shareStumbleUpon);
        }

        private function shareFacebook(event:MouseEvent):void {
            var url:String = formatString(_facebookURL, _config.description, _videoURL);
            launchURL(url, _config.popupDimensions.facebook);
        }

        private function shareMyspace(event:MouseEvent):void {
            var url:String = formatString(_myspaceURL, _config.description, _embedCode, _videoURL);
            launchURL(url, _config.popupDimensions.myspace);
        }

        private function shareDigg(event:MouseEvent):void {
            var url:String = formatString(_diggURL, _config.description, _videoURL, _config.body, _config.category);
            launchURL(url, _config.popupDimensions.digg);
        }

        private function shareBebo(event:MouseEvent):void {
            var url:String = formatString(_beboURL, _config.description, _videoURL);
            launchURL(url, _config.popupDimensions.bebo);
        }

        private function shareOrkut(event:MouseEvent):void {
            var url:String = formatString(_orkutURL, _videoURL);
            launchURL(url, _config.popupDimensions.orkut);
        }

        private function shareTwitter(event:MouseEvent):void {
            var url:String = formatString(_twitterURL, _config.description, _videoURL);
            launchURL(url, _config.popupDimensions.twitter);
        }

        private function shareStumbleUpon(event:MouseEvent):void {
            var url:String = formatString(_stumbleUponURL, _config.description, _videoURL);
            launchURL(url, _config.popupDimensions.stumbleupon);
        }

        private function shareLiveSpaces(event:MouseEvent):void {
            var url:String = formatString(_liveSpacesURL, _config.description, _videoURL, _embedCode);
            launchURL(url, _config.popupDimensions.livespaces);
        }

        private function launchURL(url:String, popUpDimensions:Array):void {
            url = escape(url);
            var request:URLRequest;

            //if we are using a popup window, launch javascript with window.open
            if (_config.popupOnClick)
            {
                var jscommand:String = "window.open('" + url + "','PopUpWindow','height=" + popUpDimensions[0] + ",width=" + popUpDimensions[1] + ",toolbar=yes,scrollbars=yes');";
                request = new URLRequest("javascript:" + jscommand + " void(0);");
                navigateToURL(request, "_self");
            } else {
                //request a blank page
                request = new URLRequest(url);
                navigateToURL(request, "_blank");
            }
        }

        private function arrangeIcons():void {
            var margin:int = width >= 320 ? width * .12 : width * .05;
            const PADDING_NON_SCALED:int = width >= 320 ? 25 : 10;

            var numCols:int = _iconArray.length >= 4 ? 4 : _iconArray.length;
            log.debug("arrangeIcons(), number of columns " + numCols);

            var lineWidth:Number = (_originalIconWidth * numCols) + (numCols-1) * PADDING_NON_SCALED;
            var scaling:Number = (width-2*margin) / lineWidth;

            // try if too tall, and reset scaling accordingly
            if (_originalIconHeight * scaling > height - 2 * margin) {
                scaling = (height-2*margin) / _originalIconHeight;
            }

            var padding:Number = PADDING_NON_SCALED * scaling;
            var leftEdge:int = width/2 - numCols/2 * _originalIconWidth * scaling - (numCols > 1 ? (numCols/2-1) * padding : 0);

            var numRows:int = _iconArray.length > 4 ? 2 : 1;
            var yPos:int = Math.max(height/2 - (_originalIconHeight * scaling / (numRows == 1 ? 2 : 1)) - (numRows == 2 ? padding/2 : 0), _title.y + _title.height + 10);

            var iconNum:int = 0;
            var xPos:int = leftEdge;
            for (var name:String in _iconArray) {
                var icon:AbstractButton = _iconArray[name] as AbstractButton;
                icon.setSize(_originalIconWidth * scaling, _originalIconHeight * scaling);

                iconNum++;
                if (iconNum > 4) {
                    iconNum = 0;
                    xPos = leftEdge;
                    yPos += icon.height + 15 * scaling;
                }
                icon.x = xPos;
                icon.y = yPos;
                xPos += icon.width + padding;
            }

        }

        private function arrangeTitle():void {
            _title.width = _title.textWidth + 5;
            _title.height = 20;
            Arrange.center(_title, width);
            _title.y = MARGIN_TOP;
        }

        override protected function onResize():void {
            log.debug("onResize() " + width + " x " + height);
            arrangeTitle();
            arrangeIcons();
        }
    }
}
