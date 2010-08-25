package org.flowplayer.bwcheck.strategy
{
    import org.flowplayer.util.Log;
    import org.osmf.net.DynamicStreamingItem;
    import org.osmf.net.SwitchingRuleBase;
	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.bwcheck.strategy.StreamSelection;
    import org.osmf.net.rtmpstreaming.RTMPNetStreamMetrics;
    import org.osmf.net.rtmpstreaming.RTMPNetStreamMetrics;

	public class ScreenSizeRule extends SwitchingRuleBase
	{
		private var _factory:StreamSelection;
		private var _player:Flowplayer;
        private var log:Log = new Log(this);

		public function ScreenSizeRule(metrics:RTMPNetStreamMetrics, factory:StreamSelection, player:Flowplayer)
		{
			super(metrics);
			_factory = factory;
			_player = player;
		}

		override public function getNewIndex():int {
            var screenWidth:Number = _player.screen.getDisplayObject().width;

            for (var i:Number = _factory.bitrates.length  - 1; i >= 0; i--) {
                var item:DynamicStreamingItem = _factory.bitrates[i];

                log.debug("candidate '" + item.streamName +  "' has width " + item.width);

                var fitsScreen:Boolean = ! item.width || screenWidth >= item.width;
                log.info("fits screen? " + fitsScreen);

                if (fitsScreen) {
                    log.debug("selecting bitrate with width " + item.width);
                    return i;
                    break;
                }
            }
            return -1;
		}

		private function get rtmpMetrics():RTMPNetStreamMetrics
		{
			return metrics as RTMPNetStreamMetrics;
		}

	}
}