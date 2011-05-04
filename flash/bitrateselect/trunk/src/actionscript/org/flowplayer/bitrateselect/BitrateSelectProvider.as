package org.flowplayer.bitrateselect {

    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.model.PlayerEvent;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.util.Arrange;

    import org.flowplayer.ui.containers.*;
    import org.flowplayer.ui.Dock;
    import org.flowplayer.ui.Notification;
    import org.flowplayer.ui.buttons.ToggleButton;
    import org.flowplayer.ui.buttons.ToggleButtonConfig;

    import fp.HDSymbol;

    import org.flowplayer.bitrateselect.ui.HDToggleController;
    import org.flowplayer.bitrateselect.event.HDEvent;
    import org.flowplayer.bitrateselect.config.Config;


    public class BitrateSelectProvider extends AbstractSprite implements Plugin {
        private var _config:Config;
        private var _model:PluginModel;
        private var _hdButton:ToggleButton;
        private var _hasHdButton:Boolean;
        private var _hdEnabled:Boolean = false;
        private var _player:Flowplayer;
        private var _iconDock:Dock;
        
        public function onConfig(model:PluginModel):void {
            _model = model;
            _config = new PropertyBinder(new Config(), null).copyProperties(model.config) as Config;
        }

        private function applyForClip(clip:Clip):Boolean {
            log.debug("applyForClip(), clip.urlResolvers == " + clip.urlResolvers);
            if (clip.urlResolvers == null) return false;
            var apply:Boolean = clip.urlResolvers.indexOf(_model.name) >= 0;
            log.debug("applyForClip? " + apply);
            return apply;
        }
    
        public function onLoad(player:Flowplayer):void {
            log.info("onLoad()");

            _player = player;

            _player.playlist.onStart(function(event:ClipEvent):void {
                log.debug("onBegin()");
                log.debug("hd available? " + hasHD);
                dispatchEvent(new HDEvent(HDEvent.HD_AVAILABILITY, hasHD));
            });

            if (_config.hdButton.docked) {
                _hasHdButton = true;
                createIconDock();	// we need to create the controller pretty early else it won't receive the HD_AVAILABILITY event
                _player.onLoad(onPlayerLoad);
            }

            if (_config.hdButton.controls) {
                _hasHdButton = true;
                var controlbar:* = player.pluginRegistry.plugins['controls'];
                controlbar.pluginObject.addEventListener(WidgetContainerEvent.CONTAINER_READY, addHDButton);
            }

            _model.dispatchOnLoad();
        }

        private function onPlayerLoad(event:PlayerEvent):void {
            log.debug("onPlayerLoad() ");
            _iconDock.addToPanel();
        }

        private function addHDButton(event:WidgetContainerEvent):void {
            var container:WidgetContainer = event.container;
            var controller:HDToggleController = new HDToggleController(false, this);
            container.addWidget(controller, "volume", false);
        }

        private function createIconDock():void {
            if (_iconDock) return;
            _iconDock = Dock.getInstance(_player);
            var controller:HDToggleController = new HDToggleController(true, this);

            // dock should do that, v3.2.7 maybe :)
            _hdButton = controller.init(_player, _iconDock, new ToggleButtonConfig(_config.iconConfig, _config.iconConfig)) as ToggleButton;
            _iconDock.addIcon(_hdButton);
            _iconDock.addToPanel();
        }

        public function get hasHD():Boolean {
            return true;
           // return (_player.playlist.current.getCustomProperty("hdBitrateItem") && _player.playlist.current.getCustomProperty("sdBitrateItem"));
        }

        public function set hd(enable:Boolean):void {
            //if (! hasHD) return;
            log.info("set HD, switching to " + (enable ? "HD" : "normal"));

            //var newItem:BitrateItem = _player.playlist.current.getCustomProperty(enable ? "hdBitrateItem" : "sdBitrateItem") as BitrateItem;
            //switchStream(newItem);

            setHDNotification(enable);
        }

        private function setHDNotification(enable:Boolean):void {
            _hdEnabled = enable;
            if (_config.hdButton.splash) {
                displayHDNotification(enable);
            }
            dispatchEvent(new HDEvent(HDEvent.HD_SWITCHED, _hdEnabled));
        }

        private function displayHDNotification(enable:Boolean):void {
            var symbol:HDSymbol = new HDSymbol();
            symbol.hdText.text = enable ? _config.hdButton.onLabel : _config.hdButton.offLabel;
            symbol.hdText.width = symbol.hdText.textWidth + 26;
            Arrange.center(symbol.hdText, symbol.width);
            Arrange.center(symbol.hdSymbol, symbol.width);
            var notification:Notification = Notification.createDisplayObjectNotification(_player, symbol);
            notification.show(_config.hdButton.splash).autoHide(1200);
        }

/*
        private function toggleDefaultToHD(mappedBitrate:BitrateItem):void {
            if (mappedBitrate.isDefault) toggleToHD(mappedBitrate);
        }

        private function toggleToHD(mappedBitrate:BitrateItem):void {
            if (mappedBitrate.hd) setHDNotification(true);
        }
  */

        public function get hd():Boolean {
            return _hdEnabled;
        }

        public function getDefaultConfig():Object {
            return {
                top: "45%",
                left: "50%",
                opacity: 1,
                borderRadius: 15,
                border: 'none',
                width: "80%",
                height: "80%"
            };
        }

        public function css(styleProps:Object = null):Object {
            return {};
        }

        public function animate(styleProps:Object):Object {
            return {};
        }

        public function onBeforeCss(styleProps:Object = null):void {
            _iconDock.cancelAnimation();
        }

        public function onBeforeAnimate(styleProps:Object):void {
            _iconDock.cancelAnimation();
        }
        
    }
}
