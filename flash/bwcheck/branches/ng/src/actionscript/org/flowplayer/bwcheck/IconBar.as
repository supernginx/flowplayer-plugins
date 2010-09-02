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
        private var _hdOn:Boolean;

        public function IconBar(config:Config, player:Flowplayer, hdOn:Boolean = false) {
            _config = config;
            _player = player;
            _hdOn = hdOn;
            createIcons();
        }

        private function resizeIcon(dim:Number):void {
            if (_hdIcon)
                _hdIcon.height = _hdIcon.width = dim;
        }

        override protected function onResize():void {
            log.debug("onResize() " + width + " x " + height);

            resizeIcon(width);
            var nextY:int = 0;

            if (_hdIcon) {
                _hdIcon.x = 0;
                _hdIcon.y = 0;

                nextY = nextY + _hdIcon.height + 5;
            }
        }

        private function createIcons():void {
            _hdIcon = new HDIcon(_config.iconButtons, _player.animationEngine);
            _hdIcon.toggle = _hdOn;
            addChild(_hdIcon);

            var props:DisplayProperties = _config.iconDisplayProperties;
            props.setDisplayObject(this);

            onResize();

            log.debug("icon bar props " + props.dimensions);
            _player.addToPanel(this, props);
        }

        private function addIconClickListener(icon:DisplayObject, listener:Function, ...args):void {
            icon.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                listener(args);
            });
        }

        public function onHd(listener:Function):void {
            log.error("FUCK" + _hdIcon.toggle.toString());
            if (_hdIcon)
                addIconClickListener(_hdIcon, listener, _hdIcon.toggle);
        }

    }
}