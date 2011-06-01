/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <api@iki.fi>
 *
 * Copyright (c) 2008-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.cluster {
    import flash.events.NetStatusEvent;
    import flash.net.NetConnection;
    import flash.net.NetStream;

    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.controller.NetStreamClient;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.PluginEventType;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;

    internal class ClusterUrlResolver implements ClipURLResolver {
        private var log:Log = new Log(this);
        private var _clip:Clip;
        private var _successListener:Function;
        private var _provider:StreamProvider;
        private var _connection:NetConnection;
        private var _cluster:Cluster;
        private var _failureListener:Function;
        private var _netStream:NetStream;
        private var _player:Flowplayer;
        private var _isComplete:Boolean;
        private var _model:PluginModel;

        public function ClusterUrlResolver(player:Flowplayer, cluster:Cluster, model:PluginModel) {
            _player = player;
            _cluster = cluster;
            _model = model;
        }

        public function set onFailure(listener:Function):void {
            _failureListener = listener;
        }


        public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {
            log.debug("resolve()");
            _clip = clip;
            _successListener = successListener;
            _provider = provider;
            if (_provider.netStream) {
                _provider.netStream.close();
            }

            _connection = new NetConnection();
            _connection.addEventListener(NetStatusEvent.NET_STATUS, _onConnectionStatus);
            _connection.connect(getNextNetConnectionUrl(_clip));
        }

        protected function getNextNetConnectionUrl(clip:Clip):String {
            var host:String = _cluster.nextHost;
            if (isRtmpUrl(host)) return host;
            return null;
        }

        public static function isRtmpUrl(url:String):Boolean {
            if (! url) return false;
            return url.toLowerCase().indexOf("rtmp") == 0;
        }

        private function _onConnectionStatus(event:NetStatusEvent):void {
            log.debug("onConnectionStatus: " + event.info.code);
            if (event.info.code == "NetConnection.Connect.Success") {
                doResolve(false);
            } else if (["NetConnection.Connect.Failed", "NetConnection.Connect.Rejected", "NetConnection.Connect.AppShutdown", "NetConnection.Connect.InvalidApp"].indexOf(event.info.code) >= 0) {
                _failureListener("Failed to connect " + event.info.code);
            }

        }

        private function doResolve(useNextHost:Boolean):void {
            _netStream = new NetStream(_connection);
            _netStream.client = new NetStreamClient(_clip, _player.config, _provider.streamCallbacks);
            _netStream.addEventListener(NetStatusEvent.NET_STATUS, _onNetStatus);
            _cluster.onReconnected(onHTTPReconnect);
            _cluster.start();

            resolveURL(useNextHost);
        }

        protected function resolveURL(useNextHost:Boolean):void
        {
            log.debug("resolveURL, useNextHost " + useNextHost);
            // store the resolvedUrl already now, to make sure the resolved URL is there when onStart()
            // is dispatched by the provider
            var currentUrl:String = _clip.getPreviousResolvedUrl(this);
            var nextHost:String = useNextHost ? _cluster.nextHost : _cluster.currentHost;
            var url:String = URLUtil.completeURL(nextHost, URLUtil.baseUrlAndRest(currentUrl)[1]);
            log.debug("current URL is " + currentUrl + " next host " + nextHost + ", url " + url);
            _clip.setResolvedUrl(this, url);

            _model.dispatch(PluginEventType.PLUGIN_EVENT, "onConnect", _cluster.currentHost, _cluster.currentHostIndex);
            _netStream.play(_clip.getResolvedUrl(this));
            _cluster.start();
        }

        private function _onNetStatus(event:NetStatusEvent):void {
            if (event.info.code == "NetStream.Play.Start") {
                log.debug("_onNetStatus: NetStream.Play.Start, calling clusterComplete()");
                clusterComplete();
            }  else if (event.info.code == "NetStream.Play.StreamNotFound" ||
                        event.info.code == "NetConnection.Connect.Rejected" ||
                        event.info.code == "NetConnection.Connect.Failed") {
                onHTTPReconnect();
            }
        }

        protected function onHTTPReconnect():void
        {
            _model.dispatch(PluginEventType.PLUGIN_EVENT, "onConnectFailed", _cluster.currentHost, _cluster.currentHostIndex);
            _cluster.setFailedServer(_clip.getResolvedUrl(this));
            _cluster.stop();
            resolveURL(true);
            log.info("HTTP Connection Attempting Reconnection");
        }

        protected function clusterComplete():void
        {
            _isComplete = true;
            if (_netStream) {
                _netStream.close();
            }
            _cluster.stop();
            var currentUrl:String = _clip.getPreviousResolvedUrl(this);
            _clip.setResolvedUrl(this, URLUtil.completeURL(_cluster.currentHost, URLUtil.baseUrlAndRest(currentUrl)[1]));
            _successListener(_clip);
        }

        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
            return false;
        }
    }
}
