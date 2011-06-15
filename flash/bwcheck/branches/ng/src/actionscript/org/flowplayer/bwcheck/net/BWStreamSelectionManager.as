/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>, Anssi Piirainen <api@iki.fi> Flowplayer Oy
 * Copyright (c) 2009, 2010 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.bwcheck.net {

    import org.flowplayer.net.BitrateItem;
    import org.flowplayer.net.StreamSelectionManager;
    import org.flowplayer.net.BitrateResource;

    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.PropertyBinder;



    import org.flowplayer.model.DisplayProperties;

    import flash.display.Stage;
    import flash.display.StageDisplayState;

    import org.flowplayer.bwcheck.config.Config;

    import org.osmf.net.DynamicStreamingItem;

public class BWStreamSelectionManager extends StreamSelectionManager {

        private var _config:Config;
        private static var bwSelectLog:Log = new Log("org.flowplayer.bwcheck.net::BWStreamSelectionManager");
        private var dynamicStreamingItems:Vector.<DynamicStreamingItem>;

        public function BWStreamSelectionManager(bitrateResource:BitrateResource, player:Flowplayer, resolver:ClipURLResolver, config:Config) {
            super(bitrateResource, player, resolver);

            _config = config;
        }

        override public function getStreamIndex(bandwidth:Number):Number {
            for (var i:Number = streamItems.length - 1; i >= 0; i--) {

                var item:BitrateItem = streamItems[i];

                bwSelectLog.debug("candidate '" + item.streamName + "' has width " + item.width + ", bitrate " + item.bitrate);

                var enoughBw:Boolean = bandwidth >= item.bitrate;
                var bitrateSpecified:Boolean = item.bitrate > 0;
                bwSelectLog.info("fits screen? " + fitsScreen(item, _player, _config) + ", enough BW? " + enoughBw + ", bitrate specified? " + bitrateSpecified);

                if (fitsScreen(item, _player, _config) && enoughBw && bitrateSpecified) {
                    bwSelectLog.debug("selecting bitrate with width " + item.width + " and bitrate " + item.bitrate);
                    currentIndex = i;
                    return i;
                    break;
                }
            }
            return -1;
        }

        internal static function fitsScreen(item:BitrateItem, player:Flowplayer, config:Config):Boolean {
            if (! item.width) return true;

            var screen:DisplayProperties = player.screen;
            var stage:Stage = screen.getDisplayObject().stage;
            // take the size from screen when the screen width is 100% --> by default works on HW scaled mode also
            var screenWidth:Number = stage.displayState == StageDisplayState.FULL_SCREEN && screen.widthPct == 100 ? stage.fullScreenWidth : screen.getDisplayObject().width;

            bwSelectLog.debug("screen width is " + screenWidth);

            // max container width specified --> allows for resizing the player or for going above the current screen width
            if (config.maxWidth > 0 && ! player.isFullscreen()) {
                return config.maxWidth >= item.width;
            }
            return screenWidth >= item.width;
        }
    }
}
