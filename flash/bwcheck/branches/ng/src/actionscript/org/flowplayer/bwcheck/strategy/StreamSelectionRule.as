package org.flowplayer.bwcheck.strategy {
    import org.flowplayer.util.Log;
    import org.osmf.net.SwitchingRuleBase;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.bwcheck.strategy.StreamSelection;
    import org.osmf.net.rtmpstreaming.RTMPNetStreamMetrics;
    import org.osmf.net.rtmpstreaming.RTMPNetStreamMetrics;

    public class StreamSelectionRule extends SwitchingRuleBase {
        private var _factory:StreamSelection;
        private var _player:Flowplayer;
        private var log:Log = new Log(this);

        public function StreamSelectionRule(metrics:RTMPNetStreamMetrics, factory:StreamSelection, player:Flowplayer) {
            super(metrics);
            _factory = factory;
            _player = player;
        }

        override public function getNewIndex():int {
            log.debug("metrics, average max bytes per second: ", RTMPNetStreamMetrics(metrics).averageMaxBytesPerSecond);
            var bw:Number = RTMPNetStreamMetrics(metrics).averageMaxBytesPerSecond * 8 / 1024;
            if (bw > 0) {
                var index:int = _factory.getStreamIndex(bw, _player);
                log.debug("new index is " + index);
                return index;
            }
            log.debug("returning current index " + metrics.currentIndex);
            return metrics.currentIndex;
        }

        private function get rtmpMetrics():RTMPNetStreamMetrics {
            return metrics as RTMPNetStreamMetrics;
        }

    }
}