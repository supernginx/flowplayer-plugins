/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, Flowplayer Oy
 * Copyright (c) 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.smil{
    import flash.events.NetStatusEvent;
    import flash.net.NetConnection;

    import org.flowplayer.controller.ConnectionProvider;
    import org.flowplayer.controller.ResourceLoader;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.Log;
    import org.flowplayer.view.Flowplayer;

    public class SmilResolver implements ConnectionProvider, Plugin {
        private var log:Log = new Log(this);
        private var _failureListener:Function;
        private var _player:Flowplayer;
        private var _model:PluginModel;
        private var _connectionClient:Object;
        private var _successListener:Function;
        private var _connection:NetConnection;
        private var _streamName:String;
        private var _provider:StreamProvider;
        private var _objectEncoding:uint;
        private var _clip:Clip;

        public function connect(provider:StreamProvider, clip:Clip, successListener:Function, objectEncoding: uint, ... rest):void {
            _provider = provider;
            _successListener = successListener;

            if (clip.getCustomProperty("netConnectionUrl")) {
                log.debug("clip now has a netConnectionUrl, connecting");
                doConnect(clip, successListener, objectEncoding);
                return;
            }
            _clip = clip;
            _successListener = successListener;
            _objectEncoding = objectEncoding;
            loadSmil(_clip.completeUrl, onSmilLoaded);
        }

        [External]
        public function resolveSmil(smilUrl:String, callback:Function):void {
            log.debug("resolveSmil()");
            loadSmil(smilUrl, function(smilContent:String):void {
                var result:Array = parseSmil(smilContent);
                log.debug("resolveSmil(), resolved to netConnectionUrl " + result[0] + " streamName " + result[1]);
                callback(result[0], result[1]);
            });
        }

        private function loadSmil(smilUrl:String, loadedCallback:Function):void {
            log.debug("connect(), loading SMIL file from " + smilUrl);
            var loader:ResourceLoader = _player.createLoader();
            loader.load(smilUrl, function(loader:ResourceLoader):void {
                log.debug("SMIL file received");
                loadedCallback(String(loader.getContent()));
            }, true);
        }

        private function onSmilLoaded(smilContent:String):void {
            updateClip(_clip, smilContent);
            doConnect(_clip, _successListener, _objectEncoding);
        }


        public function set onFailure(listener:Function):void {
            _failureListener = listener;
        }

        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
            return true;
        }

         public function set connectionClient(client:Object):void {
             _connectionClient = client;
         }

        public function onConfig(model:PluginModel):void {
            _model = model;
        }

        public function onLoad(player:Flowplayer):void {
            log.debug("onLoad");
            _player = player;
            _model.dispatchOnLoad();
        }

        public function getDefaultConfig():Object {
            return null;
        }

        private function doConnect(clip:Clip, successListener:Function, objectEndocing:uint):void {
            _connection = new NetConnection();
            _connection.proxyType = "best";
            _connection.objectEncoding = objectEndocing;

            if (_connectionClient) {
                _connection.client = _connectionClient;
            }
            _connection.addEventListener(NetStatusEvent.NET_STATUS, _onConnectionStatus);
            _connection.connect(clip.getCustomProperty("netConnectionUrl") as String);
        }


        private function updateClip(clip:Clip, smilFile:String):void {
            log.debug("parsing SMIL file " + smilFile);
            var result:Array = parseSmil(smilFile);
            clip.setCustomProperty("netConnectionUrl", result[0]);
            clip.resolvedUrl = result[1];
        }

        private function parseSmil(smilFile:String):Array {
            var smil:XML = new XML(smilFile);
            return [smil.children()[0].children()[0].@base.toString(), smil.children()[1].children()[0].@src.toString()];
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
    }
}