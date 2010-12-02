/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.bwcheck.detect {
    import flash.events.EventDispatcher;
    import flash.events.NetStatusEvent;
    import flash.net.NetConnection;

    import org.flowplayer.bwcheck.Config;
    import org.flowplayer.bwcheck.NullNetConnectionClient;
    import org.flowplayer.cluster.RTMPCluster;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.Playlist;
    import org.flowplayer.model.PluginEventType;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.Log;
    import org.flowplayer.view.Flowplayer;

    /**
     * @author danielr
     */
    public class BandwidthDetector extends EventDispatcher {
        private var log:Log = new Log(this);

        // --------- These references are needed here, so that the classes get compiled in!
        private var wowzaImpl:BandwidthDetectorWowza;
        private var httpImpl:BandwidthDetectorHttp;
        private var fmsImpl:BandwidthDetectorFms;
        private var red5Impl:BandwidthDetectorRed5;
        // ---------

        private var _strategy:AbstractDetectionStrategy;
        private var _connection:NetConnection;
        protected var _rtmpCluster:RTMPCluster;
        private var _config:Config;
        private var _model:PluginModel;
        private var _host:String;
        private var _playlist:Playlist;

        public function BandwidthDetector(model:PluginModel, config:Config, playlist:Playlist) {
            _model = model;
            _config = config;
            _playlist = playlist;

            var bandwidthDetectionCls:Class = FactoryMethodUtil.getFactoryMethod("org.flowplayer.bwcheck.detect.BandwidthDetector", _config.serverType);
            _strategy = new bandwidthDetectionCls();

            if (_strategy == null) _strategy = new BandwidthDetectorHttp();

            if (_config.hosts || config.netConnectionUrl) {
                _rtmpCluster = new RTMPCluster(_config);
                _rtmpCluster.onFailed(onClusterFailed);
            }
        }

        override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
            if (type == BandwidthDetectEvent.CLUSTER_FAILED) {
                super.addEventListener(type, listener, useCapture, priority, useWeakReference);
            } else {
                _strategy.addEventListener(type, listener);
            }
        }

        public function detect(host:String = null):void {
            _host = _rtmpCluster ? _rtmpCluster.nextHost : _playlist.current.getCustomProperty("netConnectionUrl") as String;
            if (! _host) {
                log.error("no live hosts to connect to");
                dispatchClusterFailed();
                return;
            }
            if (_rtmpCluster) {
                _rtmpCluster.onReconnected(onRTMPReconnect);
                _rtmpCluster.start();
            }

            _connection = new NetConnection();
            _connection.addEventListener(NetStatusEvent.NET_STATUS, onConnectionStatus);
            _connection.client = new NullNetConnectionClient();
            _strategy.connection = _connection;

            log.debug("detect(), connecting to " + _host + ", using strategy " + _strategy);
            _strategy.connect(_host);
        }

        private function onConnectionStatus(event:NetStatusEvent):void {
            switch (event.info.code) {
                case "NetConnection.Connect.Success":
                    log.info("successfully connected to " + _connection.uri);
                    if (_rtmpCluster) {
                        _rtmpCluster.stop();
                        _strategy.detect();
                    }
                    break;

                case "NetConnection.Connect.Failed":
                    log.info("Couldn't connect to " + _connection.uri);
                    if (_rtmpCluster) {
                        _rtmpCluster.setFailedServer(_connection.uri);
                        _rtmpCluster.stop();
                    }

                    detect();
                    break;
                //connection has closed
                case "NetConnection.Connect.Closed":
            }
        }

        private function onClusterFailed(event:ClipEvent = null):void {
            log.info("Connections failed");
            _model.dispatch(PluginEventType.PLUGIN_EVENT, event, currentHost, currentHostIndex);
        }

        private function get currentHostIndex():int {
            return _rtmpCluster ? _rtmpCluster.currentHostIndex : 0;
        }

        private function get currentHost():String {
            return _rtmpCluster ? _rtmpCluster.currentHost : _playlist.current.getCustomProperty("netConnectionUrl") as String;
        }

        private function onRTMPReconnect():void {
            dispatch("onRTMPReconnect()");
            if (_rtmpCluster) {
                _rtmpCluster.setFailedServer(_host);
            }
            _connection.close();
            log.info("onRTMPReconnect(), Attempting reconnection");
            detect();
        }

        private function dispatch(event:String):void {
            _model.dispatch(PluginEventType.PLUGIN_EVENT, event, currentHost, currentHostIndex);

        }

        private function dispatchClusterFailed():void {
            var event:BandwidthDetectEvent = new BandwidthDetectEvent(BandwidthDetectEvent.CLUSTER_FAILED);
            dispatchEvent(event);
        }

        public function get host():String {
            if (!_host) {
                return currentHost;
            }
            return _host;
        }
    }
}
