/*     *    Copyright 2008 Anssi Piirainen * *    This file is part of FlowPlayer. * *    FlowPlayer is free software: you can redistribute it and/or modify *    it under the terms of the GNU General Public License as published by *    the Free Software Foundation, either version 3 of the License, or *    (at your option) any later version. * *    FlowPlayer is distributed in the hope that it will be useful, *    but WITHOUT ANY WARRANTY; without even the implied warranty of *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the *    GNU General Public License for more details. * *    You should have received a copy of the GNU General Public License *    along with FlowPlayer.  If not, see <http://www.gnu.org/licenses/>. */package org.flowplayer.rtmp {    import flash.events.NetStatusEvent;    import flash.events.NetStatusEvent;    import flash.events.TimerEvent;    import flash.net.NetConnection;    import flash.utils.Timer;    import org.flowplayer.controller.ConnectionProvider;    import org.flowplayer.controller.DefaultRTMPConnectionProvider;    import org.flowplayer.controller.NetStreamControllingStreamProvider;    import org.flowplayer.controller.StreamProvider;    import org.flowplayer.model.Clip;    import org.flowplayer.model.Clip;    import org.flowplayer.util.Log;    /**	 * @author api	 */	public class RTMPConnectionProvider implements ConnectionProvider {        protected var log:Log = new Log(this);//		private var _config:Config;        private var _successListener:Function;        private var _failureListener:Function;        private var _connectionClient:Object;        private var _connector1:Connector;        private var _connector2:Connector;        private var _connection:NetConnection;        private var _config:Config;        public function RTMPConnectionProvider(config:Config) {            _config = config;        }        public function connect(ignored:StreamProvider, clip:Clip, successListener:Function, objectEncoding: uint, connectionArgs:Array):void {                        _successListener = successListener;            _connection = null;            var configuredUrl:String = getNetConnectionUrl(clip)            if (! configuredUrl && _failureListener != null) {                _failureListener("netConnectionURL is not defined");            }            var parts:Array = getUrlParts(configuredUrl);            if (parts && (parts[0] == 'rtmp' || parts[0] == 'rtmpe') ) {                log.debug("will connect using RTMP and RTMPT in parallel, connectionClient " + _connectionClient);                _connector1 = new Connector((parts[0] == 'rtmp' ? 'rtmp' : 'rtmpe') + '://' + parts[1], _connectionClient, onConnectorSuccess, onConnectorFailure);                _connector2 = new Connector((parts[0] == 'rtmp' ? 'rtmpt' : 'rtmpte') +'://' + parts[1], _connectionClient, onConnectorSuccess, onConnectorFailure);                doConnect(_connector1, _config.proxyType, objectEncoding, (clip.getCustomProperty("connectionArgs") as Array) || connectionArgs);                // RTMPT connect is started after 250 ms                var delay:Timer = new Timer(_config.failOverDelay, 1);                delay.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {                    doConnect(_connector2, _config.proxyType, objectEncoding, connectionArgs);                });                delay.start();            } else {                log.debug("connecting to URL "+ configuredUrl);                _connector1 = new Connector(configuredUrl, _connectionClient, onConnectorSuccess, onConnectorFailure);                doConnect(_connector1, _config.proxyType, objectEncoding, connectionArgs);            }        }        private function doConnect(connector1:Connector, proxyType:String, objectEncoding:uint, connectionArgs:Array):void {            if (connectionArgs.length > 0) {                connector1.connect(_config.proxyType, objectEncoding, connectionArgs);            } else {                connector1.connect(_config.proxyType, objectEncoding, null);            }        }        private function onConnectorSuccess(connector:Connector, connection:NetConnection):void {            log.debug(connector + " established a connection");            if (_connection) return;            _connection = connection;                        if (connector == _connector2 && _connector1) {                _connector1.stop();            } else if (_connector2) {                _connector2.stop();            }            _successListener(connection);        }        private function onConnectorFailure():void {            if (isFailedOrNotUsed(_connector1) && isFailedOrNotUsed(_connector2) && _failureListener != null) {                _failureListener();            }        }        private function isFailedOrNotUsed(connector:Connector):Boolean {            if (! connector) return true;            return connector.failed;        }        private function getUrlParts(url:String):Array {            var pos:int = url.indexOf('://');            if (pos > 0) {                return [url.substring(0, pos), url.substring(pos + 3)];            }            return null;        }		private function getNetConnectionUrl(clip:Clip):String {			if (isRtmpUrl(clip.completeUrl)) {                log.debug("clip has complete rtmp url");				var url:String = clip.completeUrl;				var lastSlashPos:Number = url.lastIndexOf("/");				return url.substring(0, lastSlashPos);			}			if (clip.customProperties && clip.customProperties.netConnectionUrl) {                log.debug("clip has netConnectionUrl as a property " + clip.customProperties.netConnectionUrl);				return clip.customProperties.netConnectionUrl;			}            log.debug("using netConnectionUrl from config" + _config.netConnectionUrl);			return _config.netConnectionUrl;		}        private function isRtmpUrl(url:String):Boolean {            return url && url.toLowerCase().indexOf("rtmp") == 0;        }        public function set connectionClient(client:Object):void {            log.debug("received connection client " + client);            _connectionClient = client;        }        public function set onFailure(listener:Function):void {            _failureListener = listener;        }        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {            return true;        }        public function get connection():NetConnection {            return _connection;        }    }}