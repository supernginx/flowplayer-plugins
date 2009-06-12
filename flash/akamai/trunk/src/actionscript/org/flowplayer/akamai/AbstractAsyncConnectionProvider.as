/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, Flowplayer Oy
 * Copyright (c) 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.akamai {
    import flash.events.NetStatusEvent;
    import flash.events.NetStatusEvent;
    import flash.net.NetConnection;

    import org.flowplayer.controller.ConnectionProvider;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.Log;
    import org.flowplayer.view.Flowplayer;

    public class AbstractAsyncConnectionProvider implements ConnectionProvider {

        protected var log:Log = new Log(this);
        private var _connection:NetConnection;
        private var _connectionClient:Object;
        private var _provider:StreamProvider;
        private var _successListener:Function;
        private var _failureListener:Function;
        private var _clip:Clip;

        public function AbstractAsyncConnectionProvider() {
            log.debug("instantiating");
        }

        public function connect(provider:StreamProvider, clip:Clip, successListener:Function, objectEncoding: uint, ... rest):void {
            _clip = clip;
            _provider = provider;
            _successListener = successListener;
            log.debug("connect()");
            createConnection(clip, successListener, objectEncoding);
            doConnect();
        }

        protected function doConnect():void {
            throw new Error("doConnect should be overridden in subclasses!");
//            _connection.connect(clip.getCustomProperty("netConnectionUrl") as String);
        }

        public function set connectionClient(client:Object):void {
            _connectionClient = client;
        }

        public function set onFailure(listener:Function):void {
            _failureListener = listener;
        }

        private function createConnection(clip:Clip, successListener:Function, objectEndocing:uint):void {
            _connection = new NetConnection();
            _connection.proxyType = "best";
            _connection.objectEncoding = objectEndocing;

            if (_connectionClient) {
                _connection.client = _connectionClient;
            }
            _connection.addEventListener(NetStatusEvent.NET_STATUS, _onConnectionStatus);
        }

        private function _onConnectionStatus(event:NetStatusEvent):void {
            log.debug("onConnectionStatus " + event.info.code);
            if (event.info.code == "NetConnection.Connect.Success" && _successListener != null) {
                _successListener(_connection);
            } else if (["NetConnection.Connect.Failed", "NetConnection.Connect.Rejected", "NetConnection.Connect.AppShutdown", "NetConnection.Connect.InvalidApp"].indexOf(event.info.code) >= 0) {

                if (_failureListener != null) {
                    _failureListener();
                }
            }
        }

        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
            return true;
        }

        protected function get connection():NetConnection {
            return _connection;
        }

        protected function get connectionClient():Object {
            return _connectionClient;
        }

        protected function get provider():StreamProvider {
            return _provider;
        }

        protected function get successListener():Function {
            return _successListener;
        }

        protected function get failureListener():Function {
            return _failureListener;
        }

        protected function get clip():Clip {
            return _clip;
        }
    }
}