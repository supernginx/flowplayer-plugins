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

    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.PlayerEvent;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.shareembed.assets.EmailBtn;
    import org.flowplayer.shareembed.assets.EmbedBtn;
    import org.flowplayer.shareembed.assets.ShareBtn;
    import org.flowplayer.shareembed.config.Config;
    import org.flowplayer.ui.AutoHide;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.FlowStyleSheet;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.Styleable;
    import org.flowplayer.view.StyleableSprite;

    public class ShareEmbed extends AbstractSprite implements Plugin, Styleable {

        private const BORDER:int = 1;
        private const TAB_HEIGHT:int = 20;
        private const TAB_WIDTH:int = 100;
        private const TAB_HEIGHT_LIVE:int = 20 + (BORDER);

        public var _player:Flowplayer;
        private var _model:PluginModel;
        private var _config:Config;
        private var _playerEmbed:PlayerEmbed;

        private var _embedBtn:Sprite;
        private var _emailBtn:Sprite;
        private var _shareBtn:Sprite;

        private var _btnContainer:Sprite;
        private var _tabContainer:Sprite;
        private var _panelContainer:Sprite;

        private var _embedView:EmbedView;
        private var _emailView:EmailView;
        private var _shareView:ShareView;
        private var _emailMask:Sprite = new Sprite();
        private var _shareMask:Sprite = new Sprite();
        private var _embedMask:Sprite = new Sprite();

        public var _embedTab:Tab;
        public var _emailTab:Tab;
        public var _shareTab:Tab;

        private var _closeButton:CloseButton;
        private var _tabCSSProperties:Object;
        private var _autoHide:AutoHide;

        public function onConfig(plugin:PluginModel):void {
            _model = plugin;
            //_config = new PropertyBinder(new Config(), null).copyProperties(plugin.config) as Config;
            _config = new PropertyBinder(new Config(), null).copyProperties(_model.config) as Config;
        }

        private function arrangeView(view:StyleableSprite):void {
            if (view) {
                view.setSize(width, height);
                view.y = 20;
            }
        }

        private function arrangeCloseButton():void {
            _closeButton.x = width;
            _closeButton.y = TAB_HEIGHT;
            setChildIndex(_closeButton, numChildren - 1);
        }

        override protected function onResize():void {
            arrangeView(_emailView);
            arrangeView(_embedView);
            arrangeView(_shareView);
            arrangeCloseButton();
        }

        private function createButtonContainer():void {
            _btnContainer = new Sprite();

            if (_config.email) {
                _emailBtn = new EmailBtn() as Sprite;
                _btnContainer.addChild(_emailBtn);
            }

            if (_config.embed) {
                _embedBtn = new EmbedBtn() as Sprite;
                _btnContainer.addChild(_embedBtn);
                _embedBtn.y = _emailBtn.y + _emailBtn.height + 5;
            }

            if (_config.share) {
                _shareBtn = new ShareBtn() as Sprite;
                _btnContainer.addChild(_shareBtn);
                _shareBtn.y = _embedBtn.y + _embedBtn.height + 5;
            }

            _player.addToPanel(_btnContainer, {right:10, top: 0, zIndex: 100});
        }

        private function createPanelContainer():void {
            _panelContainer = new Sprite();
            addChild(_panelContainer);
        }

        private function createCloseButton(icon:DisplayObject = null):void {
            _closeButton = new CloseButton(icon);
            addChild(_closeButton);
            _closeButton.addEventListener(MouseEvent.CLICK, onCloseClicked);
        }

        public function onLoad(player:Flowplayer):void {
            this.visible = false;
            _player = player;

            createPanelContainer();
            createButtonContainer();
            createTabs();
            createCloseButton();

            _emailBtn.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                fadeIn("Email");
            });
            _embedBtn.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                fadeIn("Embed");
            });
            _shareBtn.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                fadeIn("Share");
            });

            _player.onLoad(onPlayerLoad);
            _model.dispatchOnLoad();
        }

        private function fadeIn(view:String):void {
            this.visible = true;
            this.alpha = 0;
            setActiveTab(view);
            _player.animationEngine.fadeIn(this);
        }

        private function onPlayerLoad(event:PlayerEvent):void {
            _playerEmbed = new PlayerEmbed(_player, _model.name, stage, stage.loaderInfo.parameters["config"]);
            _config.playerEmbed = _playerEmbed;

            createViews();
            initializeTabProperties();

            _autoHide = new AutoHide(null, _config.autoHide, _player, stage, _btnContainer);
            _autoHide.start();
        }

        private function createViews():void {
            if (_config.email) {
                createEmailView();
            }
            if (_config.share) {
                createShareView();
            }
            if (_config.embed) {
                createEmbedView();
            }
        }

        private function initializeTabProperties():void {
            var gradient:Array = null;
            if (_config.canvas.hasOwnProperty("backgroundGradient")) {
                var gradArr:Array = FlowStyleSheet.decodeGradient(_config.canvas.backgroundGradient);
                gradient = [gradArr[0], gradArr[0]];
            }
            _tabCSSProperties = getViewCSSProperties();
            if (gradient) {
                _tabCSSProperties.backgroundGradient = gradient;
            }
        }

        public function getDefaultConfig():Object {
            return {
                top: "45%",
                left: "50%",
                opacity: 1,
                borderRadius: 10,
                border: 'none',
                width: "80%",
                height: "80%"
            };
        }

        //Javascript API functions

        private function createEmailView():void {
            _config.setEmail(true);
            _emailView = new EmailView(_model as DisplayPluginModel, _player, _config.email, _config.canvas);
            //_emailView.setSize(stage.width, stage.height);
            _panelContainer.addChild(_emailView);
        }

        [External]
        public function email():void {
            showViews('Email');
        }

        private function createEmbedView():void {
            _embedView = new EmbedView(_model as DisplayPluginModel, _player, _config.embed, _config.canvas);
            //_embedView.setSize(stage.width, stage.height);
            _panelContainer.addChild(_embedView);
            //get the embed code and return it to the embed code textfield
        }

        [External]
        public function embed():void {
            showViews('Embed');
        }


        private function createShareView():void {
            _shareView = new ShareView(_model as DisplayPluginModel, _player, _config.share, _config.canvas);
            //return the embed code to be used for some of the social networking site links like myspace
            _panelContainer.addChild(_shareView);
        }

        [External]
        public function share():void {
            showViews('Share');
        }

        public function showView(panel:String):void {
            displayButtons(false);

            if (_emailView) _emailView.visible = false;
            if (_embedView) _embedView.visible = false;
            if (_shareView) _shareView.visible = false;

            if (panel == "Email") _emailView.show();
            if (panel == "Embed") _embedView.show();
            if (panel == "Share") _shareView.show();
        }


        private function onCloseClicked(event:MouseEvent):void {
            _player.animationEngine.fadeOut(this, 500, onFadeOut);
        }

        private function onFadeOut():void {
            displayButtons(true);
        }

        public function setActiveTab(newTab:String):void {
            log.debug("setActiveTab() " + newTab);

            if (_emailView) {
                _emailMask.height = TAB_HEIGHT;
                _emailTab.css({backgroundGradient: 'medium'})
            }
            if (_embedView) {
                _embedMask.height = TAB_HEIGHT;
                _embedTab.css({backgroundGradient: 'medium'})
            }
            if (_shareView) {
                _shareMask.height = TAB_HEIGHT;
                _shareTab.css({backgroundGradient: 'medium'})
            }

            if (newTab == "Email") {
                _emailMask.height = TAB_HEIGHT_LIVE;
                _emailTab.css(_tabCSSProperties);
            }
            if (newTab == "Embed") {
                _embedMask.height = TAB_HEIGHT_LIVE;
                _embedTab.css(_tabCSSProperties);
            }
            if (newTab == "Share") {
                _shareMask.height = TAB_HEIGHT_LIVE;
                _shareTab.css(_tabCSSProperties);
            }

            showView(newTab);
            arrangeView(getView(newTab));

        }

        private function getViewCSSProperties():Object {
            if (_emailView) return _emailView.css();
            if (_embedView) return _embedView.css();
            if (_shareView) return _shareView.css();
            return null;
        }

        private function createViewIfNotExists(liveTab:String, viewName:String, view:DisplayObject, createFunc:Function):void {
            if (liveTab == viewName && ! view) {
                createFunc();
            }
        }

        private function showViews(liveTab:String):void {
            this.visible = true;
            this.alpha = 1;

            createViewIfNotExists(liveTab, "Email", _emailView, createEmailView);
            createViewIfNotExists(liveTab, "Embed", _embedView, createEmbedView);
            createViewIfNotExists(liveTab, "Share", _shareView, createShareView);

            setActiveTab(liveTab);
        }

        private function getView(liveTab:String):StyleableSprite {
            if (liveTab == "Email") return _emailView;
            if (liveTab == "Embed") return _embedView;
            if (liveTab == "Share") return _shareView;
            return null
        }

        private function createTab(xpos:int, mask:Sprite, masky:int, tabTitle:String):Tab {
            var tab:Tab = new Tab(_model as DisplayPluginModel, _player, tabTitle);
            tab.setSize(TAB_WIDTH, TAB_HEIGHT * 2);
            tab.x = xpos;
            _tabContainer.addChild(tab);

            mask.graphics.beginFill(0xffffff, 1);
            mask.graphics.drawRect(0, 0, TAB_WIDTH + (BORDER * 2), TAB_HEIGHT_LIVE);
            mask.graphics.endFill();
            mask.x = xpos - (BORDER / 2);
            mask.y = masky;
            tab.mask = mask;
            _tabContainer.addChild(mask);
            return tab;
        }

        private function createTabs():void {
            log.debug("createTabs()");
            _tabContainer = new Sprite();
            addChild(_tabContainer);
            _tabContainer.x = 3;

            var tabXPos:int = 0;
            var masky:int = (BORDER / 2);

            if (_config.email) {
                _emailTab = createTab(tabXPos, _emailMask, masky, "Email");
                tabXPos += TAB_WIDTH + (BORDER * 2);
            }
            if (_config.embed) {
                _embedTab = createTab(tabXPos, _embedMask, masky, "Embed")
                tabXPos += TAB_WIDTH + (BORDER * 2);
            }
            if (_config.share) {
                _shareTab = createTab(tabXPos, _shareMask, masky, "Share")
            }
        }

        public function displayButtons(display:Boolean):void {
            if (display) {
                _autoHide.start();
            } else {
                log.debug("stopping auto hide and hiding buttons");
                _autoHide.stop(false);
            }
        }

        [External]
        public function show():void {
            showViews("Email");
        }

        public function css(styleProps:Object = null):Object {
            return {};
        }

        public function animate(styleProps:Object):Object {
            return {};
        }
    }
}
