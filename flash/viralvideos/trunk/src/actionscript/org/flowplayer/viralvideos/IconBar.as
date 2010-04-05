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
package org.flowplayer.viralvideos {
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;

    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.viralvideos.config.Config;
    import org.flowplayer.viralvideos.icons.EmailIcon;
    import org.flowplayer.viralvideos.icons.EmbedIcon;
    import org.flowplayer.viralvideos.icons.ShareIcon;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.Flowplayer;

    public class IconBar extends AbstractSprite {
        private var _player:Flowplayer;
        private var _config:Config;
        private var _shareIcon:ShareIcon;
        private var _embedIcon:EmbedIcon;
        private var _emailIcon:EmailIcon;

        public function IconBar(config:Config, player:Flowplayer) {
            _config = config;
            _player = player;
            createIcons();
        }

        private function resizeIcon(dim:Number):void {
            _embedIcon.height = _embedIcon.width = dim;
            _emailIcon.height = _emailIcon.width = dim;
            _shareIcon.height = _shareIcon.width = dim;
        }

        override protected function onResize():void {
            log.debug("onResize() " + width + " x " + height);
            var horizontal:Boolean = width > height;

            if (horizontal) {
                resizeIcon(height);
                _embedIcon.x = _emailIcon.x + _emailIcon.width + 5;
                _shareIcon.x = _embedIcon.x + _embedIcon.width + 5;
            } else {
                resizeIcon(width);
                _embedIcon.y = _emailIcon.y + _emailIcon.height + 5;
                _shareIcon.y = _embedIcon.y + _embedIcon.height + 5;                
            }
        }

        private function createIcons():void {
            if (_config.email) {
                _emailIcon = new EmailIcon(_config.iconButtons, _player.animationEngine);
                addChild(_emailIcon);
            }

            if (_config.embed) {
                _embedIcon = new EmbedIcon(_config.iconButtons, _player.animationEngine);
                addChild(_embedIcon);
                _embedIcon.y = _emailIcon.y + _emailIcon.height + 5;
            }

            if (_config.share) {
                _shareIcon = new ShareIcon(_config.iconButtons, _player.animationEngine);
                addChild(_shareIcon);
                _shareIcon.y = _embedIcon.y + _embedIcon.height + 5;
            }

            var props:DisplayProperties = _config.iconDisplayProperties;
            props.setDisplayObject(this);
            log.debug("icon bar props " + props.dimensions);
            _player.addToPanel(this, props);
        }

        private function addIconClickListener(icon:DisplayObject, listener:Function):void {
            icon.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                listener();
            });
        }

        public function onEmail(listener:Function):void {
            addIconClickListener(_emailIcon, listener);
        }

        public function onEmbed(listener:Function):void {
            addIconClickListener(_embedIcon, listener);
        }

        public function onShare(listener:Function):void {
            addIconClickListener(_shareIcon, listener);
        }
    }
}