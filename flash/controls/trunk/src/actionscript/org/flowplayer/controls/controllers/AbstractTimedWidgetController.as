/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.controls.controllers {
    
	import org.flowplayer.model.Status;
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.view.Flowplayer;
	
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.DisplayObjectContainer;

	public class AbstractTimedWidgetController extends AbstractWidgetController {

		protected var _timeUpdateTimer:Timer;
		
		public function AbstractTimedWidgetController(config:Object, player:Flowplayer, controlbar:DisplayObjectContainer) {
			super(config, player, controlbar);
			createUpdateTimer();
		}
		
		protected function createUpdateTimer():void {
			_timeUpdateTimer = new Timer(100);
			_timeUpdateTimer.addEventListener(TimerEvent.TIMER, onTimeUpdate);
		}

		protected function startUpdateTimer():void {
			_timeUpdateTimer.start();
			onTimeUpdate(null);
		}

		protected function stopUpdateTimer():void {
			_timeUpdateTimer.stop();
			onTimeUpdate(null);
		}

		protected function getPlayerStatus():Status {
            try {
                return _player.status;
            } catch (e:Error) {
                log.error("error querying player status, will stop query timer, error message: " + e.message);
                stopUpdateTimer();
                throw e;
            }
            return null;
       	}
	
		override protected function onPlayStarted(event:ClipEvent):void {
			super.onPlayStarted(event);
			startUpdateTimer();
		}

		override protected function onPlayPaused(event:ClipEvent):void {
			super.onPlayPaused(event);
			stopUpdateTimer();
		}

		override protected function onPlayResumed(event:ClipEvent):void {
			super.onPlayResumed(event);
			startUpdateTimer();
		}

		override protected function onPlayStopped(event:ClipEvent):void {
			super.onPlayStopped(event);
			stopUpdateTimer();
		}

		// override this when you need to get updated
		protected function onTimeUpdate(event:TimerEvent):void {
			
		}
		
	}
}

