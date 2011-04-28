/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <api@iki.fi>
 *
 * Copyright (c) 2008-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.slowmotion {
    import org.flowplayer.controller.StreamProvider;

    public class WowzaSlowMotion extends AbstractSlowMotion {

        public function WowzaSlowMotion(provider:StreamProvider, timeProvider:SlowMotionTimeProvider) {
            super(provider, timeProvider);
        }

        override protected function normalSpeed():void {
            provider.netStream.seek(time);
        }

        override protected function trickSpeed(multiplier:Number, fps:Number, forward:Boolean):void {
            var targetFps:Number = fps > 0 ? fps : multiplier * 50;
            provider.netConnection.call("trickPlay", null, multiplier, targetFps, forward ? 1 : -1);
            provider.netStream.seek(time);
        }

    }
}
