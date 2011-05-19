/**
 * Created by IntelliJ IDEA.
 * User: danielr
 * Date: 17/05/11
 * Time: 5:55 PM
 * To change this template use File | Settings | File Templates.
 */
package org.flowplayer.bitrateselect {

    import org.flowplayer.net.BitrateResource;
    import org.flowplayer.net.BitrateItem;
    import org.flowplayer.model.Clip;
    import org.osmf.net.DynamicStreamingItem;
    import org.flowplayer.util.Log;

    public class HDBitrateResource extends BitrateResource {

        private var log:Log = new Log(this);

        public function HDBitrateResource() {

        }

        override public function addBitratesToClip(clip:Clip):Vector.<DynamicStreamingItem> {

            var streamingItems:Vector.<DynamicStreamingItem>;

            streamingItems = super.addBitratesToClip(clip);

            if (streamingItems.length == 2) {
                //set this item to a hd clip
                var hdItem:BitrateItem = streamingItems[streamingItems.length - 1] as BitrateItem;
                hdItem.hd = true;

                //set this item to a sd clip
                var sdItem:BitrateItem = streamingItems[0] as BitrateItem;
                sdItem.sd = true;
                clip.setCustomProperty("hdBitrateItem", hdItem);
                clip.setCustomProperty("sdBitrateItem", sdItem);

                log.debug("HD feature is set, SD Bitrate: " + sdItem.bitrate + " HD Bitrate: " + hdItem.bitrate);
            }

            return streamingItems;
        }
    }
}
