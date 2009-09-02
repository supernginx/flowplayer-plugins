/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By:
 *     Andreas Reiter
 *     Anssi Piirainen, Flowplayer Oy
 * Copyright (c) 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.akamai{
    import com.akamai.AkamaiConnection;
    import com.akamai.events.AkamaiNotificationEvent;
    import com.akamai.rss.AkamaiBOSSParser;
    
    import flash.events.NetStatusEvent;
    import flash.net.NetConnection;

    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.controller.ConnectionProvider;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.Flowplayer;

    public class AkamaiSmilResolver implements ClipURLResolver, Plugin {
        private var log:Log = new Log(this);
        private var _failureListener:Function;
        private var _player:Flowplayer;
        private var _model:PluginModel;
        private var _connectionClient:Object;
        private var _successListener:Function;
        private var _streamName:String;
        private var _provider:StreamProvider;
        private var _objectEncoding:uint;
        private var _clip:Clip;
        private var _mainResolver:ClipURLResolver;

        private var bossMetafile:AkamaiBOSSParser;
        private var ak:AkamaiConnection;

        public function AkamaiSmilResolver(mainResolver:ClipURLResolver) {
            _mainResolver = mainResolver;
        }


        public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {
            log.debug("resolve()");
            _provider = provider;
            _successListener = successListener;
            _clip = clip;

            // loadSmil
            bossMetafile = new AkamaiBOSSParser();
			bossMetafile.addEventListener(AkamaiNotificationEvent.PARSED,bossParsedHandler);

			bossMetafile.load(_clip.completeUrl);
        }
        
        // Handles the notification that the BOSS feed was successfully parsed
		private function bossParsedHandler(e:AkamaiNotificationEvent):void {

            log.debug("BOSS parsed successfully:");
            log.debug("  Server name: " + bossMetafile.serverName);
            log.debug("  App name: " + bossMetafile.appName);
            log.debug("  Stream name: " + bossMetafile.streamName);
            log.debug("  Protocol: " + bossMetafile.protocol);
            log.debug("  Is live: " + bossMetafile.isLive);
            log.debug("  Title: " + bossMetafile.title);
            log.debug("  Source: " + bossMetafile.source);
            log.debug("  Author: " + bossMetafile.author);
            log.debug("  Clip begin: " + bossMetafile.clipBegin);
            log.debug("  Clip end: " + bossMetafile.clipEnd);
            log.debug("  Duration: " + bossMetafile.duration);
            log.debug("  Connect Auth Params: " + bossMetafile.connectAuthParams);
            log.debug("  Play Auth Params: " + bossMetafile.playAuthParams);
            log.debug("  Secondary Encoder Source: " + bossMetafile.secondaryEncoderSrc);
            log.debug("  Keywords: " + bossMetafile.keywords);
            log.debug("======= End of Metafile data ===========");

            var protocol:String = bossMetafile.protocol.indexOf("rtmpe") != -1 ? "rtmpe,rtmpte" : "rtmp";
            _clip.setCustomProperty("netConnectionUrl", protocol + "://" + bossMetafile.serverName + "/" + bossMetafile.appName + (bossMetafile.connectAuthParams ? "?" + bossMetafile.connectAuthParams : ""));
            _clip.live = bossMetafile.isLive;
            if (bossMetafile.isLive) {
                _clip.setCustomProperty("rtmpSubscribe", true);
            }
            _clip.setResolvedUrl(_mainResolver, bossMetafile.streamName + (bossMetafile.playAuthParams ? "?" + bossMetafile.playAuthParams : ""));
            _successListener(_clip);
		}

        public function set onFailure(listener:Function):void {
            _failureListener = listener;
        }

        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
            return true;
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

    }
}