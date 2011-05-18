/**
 * Created by IntelliJ IDEA.
 * User: danielr
 * Date: 5/05/11
 * Time: 9:26 PM
 * To change this template use File | Settings | File Templates.
 */
package org.flowplayer.net {

    import org.flowplayer.model.Clip;
    import org.osmf.net.DynamicStreamingItem;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.PropertyBinder;

    public class BitrateResource {

        private static var log:Log = new Log("org.flowplayer.net.BitrateResource");

        public function BitrateResource() {


        }

        private function sort(bitrates:Vector.<DynamicStreamingItem>):Vector.<DynamicStreamingItem> {
            var sorter:Function = function (a:DynamicStreamingItem, b:DynamicStreamingItem):Number {
                // increasing bitrate order
                if (a.bitrate == b.bitrate) {
                    // decreasing width inside the same bitrate
                    if (a.width == b.width) {
                        return 0;
                    } else if (a.width < b.width) {
                        return 1;
                    }
                    return -1;


                } else if (a.bitrate > b.bitrate) {
                    return 1;
                }
                return -1;
            };
            return bitrates.concat().sort(sorter);
        }

        public function addBitratesToClip(clip:Clip):Vector.<DynamicStreamingItem> {
            log.debug("addBitratesToClip()");

            var streamingItems:Vector.<DynamicStreamingItem>;

            if (!clip.getCustomProperty("dynamicStreamingItems")) {
                streamingItems = new Vector.<DynamicStreamingItem>();

                var i:int = 0;

                for each(var props:Object in clip.getCustomProperty("bitrates")) {
                    var bitrateItem:BitrateItem = new PropertyBinder(new BitrateItem()).copyProperties(props) as BitrateItem;

                    bitrateItem.index = i;
                    streamingItems.push(bitrateItem);
                    i++;
                }

                //set the DynamicStreamingItem to the clip to be reused later in the streamselector
                clip.setCustomProperty("dynamicStreamingItems", sort(streamingItems));
            } else {
                //we have a dynamicStreamingItems list configured in another plugin
                streamingItems = sort(clip.getCustomProperty("dynamicStreamingItems") as Vector.<DynamicStreamingItem>);
            }
            //_streamSelector = new StreamSelector(streamingItems, _player, _config);

            return streamingItems;


            //clip.setCustomProperty("streamSelector", _streamSelector);
        }
    }

}
