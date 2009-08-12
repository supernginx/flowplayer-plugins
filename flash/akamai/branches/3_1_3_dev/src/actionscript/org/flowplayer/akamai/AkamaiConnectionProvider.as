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
    import flash.net.NetConnection;

    import flash.net.URLRequest;

    import org.flowplayer.controller.ConnectionProvider;
    import org.flowplayer.controller.ResourceLoader;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.view.Flowplayer;

    public class AkamaiConnectionProvider extends AbstractAsyncConnectionProvider implements ConnectionProvider, Plugin {

        private var _parseResults:Object;
        private var _player:Flowplayer;
        private var _model:PluginModel;

        override protected function doConnect():void {
            _parseResults = URLUtil.parseURL(clip.completeUrl);
            if (!_parseResults.isRTMP) {
                throw new Error("This is not a RTMP url");
            }

            findAkamaiIP("http://" + _parseResults.serverName);
        }

        public function findAkamaiIP(akamaiAppURL:String):void
        {
            log.debug("findAkamaiIP(), requesting " + akamaiAppURL + "/fcs/ident " + _player);

            var loader:ResourceLoader = _player.createLoader();
            loader.load(akamaiAppURL + "/fcs/ident/", function(loader:ResourceLoader):void {
                log.debug("Ident file received " + loader.getContent());
                updateClip(String(loader.getContent()));
                connection.connect(clip.getCustomProperty("netConnectionUrl") as String);
            }, true);
        }

        private function updateClip(identFile:String):void {
            log.debug("parsing Ident file " + identFile);
            var ident:XML = new XML(identFile);
            var ip:String = ident.ip.toString();

            var url:String = _parseResults.protocol + "/" + ip;
            if (_parseResults.portNumber) {
                url += ":" + _parseResults.portNumber;
            }
            url += "/" + getAkamaiAppName(clip.completeUrl);

            log.debug("netConnectionUrl is " + url);
            clip.setCustomProperty("netConnectionUrl", url);
            clip.resolvedUrl = getAkamaiStreamName(clip.completeUrl);
            clip.url = null;
            clip.baseUrl = null;
            log.debug("stream name is " + clip.url);
        }

        public function onLoad(player:Flowplayer):void {
            _player = player;
            _model.dispatchOnLoad();
        }

        public function getDefaultConfig():Object {
            return null;
        }

        public function onConfig(model:PluginModel):void {
            _model = model;
        }

        private function getAkamaiAppName(p:String):String
        {
            var result:String;
            //first check if a vhost is being passed in
            if (p.indexOf("_fcs_vhost") != -1) {
                result = p.slice(p.indexOf("/", 10)+1, p.indexOf("/", p.indexOf("/", 10)+1))+"?_fcs_vhost="+p.slice(p.indexOf("_fcs_vhost")+11, p.length);
            } else {
                result =  p.slice(p.indexOf("/", 10)+1, p.indexOf("/", p.indexOf("/", 10)+1))+"?_fcs_vhost="+ URLUtil.parseURL(p).serverName;
            }
            if (p.indexOf("?") != -1) {
                result += "&"+p.slice(p.indexOf("?")+1, p.length);
            }
            return result;
        }

        private function getAkamaiStreamName(p:String):String
        {
            var tempApp:String=p.slice( p.indexOf("/",10) + 1, p.indexOf("/", p.indexOf("/",10) + 1));
            tempApp = p.indexOf("_fcs_vhost") != -1 ?
                      p.slice(p.indexOf(tempApp)+tempApp.length+1, p.indexOf("_fcs_vhost")-1)
                        : p.slice(p.indexOf(tempApp)+tempApp.length+1, p.length);
            return URLUtil.stripFlvExtension(tempApp);
        }
    }
}