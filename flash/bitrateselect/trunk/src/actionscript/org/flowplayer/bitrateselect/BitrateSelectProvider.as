package org.flowplayer.bitrateselect {

    import flash.events.EventDispatcher;
    import flash.net.NetStream;
    import flash.events.NetStatusEvent;

    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.model.PlayerEvent;
    import org.flowplayer.model.PluginEventType;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.Styleable;
    import org.flowplayer.util.Arrange;

    import org.flowplayer.ui.containers.*;
    import org.flowplayer.ui.Dock;
    import org.flowplayer.ui.Notification;
    import org.flowplayer.ui.buttons.ToggleButton;
    import org.flowplayer.ui.buttons.ToggleButtonConfig;

    import org.flowplayer.net.BitrateItem;
    import org.flowplayer.net.StreamSelectionManager;
    import org.flowplayer.net.StreamSwitchManager;

    import fp.HDSymbol;

    import org.flowplayer.bitrateselect.ui.HDToggleController;
    import org.flowplayer.bitrateselect.event.HDEvent;
    import org.flowplayer.bitrateselect.config.Config;


    public class BitrateSelectProvider extends EventDispatcher implements ClipURLResolver, Plugin  {
        private var log:Log = new Log(this);
        private var _config:Config;
        private var _model:PluginModel;
        private var _hdButton:ToggleButton;
        private var _hdEnabled:Boolean = false;
        private var _player:Flowplayer;
        private var _iconDock:Dock;
        private var _provider:StreamProvider;
        private var _resolveSuccessListener:Function;
        private var _netStream:NetStream;
        private var _clip:Clip;
        private var _start:Number = 0;
        private var _failureListener:Function;
        private var _streamSelectionManager:StreamSelectionManager;
        private var _streamSwitchManager:StreamSwitchManager;
        
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

            _player.playlist.onSwitch(function(event:ClipEvent):void {
                log.debug("new item is " + _streamSelectionManager.currentBitrateItem + ", current " + _streamSwitchManager.previousBitrateItem);
                _model.dispatch(PluginEventType.PLUGIN_EVENT, "onStreamSwitchBegin", _streamSelectionManager.currentBitrateItem, _streamSwitchManager.previousBitrateItem);
            });

            _player.playlist.onSwitchFailed(function(event:ClipEvent):void {
                log.debug("Transition failed with error " + event.info2.toString());
                _model.dispatch(PluginEventType.PLUGIN_EVENT, "onStreamSwitchFailed", "Transition failed with error " + event.info2.toString());
            });

            _player.playlist.onSwitchComplete(function(event:ClipEvent):void {
                _model.dispatch(PluginEventType.PLUGIN_EVENT, "onStreamSwitch", _streamSelectionManager.currentBitrateItem);
            });

            _player.playlist.onStart(function(event:ClipEvent):void {

                log.debug("onStart()");
                log.debug("hd available? " + hasHD);



                var clip:Clip = event.target as Clip;
                init(clip.getNetStream(), clip);
                initSwitchManager();

                dispatchEvent(new HDEvent(HDEvent.HD_AVAILABILITY, hasHD));
                toggleSplashDefault(_streamSelectionManager.currentBitrateItem);

            });

            _player.playlist.onBeforeBegin(function(event:ClipEvent):void {
                var clip:Clip = event.target as Clip;

                if (clip.getCustomProperty("streamSelectionManager")) {
                    _streamSelectionManager = _clip.getCustomProperty("streamSelectionManager") as StreamSelectionManager;
                }
            });

            if (_config.hdButton.docked) {
                createIconDock();	// we need to create the controller pretty early else it won't receive the HD_AVAILABILITY event
                _player.onLoad(onPlayerLoad);
            }

            if (_config.hdButton.controls) {
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
            return (HDBitrateResource(_streamSelectionManager.bitrateResource).hasHD);
        }

        public function set hd(enable:Boolean):void {
            if (! hasHD) return;
            log.info("set HD, switching to " + (enable ? "HD" : "normal"));

            var newItem:BitrateItem = _player.playlist.current.getCustomProperty(enable ? "hdBitrateItem" : "sdBitrateItem") as BitrateItem;
            _streamSwitchManager.switchStream(newItem);


            setHDNotification(enable);
        }

        private function setHDNotification(enable:Boolean):void {
            _hdEnabled = enable;
            dispatchEvent(new HDEvent(HDEvent.HD_SWITCHED, _hdEnabled));
            if (_config.hdButton.splash) {
                displayHDNotification(enable);
            }

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

        private function alreadyResolved(clip:Clip):Boolean {
            return clip.getCustomProperty("bwcheckResolvedUrl") != null;
        }

        public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {

            if (!clip.getCustomProperty("bitrates") && !clip.getCustomProperty("dynamicStreamingItems")) {
                log.debug("Bitrates configuration not enabled for this clip");
                successListener(clip);
                return;
            }

            if (alreadyResolved(clip)) {
                log.debug("resolve(): bandwidth already resolved for clip " + clip + ", will not detect again");
                successListener(clip);
                return;
            }

            _provider = provider;
            _resolveSuccessListener = successListener;

            init(provider.netStream, clip);

            var mappedBitrate:BitrateItem = _streamSelectionManager.getMappedBitrate(-1);
            _streamSelectionManager.changeStreamNames(mappedBitrate);

            _resolveSuccessListener(_clip);
        }

        private function init(netStream:NetStream, clip:Clip):void {
            log.debug("init(), netStream == " + netStream);

            _netStream = netStream;
            _clip = clip;
            _start = netStream ? netStream.time : 0;

            if (!_clip.getCustomProperty("streamSelectionManager")) {
                _streamSelectionManager = new StreamSelectionManager(new HDBitrateResource(), _player, this);
                _clip.setCustomProperty("streamSelectionManager",_streamSelectionManager);
            }


        }

        private function initSwitchManager():void {
            _streamSwitchManager = new StreamSwitchManager(_netStream, _streamSelectionManager, _player);
        }

        private function toggleSplashDefault(mappedBitrate:BitrateItem):void {
            if (mappedBitrate.isDefault) toggleSplash(mappedBitrate);
        }

        private function toggleSplash(mappedBitrate:BitrateItem):void {
            if (hasHD) {
                setHDNotification(mappedBitrate.hd);
            }
        }

        public function get hd():Boolean {
            return _hdEnabled;
        }

        private function checkCurrentClip():Boolean {
            var clip:Clip = _player.playlist.current;
            if (_clip == clip) return true;

            if (clip.urlResolvers && clip.urlResolvers.indexOf(_model.name) < 0) {
                return false;
            }
            _clip = clip;
            return true;
        }

        [External]
        public function setBitrate(bitrate:Number):void {
            log.debug("set bitrate()");
            if (! checkCurrentClip()) return;

            if (_player.isPlaying() || _player.isPaused() && _streamSwitchManager) {
                _streamSwitchManager.switchStream(_streamSelectionManager.getStream(bitrate) as BitrateItem);
            }
        }

        public function set onFailure(listener:Function):void {
            _failureListener = listener;
        }

        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
            return true;
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
