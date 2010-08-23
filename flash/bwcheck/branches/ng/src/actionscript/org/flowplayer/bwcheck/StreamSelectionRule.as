package org.flowplayer.bwcheck
{
    import org.flowplayer.util.Log;
    import org.osmf.net.SwitchingRuleBase;
	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.bwcheck.strategy.StreamSelection;
    import org.osmf.net.rtmpstreaming.RTMPNetStreamMetrics;
    import org.osmf.net.rtmpstreaming.RTMPNetStreamMetrics;

	public class StreamSelectionRule extends SwitchingRuleBase
	{
		private var _factory:StreamSelection;
		private var _player:Flowplayer;
        private var log:Log = new Log(this);

		public function StreamSelectionRule(metrics:RTMPNetStreamMetrics, factory:StreamSelection, player:Flowplayer)
		{
			super(metrics);
			_factory = factory;
			_player = player;
		}

		/**
		 * @private
		 */
		override public function getNewIndex():int
		{
            log.debug("metrics", metrics);
            var bps:Number = RTMPNetStreamMetrics(metrics).averageMaxBytesPerSecond;

            return bps > 0 ? _factory.getStreamIndex(bps, _player) : _factory.getStreamIndex(metrics.resource.streamItems[metrics.currentIndex].bitrate, _player);
		}



		private function get rtmpMetrics():RTMPNetStreamMetrics
		{
			return metrics as RTMPNetStreamMetrics;
		}

	}
}