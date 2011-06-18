/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>, Anssi Piirainen <api@iki.fi> Flowplayer Oy
 * Copyright (c) 2009, 2010 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.bitrateselect {

    import org.flowplayer.net.BitrateResource;
    import org.flowplayer.net.BitrateItem;
    import org.flowplayer.model.Clip;

    public class HDBitrateResource extends BitrateResource {

        private var _hasHD:Boolean = false;

        override public function addBitratesToClip(clip:Clip):Vector.<BitrateItem> {

            var streamingItems:Vector.<BitrateItem> = super.addBitratesToClip(clip);

            if (streamingItems.length == 2) {
                //set this item to a hd clip
                var hdItem:BitrateItem = streamingItems[streamingItems.length - 1] as BitrateItem;
                hdItem.hd = true;

                //set this item to a sd clip
                var sdItem:BitrateItem = streamingItems[0] as BitrateItem;
                sdItem.sd = true;
                clip.setCustomProperty("hdBitrateItem", hdItem);
                clip.setCustomProperty("sdBitrateItem", sdItem);

                _hasHD = true;
                log.error("HD feature is set, SD Bitrate: " + sdItem.bitrate + " HD Bitrate: " + hdItem.bitrate);
            }

            return streamingItems;
        }

        public function get hasHD():Boolean {
            return _hasHD;
        }
    }
}
