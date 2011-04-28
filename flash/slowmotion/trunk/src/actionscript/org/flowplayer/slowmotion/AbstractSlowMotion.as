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
package org.flowplayer.slowmotion {
    import flash.net.NetStream;
    import flash.utils.Dictionary;
	import flash.utils.*;
	import flash.events.*;
	import flash.display.Loader;
	import org.flowplayer.layout.LayoutEvent;

	import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginError;
    import org.flowplayer.model.PluginModel;
	import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.util.Log;
    import org.flowplayer.view.Flowplayer;
	import org.flowplayer.util.PropertyBinder;

	import org.flowplayer.ui.containers.WidgetContainer;
	import org.flowplayer.ui.containers.WidgetContainerEvent;

	import org.flowplayer.ui.controllers.GenericButtonController;

	import fp.*;

    public class AbstractSlowMotion {
        protected var log:Log = new Log(this);
        private var _provider:StreamProvider;
        private var _timeProvider:SlowMotionTimeProvider;

        public function AbstractSlowMotion(provider:StreamProvider, timeProvider:SlowMotionTimeProvider) {
            _provider = provider;
            _timeProvider = timeProvider;
        }

        public final function normal():void {
            normalSpeed();
        }

        protected function normalSpeed():void {
            // should be overridden in subclasses
        }

        public final function trickPlay(multiplier:Number, fps:Number, forward:Boolean):void {
            trickSpeed(multiplier, fps, forward);
        }

        protected function trickSpeed(multiplier:Number, fps:Number, forward:Boolean):void {
            // should be overridden in subclasses
        }

        protected function get netStream():NetStream {
            return _provider.netStream;
        }

        protected function get provider():StreamProvider {
            return _provider;
        }

        protected function get timeProvider():SlowMotionTimeProvider {
            return _timeProvider;
        }

        protected function get time():Number {
            return timeProvider.getTime(netStream);
        }
    }
}