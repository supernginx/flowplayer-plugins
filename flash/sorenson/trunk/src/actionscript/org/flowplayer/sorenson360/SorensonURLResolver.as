/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009-2011 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.sorenson360 {
    import com.sorensonmedia.sdk.Sorenson360SDKLibrary;

    import fl.video.FLVPlayback;

    import flash.events.Event;
    import flash.events.NetStatusEvent;
    import flash.system.Security;

    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.Log;
    import org.flowplayer.view.Flowplayer;

    public class SorensonURLResolver implements ClipURLResolver, Plugin {
        private var log:Log = new Log(this);
        private var _failureListener:Function;
        private var _successListener:Function;
        private var _sorenson:Sorenson360SDKLibrary;
        private var _password:String;
        private var _clip:Clip;

        public function SorensonURLResolver() {
            Security.allowDomain("*");
            Security.allowInsecureDomain("*");

            _sorenson = new Sorenson360SDKLibrary(new FLVPlayback());
            _sorenson.addEventListener("GetVideoUrlComplete", onGetVideoUrl);
            _sorenson.addEventListener("PasswordRequired", onPasswordRequired);
            _sorenson.addEventListener("PasswordIncorrect", onPasswordIncorrect);
            _sorenson.addEventListener("PasswordAccepted", onPasswordAccepted);
            _sorenson.addEventListener("VideoUnavailable", onVideoUnavailable);
        }

        public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {
            log.debug("resolve()");
            _clip = clip;
            _successListener = successListener;
            log.debug("resolving URL for id " + clip.url);
            _sorenson.requestVideoUrl(clip.url);
        }

        private function onPasswordRequired(event:Event):void {
            if (! _clip.getCustomProperty("videoPassword")) {
                fail("password required");
                return;
            }
            _sorenson.videoPassword = _clip.getCustomProperty("videoPassword") as String;
            _sorenson.requestVideoUrl(_clip.url);
        }

        private function onGetVideoUrl(event:Event):void {
            log.debug("resolved video URL '" + event.target.videoUrl + "'");
            _clip.setResolvedUrl(this, event.target.videoUrl);
            _successListener(_clip);
        }

        public function set onFailure(listener:Function):void {
            log.debug("received failure listener");
            _failureListener = listener;
        }

        public function onConfig(model:PluginModel):void {
            model.dispatchOnLoad();
        }

        public function onLoad(player:Flowplayer):void {
        }

        public function getDefaultConfig():Object {
            return null;
        }

        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
            return true;
        }

        private function fail(message:String):void {
            log.error("Failed to resolve: " +message);
            if (_failureListener != null) {
                _failureListener(message);
            }
        }

        private function onVideoUnavailable(event:Event):void {
            fail("video not available");
        }

        private function onPasswordAccepted(event:Event):void {
            log.debug("password accepted");
        }

        private function onPasswordIncorrect(event:Event):void {
            log.debug("incorrect password");
        }
    }
}