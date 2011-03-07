/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.playlist {

    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.PlayerEvent;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.model.PluginEventType;
    import org.flowplayer.ui.Dock;
    import org.flowplayer.util.PropertyBinder;
    
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.FlowStyleSheet;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.Styleable;
    import org.flowplayer.view.StyleableSprite;
    
    import org.flowplayer.playlist.config.Config;
    import org.flowplayer.playlist.ui.CloseButton;
    import org.flowplayer.playlist.ui.PlaylistItemController;
    import org.flowplayer.playlist.ui.PlaylistButton;


    public class PlaylistProvider extends AbstractSprite implements Plugin, Styleable {



        public var _player:Flowplayer;
        private var _model:PluginModel;
        private var _config:Config;

        private var _playlistContainer:Sprite;


        private var _closeButton:CloseButton;
        private var _iconDock:Dock;
        private var _playlistScroller:PlaylistScroller;
       

        public function onConfig(plugin:PluginModel):void {
            log.debug("onConfig()", plugin.config);
            _model = plugin;
            _config = new PropertyBinder(new Config(), null).copyProperties(_model.config) as Config;
        }

        /*private function arrangeView(view:StyleableSprite):void {
            if (view) {
                view.setSize(width, height);
                view.y = TAB_HEIGHT;
            }
        }*/
        
        private function arrangePlaylist():void {
        	if (_playlistContainer) _playlistContainer.y = _player.screen.getDisplayObject().height - _playlistContainer.height;
        }

        private function arrangeCloseButton():void {
            //_closeButton.width = width * .05;
            //_closeButton.height = width * .05;
            _closeButton.x = width - _closeButton.width / 2 - 2;
            _closeButton.y = 5;
            //setChildIndex(_closeButton, numChildren - 1);
        }

        override protected function onResize():void {
            arrangeCloseButton();
            //arrangePlaylist();
        }

        private function createPlaylistContainer():void {
            _playlistContainer = new Sprite();
            addChild(_playlistContainer);
        }

        private function createCloseButton(icon:DisplayObject = null):void {
            _closeButton = new CloseButton(_config.closeButton, _player.animationEngine);
          
            _playlistContainer.addChild(_closeButton);
            _closeButton.addEventListener(MouseEvent.CLICK, close);
        }

        private function createIconDock():void {
            if (_iconDock) return;
            _iconDock = Dock.getInstance(_player);
            var addIcon:Function = function(icon:DisplayObject, clickCallback:Function):void {
                _iconDock.addIcon(icon);
                icon.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                    clickCallback();
                });
            };

            addIcon(new PlaylistButton(_config.iconConfig, _player.animationEngine), function():void { fadeIn(); });
            _iconDock.addToPanel()
        }


        public function onLoad(player:Flowplayer):void {
            log.debug("onLoad()");
            
            this.visible = false;
            _player = player;
 
            createPlaylistContainer();
            createIconDock();
            createCloseButton();

            _player.onLoad(onPlayerLoad);



            _player.onLoad(onPlayerLoad);
            _model.dispatchOnLoad();
        }

        private function fadeIn():void {

            _player.animationEngine.animate(_playlistContainer, { y: height - _playlistContainer.height}, 2000 , function():void {
                   // this.visible = true;
                   // this.alpha = 0;

                    return;
                    });

            this.visible = true;
            this.alpha = 0;
            _player.setKeyboardShortcutsEnabled(false);
            _player.animationEngine.fadeIn(this);
        }

        private function onPlayerLoad(event:PlayerEvent):void {
            log.debug("onPlayerLoad() ");

            _iconDock.addToPanel();
            _iconDock.onShow(onDockShow);

            createPlaylistScroller();
           
        }

        private function onDockShow():Boolean {
            return ! this.visible || this.alpha == 0;
        }

        public function getDefaultConfig():Object {
            return {
                //top: "45%",
                left: "50%",
                bottom: 30,
                opacity: 1,
                borderRadius: 15,
                border: 'none',
                width: "90%",
                height: "100%"
            };
        }

        private function createPlaylistScroller():void {
            _playlistScroller = new PlaylistScroller(_player, _config);
            //_playlistScroller.x = 0;
            _playlistScroller.y = _closeButton.height;
            _playlistScroller.width = width;
            _playlistScroller.height = 150;
            _playlistScroller.onPlaylistChange(function():void {
                close();
            });
            
            //addChild(_playlistScroller);
            _playlistContainer.addChild(_playlistScroller);
            //_playlistContainer.y = height - _playlistContainer.height;
             _playlistContainer.y = height;
             //_closeButton.y = _playlistContainer.y - _closeButton.height;
            //_playlistContainer.y = _closeButton.height;
            //_playlistContainer.y = height - _playlistContainer.height;
        }

        public function close(event:MouseEvent = null):void {
            _player.animationEngine.animate(_playlistContainer, { y: height}, 1000 , function():void {
                    //this.visible = false;
                   // this.alpha = 0;
                    return;
                    });
            this.visible = false;
            _player.animationEngine.fadeOut(this, 500, onFadeOut);
        }

        private function onFadeOut():void {
            displayButtons(true);
            _player.setKeyboardShortcutsEnabled(true);

            _model.dispatch(PluginEventType.PLUGIN_EVENT, "onClose");
        }



        public function displayButtons(display:Boolean):void {
            if (display) {
                _iconDock.startAutoHide();
            } else {
                log.debug("stopping auto hide and hiding buttons");
                _iconDock.stopAutoHide(false);
            }
        }

        public function css(styleProps:Object = null):Object {
            return {};
        }

        public function animate(styleProps:Object):Object {
            return {};
        }

        public function onBeforeCss(styleProps:Object = null):void {
            _iconDock.cancelAnimation();
        }

        public function onBeforeAnimate(styleProps:Object):void {
            _iconDock.cancelAnimation();
        }
    }
}
