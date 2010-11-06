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
package org.flowplayer.playlist {
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;

    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.playlist.icons.PlaylistIcon;
    import org.flowplayer.playlist.config.Config;
  
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.Flowplayer;

    public class IconBar extends AbstractSprite {
        private var _player:Flowplayer;
        private var _config:Config;
        private var _playlistIcon:PlaylistIcon;

        public function IconBar(config:Config, player:Flowplayer) {
            _config = config;
            _player = player;
            createIcons();
        }

        private function resizeIcon(dim:Number):void {
            _playlistIcon.height = _playlistIcon.width = dim;
        }

        override protected function onResize():void {
            log.debug("onResize() " + width + " x " + height);
            resizeIcon(width);
			//var nextY:int = 0;
			_playlistIcon.x = 0;
			_playlistIcon.y = 0;	
				//nextY = nextY + _playlistIcon.height + 5; 
        }

        private function createIcons():void {
            _playlistIcon = new PlaylistIcon(_config.iconButtons, _player.animationEngine);
            addChild(_playlistIcon);

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

        public function onPlaylist(listener:Function):void {
            addIconClickListener(_playlistIcon, listener);
        }
    }
}