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

    import com.ediblecode.util.StringUtil;

    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.text.TextField;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.shareembed.assets.BeboIcon;
    import org.flowplayer.shareembed.assets.DiggIcon;
    import org.flowplayer.shareembed.assets.FacebookIcon;
    import org.flowplayer.shareembed.assets.LivespacesIcon;
    import org.flowplayer.shareembed.assets.MyspaceIcon;
    import org.flowplayer.shareembed.assets.OrkutIcon;
    import org.flowplayer.shareembed.assets.StumbleuponIcon;
    import org.flowplayer.shareembed.assets.TwitterIcon;
    import org.flowplayer.shareembed.config.ShareConfig;
    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;

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

        private var _facebookIcon:Sprite;
        private var _myspaceIcon:Sprite;
        private var _twitterIcon:Sprite;
        private var _beboIcon:Sprite;
        private var _diggIcon:Sprite;
        private var _orkutIcon:Sprite;
        private var _stumbleUponIcon:Sprite;
        private var _liveSpacesIcon:Sprite;
        private var _title:TextField;

        private var _iconArray:Array;
        private var _embedCode:String;

        public function ShareView(plugin:DisplayPluginModel, player:Flowplayer, config:ShareConfig, style:Object) {
            super("viral-share", plugin, player, style);
            rootStyle = style;
            _config = config;
            createIcons();
        }

        public function set embedCode(value:String):void {
            _embedCode = escape(value.replace(/\n/g, ""));
        }

        private function initIcon(enabled:Boolean, icon:Sprite, listener:Function):Sprite {
            if (! enabled) return null;
            icon.buttonMode = true;
            icon.addEventListener(MouseEvent.MOUSE_DOWN, listener);
            addChild(icon);
            _iconArray.push(icon);
            return icon;
        }

        public function createIcons():void {
            //get the current video page
            _videoURL = URLUtil.pageUrl;
            _iconArray = new Array();
            _facebookIcon = new FacebookIcon() as Sprite;

            _title = createLabelField();
            _title.htmlText = "<span class=\"title\">" + _config.title + "</span>";
            addChild(_title);

            _facebookIcon = initIcon(_config.facebook, new FacebookIcon() as Sprite, shareFacebook);
            _twitterIcon = initIcon(_config.twitter, new TwitterIcon() as Sprite, shareTwitter);
            _myspaceIcon = initIcon(_config.myspace, new MyspaceIcon() as Sprite, shareMyspace);
            _liveSpacesIcon = initIcon(_config.livespaces, new LivespacesIcon() as Sprite, shareLiveSpaces);
            
            _beboIcon = initIcon(_config.bebo, new BeboIcon() as Sprite, shareBebo);
            _diggIcon = initIcon(_config.digg, new DiggIcon() as Sprite, shareDigg);
            _orkutIcon = initIcon(_config.orkut, new OrkutIcon() as Sprite, shareOrkut);
            _stumbleUponIcon = initIcon(_config.stubmbleupon, new StumbleuponIcon() as Sprite, shareStumbleUpon);
        }

        private function shareFacebook(event:MouseEvent):void {
            var url:String = StringUtil.formatString(_facebookURL, _config.title, _videoURL);
            launchURL(url, _config.icons.facebook);
        }

        private function shareMyspace(event:MouseEvent):void {
            var url:String = StringUtil.formatString(_myspaceURL, _config.title, _embedCode, _videoURL);
            launchURL(url, _config.icons.myspace);
        }

        private function shareDigg(event:MouseEvent):void {
            var url:String = StringUtil.formatString(_diggURL, _config.title, _videoURL, _config.body, _config.category);
            launchURL(url, _config.icons.digg);
        }

        private function shareBebo(event:MouseEvent):void {
            var url:String = StringUtil.formatString(_beboURL, _config.title, _videoURL);
            launchURL(url, _config.icons.bebo);
        }

        private function shareOrkut(event:MouseEvent):void {
            var url:String = StringUtil.formatString(_orkutURL, _videoURL);
            launchURL(url, _config.icons.orkut);
        }

        private function shareTwitter(event:MouseEvent):void {
            var url:String = StringUtil.formatString(_twitterURL, _config.title, _videoURL);
            launchURL(url, _config.icons.twitter);
        }

        private function shareStumbleUpon(event:MouseEvent):void {
            var url:String = StringUtil.formatString(_stumbleUponURL, _config.title, _videoURL);
            launchURL(url, _config.icons.stumbleupon);
        }

        private function shareLiveSpaces(event:MouseEvent):void {
            var url:String = StringUtil.formatString(_liveSpacesURL, _config.title, _videoURL, _embedCode);
            launchURL(url, _config.icons.livespaces);
        }

        private function launchURL(url:String, popUpDimensions:Array):void {
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

        private function get firstIcon():DisplayObject {
            for (var name:String in _iconArray) {
                return _iconArray[name];
            }
            return null;
        }

        private function arrangeIcons():void {
            var margin:int = width * .12;
            const PADDING_NON_SCALED:int = 10;

            firstIcon.scaleX = firstIcon.scaleY = 1;
            var numCols:int = _iconArray.length >= 4 ? 4 : _iconArray.length;
            log.debug("arrangeIcons(), number of columns " + numCols);

            var lineWidth:Number = (firstIcon.width * numCols) + (numCols-1) * PADDING_NON_SCALED;
            var scaling:Number = (width-2*margin) / lineWidth;

            // try if too tall, and reset scaling accordingly
            if (firstIcon.height * scaling > height - 2 * margin) {
                scaling = (height-2*margin) / firstIcon.height;
            }

            var padding:Number = PADDING_NON_SCALED * scaling;
            var leftEdge:int = width/2 - numCols/2 * firstIcon.width * scaling - (numCols > 1 ? (numCols/2-1) * padding : 0);

            var numRows:int = _iconArray.length > 4 ? 2 : 1;
            var yPos:int = Math.max(height/2 - (firstIcon.height * scaling / (numRows == 1 ? 2 : 1)) - (numRows == 2 ? padding/2 : 0), _title.y + _title.height + padding);

            var iconNum:int = 0;
            var xPos:int = leftEdge;
            for (var name:String in _iconArray) {
                var icon:DisplayObject = _iconArray[name] as DisplayObject;
                icon.scaleX = icon.scaleY = scaling;

                iconNum++;
                if (iconNum > 4) {
                    iconNum = 0;
                    xPos = leftEdge;
                    yPos += icon.height + padding;
                }
                icon.x = xPos;
                icon.y = yPos;
                xPos += icon.width + padding;
            }

        }

        private function arrangeTitle():void {
            _title.width = width - 20;
            _title.height = 20;
            _title.x = 10;
            _title.y = 10;
        }

        override protected function onResize():void {
            log.debug("onResize() " + width + " x " + height);
            arrangeTitle();
            arrangeIcons();
        }
    }
}
