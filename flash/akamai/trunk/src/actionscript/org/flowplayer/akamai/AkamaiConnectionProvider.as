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
            _parseResults = parseURL(clip.completeUrl);
            if (!_parseResults.isRTMP) {
                throw new Error("This is not a RTMP url");
            }

            findAkamaiIP("http://" + _parseResults.serverName);
        }

        public function findAkamaiIP(akamaiAppURL:String):void
        {
            log.debug("findAkamaiIP(), requesting " + akamaiAppURL + "/fcs/ident " + _player);
            //matches one of these:
            //http://cp44952.edgefcs.net/
            //http://cp44952.edgefcs.net
            //https://cp44952.edgefcs.net/
            //https://cp44952.edgefcs.net
//            var reg:RegExp = new RegExp("^http?\://cp[0-9]{1,9}\.edgefcs\.net/?$","i");
//            if(!akamaiAppURL) throw new Error("The Akamai host cannot be null");
//            if(!akamaiAppURL.match(reg)) throw new Error("The supplied Akamai Application URL is not correctly formatted");

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
            } else {
                url += ":1935";
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

        private function parseURL(url:String):Object
        {
            var parseResults:Object = {};

            // get protocol
            var startIndex:uint = 0;
            var endIndex:int = url.indexOf(":/", startIndex);
            if (endIndex >= 0)
            {
                endIndex += 2;
                parseResults.protocol = url.slice(startIndex, endIndex);
                parseResults.isRelative = false;
            }
            else
                parseResults.isRelative = true;

            if ( parseResults.protocol != null &&
                 ( parseResults.protocol == "rtmp:/" ||
                   parseResults.protocol == "rtmpt:/" ||
                   parseResults.protocol == "rtmps:/" ||
                   parseResults.protocol == "rtmpe:/" ||
                   parseResults.protocol == "rmpte:/" ) )
            {
                parseResults.isRTMP = true;

                startIndex = endIndex;

                if (url.charAt(startIndex) == '/')
                {
                    startIndex++;
                    // get server (and maybe port)
                    var colonIndex:Number = url.indexOf(":", startIndex);
                    var slashIndex:Number = url.indexOf("/", startIndex);
                    if (slashIndex < 0)
                    {
                        if (colonIndex < 0)
                            parseResults.serverName = url.slice(startIndex, url.length);
                        else
                        {
                            endIndex = colonIndex;
                            parseResults.portNumber = url.slice(startIndex, endIndex);
                            startIndex = endIndex + 1;
                            parseResults.serverName = url.slice(startIndex, url.length);
                        }
                        return parseResults;
                    }
                    if (colonIndex >= 0 && colonIndex < slashIndex)
                    {
                        endIndex = colonIndex;
                        parseResults.serverName = url.slice(startIndex, endIndex);
                        startIndex = endIndex + 1;
                        endIndex = slashIndex;
                        parseResults.portNumber = url.slice(startIndex, endIndex);
                    }
                    else
                    {
                        endIndex = slashIndex;
                        parseResults.serverName = url.slice(startIndex, endIndex);
                    }
                    startIndex = endIndex + 1;
                }

                // handle wrapped RTMP servers bit recursively, if it is there
                if (url.charAt(startIndex) == '?')
                {
                    var subURL:String = url.slice(startIndex + 1, url.length);
                    var subParseResults:Object = parseURL(subURL);
                    if (!subParseResults.protocol || !subParseResults.isRTMP)
                        throw new Error("Invalid URL: " + url);
                    parseResults.wrappedURL = "?";
                    parseResults.wrappedURL += subParseResults.protocol;
                    if (subParseResults.serverName != null)
                    {
                        parseResults.wrappedURL += "/";
                        parseResults.wrappedURL +=  subParseResults.server;
                    }
                    if (subParseResults.wrappedURL != null)
                    {
                        parseResults.wrappedURL += "/?";
                        parseResults.wrappedURL +=  subParseResults.wrappedURL;
                    }
                    parseResults.appName = subParseResults.appName;
                    parseResults.streamName = subParseResults.streamName;
                    return parseResults;
                }

                // get application name
                endIndex = url.indexOf("/", startIndex);
                if (endIndex < 0)
                {
                    parseResults.appName = url.slice(startIndex, url.length);
                    return parseResults;
                }
                parseResults.appName = url.slice(startIndex, endIndex);
                startIndex = endIndex + 1;

                // check for instance name to be added to application name
                endIndex = url.indexOf("/", startIndex);
                if (endIndex < 0)
                {
                    parseResults.streamName = url.slice(startIndex, url.length);
                    // strip off .flv and .flv2 if included
                    if (parseResults.streamName.slice(-5, parseResults.streamName.length).toLowerCase() == ".flv2")
                        parseResults.streamName = parseResults.streamName.slice(0, -5);
                    else if (parseResults.streamName.slice(-4, parseResults.streamName.length).toLowerCase() == ".flv")
                        parseResults.streamName = parseResults.streamName.slice(0, -4);
                    return parseResults;
                }
                parseResults.appName += "/";
                parseResults.appName += url.slice(startIndex, endIndex);
                startIndex = endIndex + 1;

                // get flv name
                parseResults.streamName = url.slice(startIndex, url.length);
                // strip off .flv and .flv2 if included
                if (parseResults.streamName.slice(-5, parseResults.streamName.length).toLowerCase() == ".flv2")
                    parseResults.streamName = parseResults.streamName.slice(0, -5);
                else if (parseResults.streamName.slice(-4, parseResults.streamName.length).toLowerCase() == ".flv")
                    parseResults.streamName = parseResults.streamName.slice(0, -4);

            }
            else
            {
                // is http, just return the full url received as streamName
                parseResults.isRTMP = false;
                parseResults.streamName = url;
            }

            return parseResults;
        }

        /**
         * Get the Akamai App Name, usually "ondemand"
         */
        private function getAkamaiAppName(p:String):String
        {
            var result:String;
            //first check if a vhost is being passed in
            if (p.indexOf("_fcs_vhost") != -1) {
                result = p.slice(p.indexOf("/", 10)+1, p.indexOf("/", p.indexOf("/", 10)+1))+"?_fcs_vhost="+p.slice(p.indexOf("_fcs_vhost")+11, p.length);
            } else {
                result =  p.slice(p.indexOf("/", 10)+1, p.indexOf("/", p.indexOf("/", 10)+1))+"?_fcs_vhost="+parseURL(p).serverName;
            }
            if (p.indexOf("?") != -1) {
                result += "&"+p.slice(p.indexOf("?")+1, p.length);
            }
            return result;
        }

        /**
         * Get the stream name we're trying to play.
         */
        private function getAkamaiStreamName(p:String):String
        {
            var tempApp:String=p.slice( p.indexOf("/",10) + 1, p.indexOf("/", p.indexOf("/",10) + 1));
            return p.indexOf("_fcs_vhost") != -1 ? p.slice(p.indexOf(tempApp)+tempApp.length+1, p.indexOf("_fcs_vhost")-1) : p.slice(p.indexOf(tempApp)+tempApp.length+1, p.length);
        }
    }
}