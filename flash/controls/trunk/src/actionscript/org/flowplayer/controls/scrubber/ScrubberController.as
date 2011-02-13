/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.controls.scrubber {
    
	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.view.AbstractSprite;
	import org.flowplayer.model.Clip;
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.Status;
	
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;

	import org.flowplayer.util.Log;
	import flash.display.DisplayObjectContainer;
	
	import org.flowplayer.ui.buttons.WidgetDecorator;
	
	import org.flowplayer.controls.Controlbar;
	import org.flowplayer.controls.SkinClasses;
	import org.flowplayer.controls.time.TimeUtil;
	import org.flowplayer.controls.controllers.AbstractTimedWidgetController;

	public class ScrubberController extends AbstractTimedWidgetController {

		public function ScrubberController() {
			super();
		}
	
		override public function get name():String {
			return "scrubber";
		}
	
		override public function get defaults():Object {
			return {
				tooltipEnabled: true,
				visible: true,
				enabled: true
			};
		}
	
		override protected function createWidget():void {
			log.debug("Creating scrubber with ", _config)
			_widget = new ScrubberSlider(_config as ScrubberConfig, _player, _controlbar);
        }

		override protected function createDecorator():void {
			_decoratedView = new WidgetDecorator(SkinClasses.getDisplayObject("fp.ScrubberTopEdge"),
										 	 	 SkinClasses.getDisplayObject("fp.ScrubberRightEdge"),
												 SkinClasses.getDisplayObject("fp.ScrubberBottomEdge"),
												 SkinClasses.getDisplayObject("fp.ScrubberLeftEdge"), true).init(_widget);
		}

		override protected function onTimeUpdate(event:TimerEvent):void {
            var status:Status = getPlayerStatus();
            if (! status) return;

            var duration:Number = status.clip ? status.clip.duration : 0;
			var scrubber:ScrubberSlider = (_widget as ScrubberSlider);
			if (duration > 0) {
				scrubber.value = (status.time / duration) * 100;
				scrubber.setBufferRange(status.bufferStart / duration, status.bufferEnd / duration);
				scrubber.allowRandomSeek = status.allowRandomSeek;
			} else {
				scrubber.value = 0;
				scrubber.setBufferRange(0, 0);
				scrubber.allowRandomSeek = false;
			}
			if (status.clip) {
				scrubber.tooltipTextFunc = function(percentage:Number):String {
					if (duration == 0) return null;
					if (percentage < 0) {
						percentage = 0;
					}
					if (percentage > 100) {
						percentage = 100;
					}
					return TimeUtil.formatSeconds(percentage / 100 * duration);
				};
			}
        }

		override protected function onPlayStarted(event:ClipEvent):void {
			super.onPlayStarted(event);
			if (_player.status.time < 0.5) {
				enableScrubber(true);
			}
		}

		
		override protected function onPlayPaused(event:ClipEvent):void {
			super.onPlayPaused(event);
			log.info("received " + event);
			var clip:Clip = event.target as Clip;
			log.info("clip.seekableOnBegin: " + clip.seekableOnBegin);
			if (_player.status.time == 0 && ! clip.seekableOnBegin) {
				enableScrubber(false);
			}
        }

        override protected function onPlayResumed(event:ClipEvent):void {
			super.onPlayResumed(event);
			if (_player.status.time < 0.5) {
				enableScrubber(true);
			}
        }


		private function enableScrubber(enabled:Boolean):void {
			if (!_widget) return;
		
			_widget.enabled = enabled;

		//	log.error("Enabling scrubber :", enabled);

			if (enabled) {
				_widget.addEventListener(ScrubberSlider.DRAG_EVENT, onScrubbed);
			} else {
				_widget.removeEventListener(ScrubberSlider.DRAG_EVENT, onScrubbed);
			}
		}
		

		private function onScrubbed(event:Event):void {
			_player.seekRelative(ScrubberSlider(event.target).value);
		}


	}
}

