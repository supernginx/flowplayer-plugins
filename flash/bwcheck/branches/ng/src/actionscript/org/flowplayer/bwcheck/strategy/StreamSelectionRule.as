package org.flowplayer.bwcheck.strategy
{

	import org.osmf.net.SwitchingRuleBase;
	import org.flowplayer.view.Flowplayer;
	
	public class StreamSelectionRule extends SwitchingRuleBase
	{
		/**
		 * Constructor.
		 * 
		 * @param metrics The metrics provider used by this rule to determine
		 * whether to switch.
		 * @param minBufferLength The minimum buffer length that must be
		 * maintained before the rule suggests a switch down.  The default
		 * value is 2 seconds.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		
		private _factory:StreamSelection;
		private _player:Flowplayer;
		
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
			return _factory.getStreamIndex(metrics.resource.streamItems[metrics.currentIndex].bitrate, metrics.resource.streamItems, _player);
		}
		
		
		
		private function get rtmpMetrics():RTMPNetStreamMetrics
		{
			return metrics as RTMPNetStreamMetrics;
		}
		
	}
}