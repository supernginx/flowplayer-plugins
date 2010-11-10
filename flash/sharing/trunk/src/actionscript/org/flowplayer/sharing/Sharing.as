/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.sharing {
    import flash.display.DisplayObject;

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

        public function onConfig(model:PluginModel):void {
            _model = model;
        }

        public function onLoad(player:Flowplayer):void {
            _config = new PropertyBinder(new Config(player)).copyProperties(_model.config) as Config;
            _player = player;
            createDock(player);
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
            addIcon(new EmbedIcon(_config.buttons, player.animationEngine), function():void { onEmbed(); });
            addIcon(new TwitterIcon(_config.buttons, player.animationEngine), function():void { onTwitter(); });
            addIcon(new FacebookIcon(_config.buttons, player.animationEngine), function():void { onFacebook(); });

            _dock.addToPanel();
        }

        private function onFacebook():void {
        }

        private function onTwitter():void {
        }

        private function onEmbed():void {
            new Notification(_player, "Embed code copied to clipboard! You can now paste it to your site or blog.").show().autoHide();
        }

        public function getDefaultConfig():Object {
            return null;
        }
    }
}