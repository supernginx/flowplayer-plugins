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
            _config = new PropertyBinder(new Config()).copyProperties(model.config) as Config;
        }

        public function onLoad(player:Flowplayer):void {
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

            addIcon(new EmailIcon(_config.buttons, player.animationEngine), function():void { onEmail(); });
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

        private function onEmail():void {
            log.debug("onEmail()");
//            var request:URLRequest = new URLRequest(formatString("mailto:{0}?subject={1}&body={2}", _emailToInput.text, escape(_config.email.texts.subject), escape(formatString(_config.email.texts.template, _messageInput.text, _videoURL, _videoURL))));
            var request:URLRequest = new URLRequest(formatString("mailto:{0}?subject={1}&body={2}", "", "Video you might be interested in", "Here is a video you might be interested in"));
            navigateToURL(request, "_self");
        }

        public function getDefaultConfig():Object {
            return null;
        }

        private function formatString(original:String, ...args):String {
            var replaceRegex:RegExp = /\{([0-9]+)\}/g;
            return original.replace(replaceRegex, function():String {
                if (args == null)
                {
                    return arguments[0];
                }
                else
                {
                    var resultIndex:uint = uint(between(arguments[0], '{', '}'));
                    return (resultIndex < args.length) ? args[resultIndex] : arguments[0];
                }
            });
        }

        private function between(p_string:String, p_start:String, p_end:String):String {
            var str:String = '';
            if (p_string == null) { return str; }
            var startIdx:int = p_string.indexOf(p_start);
            if (startIdx != -1) {
                startIdx += p_start.length; // RM: should we support multiple chars? (or ++startIdx);
                var endIdx:int = p_string.indexOf(p_end, startIdx);
                if (endIdx != -1) { str = p_string.substr(startIdx, endIdx-startIdx); }
            }
            return str;
        }
    }
}