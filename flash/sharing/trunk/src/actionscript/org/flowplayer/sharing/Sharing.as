/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2011 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.sharing {
    import flash.display.DisplayObject;

    import flash.events.Event;
    import flash.events.MouseEvent;

    import flash.net.URLRequest;
    import flash.net.navigateToURL;

    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.sharing.Config;
    import org.flowplayer.ui.Dock;
    import org.flowplayer.ui.Notification;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.viralvideos.icons.EmailIcon;
    import org.flowplayer.viralvideos.icons.EmbedIcon;
    import org.flowplayer.viralvideos.icons.FacebookIcon;
    import org.flowplayer.viralvideos.icons.TwitterIcon;

    public class Sharing extends AbstractSprite implements Plugin {
        private var _model:PluginModel;
        private var _dock:Dock;
        private var _config:Config;
        private var _player:Flowplayer;

        public function Sharing() {
            log.debug("Sharing()");
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        private function onAddedToStage(event:Event):void {
            _config = new PropertyBinder(new Config(_player, _model.name, stage)).copyProperties(_model.config) as Config;
            createDock(_player);
        }

        public function onConfig(model:PluginModel):void {
            _model = model;
        }

        public function onLoad(player:Flowplayer):void {
            _player = player;
            _model.dispatchOnLoad();
        }

        private function createDock(player:Flowplayer):void {
            _dock = Dock.getInstance(player);

            var addIcon:Function = function(icon:DisplayObject, clickCallback:Function):void {
                _dock.addIcon(icon);
                icon.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                    clickCallback();
                });
            };

            addIcon(new EmailIcon(_config.buttons, player.animationEngine), function():void { _config.email.execute(); });
            addIcon(new EmbedIcon(_config.buttons, player.animationEngine), function():void { _config.getEmbedCode().execute(); });
            if (_config.twitter) {
                addIcon(new TwitterIcon(_config.buttons, player.animationEngine, null), function():void { _config.twitter.execute(); });
            }
            if (_config.facebook) {
                addIcon(new FacebookIcon(_config.buttons, player.animationEngine, null), function():void { _config.facebook.execute(); });
            }

            _dock.addToPanel();
        }

        public function getDefaultConfig():Object {
            return null;
        }

        [External]
        public function get config():Config {
            return _config;
        }
    }

}