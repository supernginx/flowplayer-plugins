package org.flowplayer.bwcheck.detect {
import org.flowplayer.bwcheck.config.Config;

import org.flowplayer.util.Log;
import org.flowplayer.view.Flowplayer;

import org.osmf.net.DynamicStreamingItem;
import org.osmf.net.SwitchingRuleBase;
import org.osmf.net.rtmpstreaming.RTMPNetStreamMetrics;
import org.osmf.net.NetStreamMetricsBase;

public class ScreenSizeRule extends SwitchingRuleBase {
    private var _player:Flowplayer;
    private var log:Log = new Log(this);
    private var _bitrates:Vector.<DynamicStreamingItem>;
    private var _config:Config;

    public function ScreenSizeRule(metrics:NetStreamMetricsBase, selector:StreamSelector, player:Flowplayer, config:Config) {
        super(metrics);
        _bitrates = selector.bitrates;
        _player = player;
        _config = config;
    }

    override public function getNewIndex():int {
        var screenWidth:Number = _player.screen.getDisplayObject().width;

        for (var i:Number = _bitrates.length - 1; i >= 0; i--) {
            var item:DynamicStreamingItem = _bitrates[i];

            log.debug("candidate '" + item.streamName + "' has width " + item.width);

            var fitsScreen:Boolean = StreamSelector.fitsScreen(item, _player, _config);
            log.info("fits screen? " + fitsScreen);

            if (fitsScreen) {
                log.debug("selecting bitrate with width " + item.width + ", index " + i);
                return i;
                break;
            }
        }
        return -1;
    }

    private function get rtmpMetrics():RTMPNetStreamMetrics {
        return metrics as RTMPNetStreamMetrics;
    }

}
}