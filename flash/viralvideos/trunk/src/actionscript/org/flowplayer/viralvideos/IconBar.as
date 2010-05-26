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
			if ( _embedIcon )
            	_embedIcon.height = _embedIcon.width = dim;
			if ( _emailIcon )
            	_emailIcon.height = _emailIcon.width = dim;
            if ( _shareIcon )
				_shareIcon.height = _shareIcon.width = dim;
        }

        override protected function onResize():void {
            log.debug("onResize() " + width + " x " + height);
           
            resizeIcon(width);
			var nextY:int = 0;
			
			if ( _emailIcon ) {
				_emailIcon.x = 0;
				_emailIcon.y = 0;
				
				nextY = nextY + _emailIcon.height + 5;
			}
			
			if ( _embedIcon ) {
				_embedIcon.y = nextY;
				_embedIcon.x = 0;
				
				nextY = nextY + _embedIcon.height + 5;
			}
			
			if ( _shareIcon ) {
				_shareIcon.y = nextY;
				_shareIcon.x = 0;
				
				nextY = nextY + _shareIcon.height + 5;
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
            }

            if (_config.share) {
                _shareIcon = new ShareIcon(_config.iconButtons, _player.animationEngine);
                addChild(_shareIcon);
            }

			

            var props:DisplayProperties = _config.iconDisplayProperties;
            props.setDisplayObject(this);
			
			onResize();

            log.debug("icon bar props " + props.dimensions);
            _player.addToPanel(this, props);
        }

        private function addIconClickListener(icon:DisplayObject, listener:Function):void {
            icon.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                listener();
            });
        }

        public function onEmail(listener:Function):void {
			if ( _emailIcon )
            	addIconClickListener(_emailIcon, listener);
        }

        public function onEmbed(listener:Function):void {
			if ( _embedIcon )
            	addIconClickListener(_embedIcon, listener);
        }

        public function onShare(listener:Function):void {
			if ( _shareIcon )
            	addIconClickListener(_shareIcon, listener);
        }
    }
}