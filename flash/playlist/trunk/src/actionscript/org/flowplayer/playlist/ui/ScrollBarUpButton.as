package org.flowplayer.playlist.ui
{
	import org.flowplayer.controls.Controlbar;
	import org.flowplayer.controls.SkinClasses;
	
	import org.flowplayer.ui.controllers.AbstractButtonController;
	import org.flowplayer.ui.buttons.ButtonEvent;
	import org.flowplayer.view.Flowplayer;
	import flash.display.DisplayObjectContainer;
	
	public class ScrollBarUpButton extends AbstractButtonController {
		
		public function ScrollBarUpButton() {
			super();
		}
		
		override public function get name():String {
			return "scrollbar-up";
		}
		
		override public function get defaults():Object {
			return {
				tooltipEnabled: false,
				tooltipLabel: "Up",
				visible: false,
				enabled: true
			};
		}
		
		override protected function get faceClass():Class {
			return SkinClasses.getClass("fp.StopButton");
		}
		
		override protected function onButtonClicked(event:ButtonEvent):void {
			
		}
	}
	
	
}