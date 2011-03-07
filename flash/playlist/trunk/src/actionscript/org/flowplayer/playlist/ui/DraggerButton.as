package org.flowplayer.playlist.ui
{

	import org.flowplayer.ui.buttons.AbstractButton;
	import org.flowplayer.ui.buttons.ButtonEvent;
	import org.flowplayer.view.Flowplayer;
	import flash.display.DisplayObjectContainer;
	import org.flowplayer.view.AnimationEngine;
	import org.flowplayer.ui.buttons.TooltipButtonConfig;
		
	
	import fp.*;
	
	public class DraggerButton extends AbstractButton {
		
		public function DraggerButton(config:TooltipButtonConfig, animationEngine:AnimationEngine) {
			super(config, animationEngine);
		}
		
		/*override public function get name():String {
			return "scrollbar-up";
		}*/
		
		override protected function createFace():DisplayObjectContainer {
			return new ScrollBarHThumbButton();
		}
		
	}
	
	
}