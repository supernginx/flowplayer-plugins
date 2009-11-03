/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, Flowplayer Oy
 * Copyright (c) 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.securestreaming {
    import com.adobe.crypto.MD5;
import flash.events.NetStatusEvent;
    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.controller.ConnectionProvider;
import org.flowplayer.controller.ResourceLoader;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.controller.StreamProvider;
import org.flowplayer.model.Clip;
    import org.flowplayer.model.Clip;
import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginError;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;

    public class SecureStreaming implements ClipURLResolver, ConnectionProvider, Plugin {
        private var _httpResolver:SecureHttpUrlResolver;
        private var _connectionProvider:SecureRTMPConnectionProvider;
        private var _model:PluginModel;
        private var _config:Config;
        private var _player:Flowplayer;
        private var _failureListener:Function;
        private var _connectionClient:Object;

        /*
         * URL resolving is used for HTTP
         */
        public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {
            _httpResolver.resolve(provider, clip, successListener);
        }

        /*
         * Connection establishment is used for Wowza
         */
        public function connect(provider:StreamProvider, clip:Clip, successListener:Function, objectEncoding: uint, connectionArgs:Array):void {
            _connectionProvider.connect(provider, clip, successListener, objectEncoding, connectionArgs);
        }

        public function set onFailure(listener:Function):void {
            _failureListener = listener;
            if (_httpResolver) {
                _httpResolver.onFailure = listener;
            }
            if (_connectionProvider) {
                _connectionProvider.onFailure = listener;
            }
        }

        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
            return true;
        }

        public function onConfig(model:PluginModel):void {
            _model = model;
            _config = new PropertyBinder(new Config()).copyProperties(model.config) as Config;
        }

        public function onLoad(player:Flowplayer):void {
            _player = player;
            _httpResolver = new SecureHttpUrlResolver(this, player, _config, _failureListener);
            _connectionProvider = new SecureRTMPConnectionProvider(_config.token);
            _connectionProvider.connectionClient = _connectionClient;
            _model.dispatchOnLoad();
        }


        public function getDefaultConfig():Object {
            return null;
        }

        public static function isRtmpUrl(url:String):Boolean {
            return url && url.toLowerCase().indexOf("rtmp") == 0;
        }

        public function set connectionClient(client:Object):void {
            _connectionClient = client;
            if (_connectionProvider) {
                _connectionProvider.connectionClient = client;
            }
        }

    }
}