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

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.DisplayPluginModelImpl;
    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.model.DisplayPropertiesImpl;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.ui.Dock;
    import org.flowplayer.ui.DockConfig;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.viralvideos.icons.EmailIcon;
    import org.flowplayer.viralvideos.icons.EmbedIcon;

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
            log.debug("createDock()");
            var config:DockConfig = new DockConfig();
            config.horizontal = true;
            var model:DisplayPluginModel = new DisplayPluginModelImpl(null, Dock.DOCK_PLUGIN_NAME, false);

            model.height = new int(50/stage.height * 100) + "%";
            model.left =  15;
            model.top =  15;

            config.model = model;

            _dock = Dock.getInstance(player, config);

            var addIcon:Function = function(enabled:Boolean, iconClass:Class, clickCallback:Function):void {
                if (! enabled) return;
                var icon:DisplayObject = new iconClass(_config.buttons, player.animationEngine);
                _dock.addIcon(icon);
                icon.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                    clickCallback();
                });
            };

            addIcon(_config.email, EmailIcon, function():void { return; _config.email.execute(); });
            addIcon(_config.embed, EmbedIcon, function():void { _config.getEmbedCode().execute(); });
            addIcon(_config.twitter, TwitterIcon, function():void { _config.twitter.execute(); });
            addIcon(_config.facebook, FacebookIcon, function():void { _config.facebook.execute(); });

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