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
package org.flowplayer.slowmotion {
    import flash.net.NetStream;
    import flash.utils.Dictionary;

    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginError;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.Log;
    import org.flowplayer.view.Flowplayer;

    public class SlowMotion implements Plugin {
        private var log:Log = new Log(this);
        private var _provider:StreamProvider;
        private var _model:PluginModel;
        private var _player:Flowplayer;
        private var _timeProvider:SlowMotionTimeProvider;

        public function onConfig(model:PluginModel):void {
            _model = model;
        }

        public function onLoad(player:Flowplayer):void {
            _player = player;

            try {
                _provider = lookupProvider(player.pluginRegistry.providers);
            } catch (e:Error) {
                _model.dispatchError(PluginError.INIT_FAILED, "Failed to lookup a RTMP plugin: " + e.message);
                return;
            }
            log.debug("Found RTMP provider " + _provider);

            _timeProvider = new SlowMotionTimeProvider(_model, _provider, _player.playlist);
            _provider.timeProvider = _timeProvider;
            _player.playlist.onResume(function(event:ClipEvent):void { normal(); });

            _model.dispatchOnLoad();
        }

        [External]
        public function forward(multiplier:Number = 4, fps:Number = 10):void {
            log.debug("forward()");
            if (multiplier == 1) {
                normal();
                return;
            }
            _provider.netConnection.call("setFastPlay", null, multiplier, fps, 1);
            _provider.netStream.seek(_timeProvider.getTime(netStream));
        }

        [External]
        public function backward(multiplier:Number = 4, fps:Number = 10):void {
            log.debug("backward()");
            _provider.netConnection.call("setFastPlay", null, multiplier, fps, -1);
            _provider.netStream.seek(_timeProvider.getTime(netStream));
        }

        [External]
        public function normal():void {
            log.debug("normal()");
            _provider.netStream.seek(_timeProvider.getTime(netStream));
        }

        [External]
        public function get info():SlowMotionInfo {
            return _timeProvider.info();
        }

        /*
         [External]
         public function
         */

        private function lookupProvider(providers:Dictionary):StreamProvider {
            log.debug("lookupProvider() " + providers);
            if (_model.config && _model.config["provider"]) {
                var model:PluginModel = _player.pluginRegistry.getPlugin(_model.config["provider"]) as PluginModel;
                if (! model) throw new Error("Failed to find plugin '" + _model.config["provider"] + "'");
                if (! (model.pluginObject is StreamProvider)) throw new Error("The specified provider is not a StreamProvider");
                return model.pluginObject as StreamProvider;
            }
            for each (model in providers) {
                log.debug(model.name);
                if (["http", "httpInstream"].indexOf(model.name) < 0 && model.pluginObject is StreamProvider) {
                    return model.pluginObject as StreamProvider;
                }
            }
            return null;
        }

        public function getDefaultConfig():Object {
            return null;
        }

        private function get netStream():NetStream {
            return _provider.netStream;
        }
    }
}