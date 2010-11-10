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
    import flash.display.Stage;

    import org.flowplayer.ui.ButtonConfig;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.Flowplayer;

    public class Config {
        private var _buttons:ButtonConfig;
        private var _email:Email;
        private var _embed:Embed;

        public function Config(player:Flowplayer, pluginConfiguredName:String, stage:Stage) {
            _buttons = new ButtonConfig();
            _buttons.setColor("rgba(20,20,20,0.5)");
            _buttons.setOverColor("rgba(0,0,0,1)");

            _email = new Email(player);
            _embed = new Embed(player, pluginConfiguredName, stage);
        }

        public function get buttons():ButtonConfig {
            return _buttons;
        }

        public function setButtons(config:Object):void {
            new PropertyBinder(_buttons).copyProperties(config);
        }

        public function setEmail(config:Object):void {
            new PropertyBinder(_email).copyProperties(config);
        }

        public function get email():Email {
            return _email;
        }

        public function setEmbed(config:Object):void {
            new PropertyBinder(_embed.config).copyProperties(config);            
        }

        public function get embed():Embed {
            return _embed;
        }
    }
}