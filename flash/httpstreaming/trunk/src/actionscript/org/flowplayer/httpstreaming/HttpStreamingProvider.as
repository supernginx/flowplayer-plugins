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

    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.controller.NetStreamControllingStreamProvider;
    import org.flowplayer.controller.NetStreamClient;
    import org.flowplayer.model.ClipType;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.Flowplayer;
    
    import flash.events.NetStatusEvent;
    import flash.net.NetStream;
    import flash.net.NetConnection;

    import org.osmf.net.httpstreaming.HTTPNetStream;
	import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FFileHandler;
	import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FIndexHandler;
    import org.osmf.net.httpstreaming.HTTPStreamingIndexHandlerBase;
    import org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase;
    import org.osmf.net.httpstreaming.HTTPStreamingUtils;
    import org.osmf.media.URLResource;

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

            log.debug("Playing F4F Stream With Resource " + netResource);
            _bufferStart = clip.currentTime;
            _startSeekDone = false;
            netStream.client = new NetStreamClient(clip, _player.config, streamCallbacks);
            netStream.play(netResource, clip.start);
        }

        override protected function doSwitchStream(event:ClipEvent, netStream:NetStream, clip:Clip, netStreamPlayOptions:Object = null):void {      
            log.debug("doSwitchStream()");
            clip.currentTime = time;
            _bufferStart = clip.currentTime;
            _currentClip = clip;
    
            
    
            log.debug("Switching stream with current time: " + clip.currentTime);
    
            load(event, clip);
        }

        override public function get allowRandomSeek():Boolean {
           return true;
        }
    
       
        override protected function onMetaData(event:ClipEvent):void {
            
        }
    
        override protected function canDispatchBegin():Boolean {
            return true;
        }

        override protected function canDispatchStreamNotFound():Boolean {
            return false;
        }
    
        override protected function onNetStatus(event:NetStatusEvent):void {
            log.info("onNetStatus: " + event.info.code);
            
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
