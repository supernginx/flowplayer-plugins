/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>, Anssi Piirainen <api@iki.fi> Flowplayer Oy
 * Copyright (c) 2009, 2010 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.httpstreaming {


    import flash.events.NetStatusEvent;

    import flash.net.NetStream;
    import flash.net.NetConnection;

    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.ClipEventType;
    import org.flowplayer.controller.NetStreamControllingStreamProvider;
    import org.flowplayer.controller.NetStreamClient;
    import org.flowplayer.model.ClipType;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.Flowplayer;

    import org.osmf.logging.Log;
    import org.osmf.net.httpstreaming.HTTPNetStream;
	import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FFileHandler;
	import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FIndexHandler;
    import org.osmf.net.httpstreaming.HTTPStreamingIndexHandlerBase;
    import org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase;
    import org.osmf.net.httpstreaming.HTTPStreamingUtils;

    import org.osmf.media.URLResource;

    import org.flowplayer.bwcheck.net.OsmfLoggerFactory;
    import org.flowplayer.bwcheck.net.OsmfLogger;

    import org.flowplayer.httpstreaming.Config;

    public class HttpStreamingProvider extends NetStreamControllingStreamProvider implements Plugin {
        private var _bufferStart:Number;
        private var _config:Config;
        private var _startSeekDone:Boolean;
        private var _model:PluginModel;
        private var _previousClip:Clip;
        private var _currentClip:Clip;
        private var _player:Flowplayer;
        private var netResource:URLResource;
        
        override public function onConfig(model:PluginModel):void {
            _model = model;
            _config = new PropertyBinder(new Config(), null).copyProperties(model.config) as Config;

            CONFIG::LOGGING {
                Log.loggerFactory = new OsmfLoggerFactory();
            }
        }
    
        override public function onLoad(player:Flowplayer):void {
            log.info("onLoad()");
            _player = player;

            _model.dispatchOnLoad();
        }
    
        override protected function getClipUrl(clip:Clip):String {
            return clip.completeUrl;
        }
    
        override protected function doLoad(event:ClipEvent, netStream:NetStream, clip:Clip):void {
            if (!netResource) return;

            clip.onPlayStatus(onPlayStatus);

            log.debug("Playing F4F Stream With Resource " + netResource);
            _bufferStart = clip.currentTime;
            _startSeekDone = false;
            netStream.client = new NetStreamClient(clip, _player.config, streamCallbacks);
            netStream.play(netResource, clip.start);
        }

        private function onPlayStatus(event:ClipEvent) : void {
            log.debug("onPlayStatus() -- " + event.info.code);
            if (event.info.code == "NetStream.Play.TransitionComplete"){
                dispatchEvent(new ClipEvent(ClipEventType.SWITCH_COMPLETE));
            }
            return;
        }

        override protected function onNetStatus(event:NetStatusEvent) : void {
            log.info("onNetStatus(), code: " + event.info.code + ", paused? " + paused + ", seeking? " + seeking);
            switch(event.info.code){
                case "NetStream.Play.Transition":
                    log.debug("Stream Transition -- " + event.info.details);
                    dispatchEvent(new ClipEvent(ClipEventType.SWITCH, event.info.details));
                    break;
            }
            return;
        }

        override protected function doSwitchStream(event:ClipEvent, netStream:NetStream, clip:Clip, netStreamPlayOptions:Object = null):void {      
            log.debug("doSwitchStream()");

			_previousClip = clip;

            if (netStream.hasOwnProperty("play2") && netStreamPlayOptions) {
                import flash.net.NetStreamPlayOptions;
                if (netStreamPlayOptions is NetStreamPlayOptions) {
					log.debug("doSwitchStream() calling play2()")
					netStream.play2(netStreamPlayOptions as NetStreamPlayOptions);
				}
			} else {
                //fix for #338, don't set the currentTime when dynamic stream switching
                _bufferStart = clip.currentTime;
                clip.currentTime = Math.floor(_previousClip.currentTime + netStream.time);
				load(event, clip);
                dispatchEvent(event);
			}
        }

        override public function get allowRandomSeek():Boolean {
           return true;
        }
    
        override protected function canDispatchBegin():Boolean {
            return true;
        }

        override protected function canDispatchStreamNotFound():Boolean {
            return false;
        }
    
        public function getDefaultConfig():Object {
            return null;
        }
        
        override public function get type():String {
            return "httpstreaming";    
        }
        
        override protected function createNetStream(connection:NetConnection):NetStream {

            if (!clip.getCustomProperty("urlResource")) return super.createNetStream(connection);

            clip.type = ClipType.VIDEO;

            netResource = clip.getCustomProperty("urlResource") as URLResource;

            var fileHandler:HTTPStreamingFileHandlerBase = new HTTPStreamingF4FFileHandler();
			var indexHandler:HTTPStreamingIndexHandlerBase = new HTTPStreamingF4FIndexHandler(fileHandler);
			var httpNetStream:HTTPNetStream = new HTTPNetStream(connection, indexHandler, fileHandler);
			httpNetStream.manualSwitchMode = true;
            httpNetStream.enhancedSeek = true;
			httpNetStream.indexInfo = HTTPStreamingUtils.createF4FIndexInfo(netResource);
            return httpNetStream;
        }
    }
}
