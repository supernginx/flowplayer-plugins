package org.flowplayer.bwcheck {
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;

    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.bwcheck.Config;
    import org.flowplayer.bwcheck.icons.HDIcon;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.Flowplayer;

    public class IconBar extends AbstractSprite {
        private var _player:Flowplayer;
        private var _config:Config;
        private var _hdIcon:HDIcon;

        public function IconBar(config:Config, player:Flowplayer) {
            _config = config;
            _player = player;
            createIcons();
        }

        private function resizeIcon(dim:Number):void {
			if ( _hdIcon )
            	_hdIcon.height = _hdIcon.width = dim;
        }

        override protected function onResize():void {
            log.debug("onResize() " + width + " x " + height);
           
            resizeIcon(width);
			var nextY:int = 0;
			
			if ( _hdIcon ) {
				_hdIcon.x = 0;
				_hdIcon.y = 0;
				
				nextY = nextY + _hdIcon.height + 5;
			}
        }

        private function createIcons():void {
            //if (_config.hd) {
                _hdIcon = new HDIcon(_config.iconButtons, _player.animationEngine);
                addChild(_hdIcon);
            //}

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

        public function onHd(listener:Function):void {
			if ( _hdIcon )
            	addIconClickListener(_hdIcon, listener);
        }

    }
}