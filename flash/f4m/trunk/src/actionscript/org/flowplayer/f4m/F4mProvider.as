/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>, Anssi Piirainen <api@iki.fi> Flowplayer Oy
 * Copyright (c) 2009, 2010 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.f4m {

        import flash.events.NetStatusEvent;

        import flash.utils.ByteArray;

        import org.flowplayer.model.Plugin;
        import org.flowplayer.model.PluginModel;
        import org.flowplayer.model.Clip;

        import org.flowplayer.controller.ResourceLoader;
        import org.flowplayer.controller.StreamProvider;
        import org.flowplayer.controller.ClipURLResolver;

        import org.flowplayer.util.PropertyBinder;
        import org.flowplayer.util.Log;
        import org.flowplayer.util.URLUtil;

        import org.flowplayer.view.Flowplayer;

        import org.flowplayer.bwcheck.BitrateItem;

        import org.flowplayer.f4m.config.Config;

        import org.osmf.elements.f4mClasses.DRMAdditionalHeader;
        import org.osmf.elements.f4mClasses.Manifest;
        import org.osmf.elements.f4mClasses.ManifestParser;

        import org.osmf.media.MediaResourceBase;
        import org.osmf.media.URLResource;

        import org.osmf.net.DynamicStreamingResource;
        import org.osmf.net.DynamicStreamingItem;
        import org.osmf.net.StreamingURLResource;


        public class F4mProvider implements ClipURLResolver, Plugin {
            private var _config:Config;
            private var _model:PluginModel;
            private var log:Log = new Log(this);
            private var _failureListener:Function;
            private var _successListener:Function;
            private var _clip:Clip;
            private var _player:Flowplayer;
            private var manifest:Manifest;
            private var parser:ManifestParser;
            private var netResource:MediaResourceBase;
            private var dynResource:DynamicStreamingResource;
            private var streamResource:StreamingURLResource;
            private var unfinishedDRMHeaders:Number = 0;
    

            public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {
                _clip = clip;
                _successListener = successListener;
                loadF4M(_clip.completeUrl, onF4MLoaded);
            }

            [External]
            public function resolveF4M(f4mUrl:String, callback:Function):void {
                log.debug("resolveF4M()");
                loadF4M(f4mUrl, function(f4mContent:String):void {
                    //var result:Array = parseSmil(smilContent);
                    //log.debug("resolveSmil(), resolved to netConnectionUrl " + result[0] + " streamName " + result[1]);
                    //callback(result[0], result[1]);
                });
            }

            private function loadF4M(f4mUrl:String, loadedCallback:Function):void {
                if (!_player) return;
                log.debug("connect(), loading F4M file from " + f4mUrl);

                var loader:ResourceLoader = _player.createLoader();
                loader.load(f4mUrl, function(loader:ResourceLoader):void {
                    log.debug("F4M file received");
                    loadedCallback(String(loader.getContent()));
                }, true);
            }

            private function onF4MLoaded(f4mContent:String):void {
                parseF4MManifest(f4mContent);
            }


            protected function formatStreamItems(streamItems:Vector.<DynamicStreamingItem>):Vector.<DynamicStreamingItem> {
                var bitrateItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();

                //if we have custom bitrates property set on the bitrates clip property
                var bitrateOptions:Array = [];
                if (_clip.getCustomProperty("bitrates")) {
                    bitrateOptions = _clip.getCustomProperty("bitrates") as Array;
                    bitrateOptions.sortOn(["bitrate"], Array.NUMERIC);
                }

                for (var index:int = 0; index < dynResource.streamItems.length; index++) {
                    var item:DynamicStreamingItem = streamItems[index];

                    var bitrateItem:BitrateItem = new BitrateItem();
                    bitrateItem.url = item.streamName;
                    bitrateItem.bitrate = item.bitrate;
                    bitrateItem.index = index;

                    bitrateItem.width = item.width ?
                        item.width :
                        manifest.media[index].metadata.width;
                    bitrateItem.height = item.height ?
                        item.height :
                        manifest.media[index].metadata.height;

                    //if we have custom bitrates property set on the bitrates clip property
                    //set the custom bitrate label, sd, hd properties
                    if (bitrateOptions[index])  {
                        var itemConfig:Object = bitrateOptions[index];
                        if (itemConfig.hasOwnProperty("label")) bitrateItem.label = itemConfig.label;
                        if (itemConfig.hasOwnProperty("sd")) bitrateItem.sd = itemConfig.sd;
                        if (itemConfig.hasOwnProperty("hd")) bitrateItem.hd = itemConfig.hd;
                    }

                    bitrateItems.push(bitrateItem);
                }
                return bitrateItems;
            }

            private function onF4MFinished():void
            {
                log.debug("F4M Manifest Finished");
                try
                {

                    netResource = parser.createResource(manifest, new URLResource(_clip.completeUrl));

                    if (netResource is DynamicStreamingResource) {
                        dynResource = netResource as DynamicStreamingResource;

                        //formats the stream items to be ready for the bwcheck plugin
                        dynResource.streamItems = formatStreamItems(dynResource.streamItems);

                        _clip.setCustomProperty("dynamicStreamingItems", dynResource.streamItems);
                        _clip.setCustomProperty("urlResource", dynResource);

                    } else {
                        streamResource = netResource as StreamingURLResource;
                        _clip.setResolvedUrl(this, streamResource.url);
                        _clip.setCustomProperty("urlResource", streamResource);
                    }

                    if (manifest.baseURL && URLUtil.isRtmpUrl(manifest.baseURL)) {
                        _clip.setCustomProperty("netConnectionUrl", manifest.baseURL);
                    }

                    _clip.setCustomProperty("manifestInfo",manifest);


                    if (_successListener != null) {
                        _successListener(_clip);
                    }

                }
                catch (error:Error)
                {
                    log.error(error.message);
                }
            }

            private function parseF4MManifest(f4mContent:String):void {
               // log.debug("F4M Content: " + f4mContent);
                log.debug("Parsing F4M Manifest");
                parser = new ManifestParser();

                try
                {
                    manifest = parser.parse(f4mContent, URLUtil.baseUrl(_clip.url));
                }
                catch (parseError:Error)
                {
                    log.error(parseError.errorID + " " + parseError.message);
                }

                if (manifest != null)
                {
                      if (manifest.drmAdditionalHeaders.length > 0) {
                       parseDrmAddtionalHeaders();
                    }  else {
                       onF4MFinished();
                    }
                }
            }

            private function onDRMHeaderLoad():void
            {
                unfinishedDRMHeaders--;

                if (unfinishedDRMHeaders == 0)
                {
                    onF4MFinished();
                }
            }

            private function parseDrmAddtionalHeaders():void {
                log.error("Parsing DRM Headers");
                for each (var item:DRMAdditionalHeader in manifest.drmAdditionalHeaders)
                {
                        // DRM Metadata  - we may make this load on demand in the future.
                        if (item.url != null)
                        {
                            unfinishedDRMHeaders++;
                            loadAdditionalDRMHeader(item, onDRMHeaderLoad);
                        }
                }

            }

            private function loadAdditionalDRMHeader(item:DRMAdditionalHeader, loadedCallback:Function):void
            {
                log.error("Loading DRM Header");
                var loader:ResourceLoader = _player.createLoader();
                loader.load(item.url, function(loader:ResourceLoader):void {
                    log.debug("F4M DRM Header received");
                    item.data = ByteArray(loader.getContent());
                    loadedCallback();
                }, true);
            }

            public function set onFailure(listener:Function):void {
                _failureListener = listener;
            }

            public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
                return true;
            }

            public function onConfig(model:PluginModel):void {
                _model = model;
                _config = new PropertyBinder(new Config(), null).copyProperties(model.config) as Config;
            }

            public function onLoad(player:Flowplayer):void {
                log.info("onLoad()");
                _player = player;
                _model.dispatchOnLoad();
            }

            public function getDefaultConfig():Object {
                return null;
            }

    }
}
