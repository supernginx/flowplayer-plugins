/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.controls.time {
   
	import org.flowplayer.controls.controllers.AbstractTimedWidgetController;
	import org.flowplayer.controls.buttons.SurroundedWidget;
	import org.flowplayer.controls.SkinClasses;
	
	import org.flowplayer.view.Flowplayer;
	
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.Status;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.TimerEvent;

	public class TimeViewController extends AbstractTimedWidgetController {
		
		public static const NAME:String = "time";
		public static const DEFAULTS:Object = {
			visible: true
		};
		
		protected var _durationReached:Boolean = false;

		public function TimeViewController(config:TimeViewConfig, player:Flowplayer, controlbar:DisplayObjectContainer) {
			super(config, player, controlbar);
		}

		
		override protected function createWidget():void {			
			_widget = new SurroundedWidget(	new TimeView(_config as TimeViewConfig, _player),
											SkinClasses.getDisplayObject("fp.VolumeTopEdge"),
											SkinClasses.getDisplayObject("fp.VolumeRightEdge"),
											SkinClasses.getDisplayObject("fp.VolumeBottomEdge"),
											SkinClasses.getDisplayObject("fp.VolumeLeftEdge"));
			
        }
	/*
		override public function redraw(config:Object):void {
			_config = config as TimeViewConfig;
			if ( ! _widget ) {
				createWidget();
				initWidget();
			}
			(_widget as TimeView).redraw(_config as TimeViewConfig);
		}*/
	
		override protected function onTimeUpdate(event:TimerEvent):void {
			var status:Status = getPlayerStatus();
			if (! status) return;
			
			var duration:Number = status.clip ? status.clip.duration : 0;

			((_widget as SurroundedWidget).widget as TimeView).duration = status.clip.live && duration == 0 ? -1 : duration;
			((_widget as SurroundedWidget).widget as TimeView).time = _durationReached ? duration : status.time;
		}

		override protected function addPlayerListeners():void {
			super.addPlayerListeners();
			_player.playlist.onBeforeFinish(durationReached);
		}

		protected function durationReached(event:ClipEvent):void {
			_durationReached = true;
		}

		override protected function onPlayStarted(event:ClipEvent):void {
			super.onPlayStarted(event);
			_durationReached = false;
		}
	}
}

