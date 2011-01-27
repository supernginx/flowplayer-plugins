/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.controls.volume {
    
	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.view.AbstractSprite;
	import org.flowplayer.model.Clip;
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.Status;
	import org.flowplayer.model.PlayerEvent;
	
	import org.flowplayer.controls.buttons.SurroundedWidget;
	import org.flowplayer.controls.Controlbar;
	import org.flowplayer.controls.SkinClasses;
	
	import flash.events.Event;
	
	import flash.display.DisplayObjectContainer;
	
	import org.flowplayer.controls.controllers.AbstractWidgetController;

	import org.flowplayer.controls.buttons.SliderConfig;

	public class VolumeController extends AbstractWidgetController {

		public static const NAME:String = "volume";
		public static const DEFAULTS:Object = {
			tooltipEnabled: true,
			visible: true,
			enabled: true
		};
		
		public function VolumeController(config:SliderConfig, player:Flowplayer, controlbar:Controlbar) {
			super(config, player, controlbar);
			initializeVolume();		
		}
	
		public function initializeVolume():void {
			var volume:Number = _player.volume;
            log.info("initializing volume to " + volume);
            ((_widget as SurroundedWidget).widget as VolumeSlider).value = volume;
		}
		
		override protected function createWidget():void {
			_widget = new SurroundedWidget(	new VolumeSlider(_config as SliderConfig, _player, _controlbar),
											SkinClasses.getDisplayObject("fp.VolumeTopEdge"),
											SkinClasses.getDisplayObject("fp.VolumeRightEdge"),
											SkinClasses.getDisplayObject("fp.VolumeBottomEdge"),
											SkinClasses.getDisplayObject("fp.VolumeLeftEdge"));
        }

		override protected function initWidget():void {
			_widget.addEventListener(VolumeSlider.DRAG_EVENT, onVolumeChanged);
			initializeVolume();
		}

		override protected function addPlayerListeners():void {
			_player.onVolume(onPlayerVolumeEvent);
		}
		
		private function onPlayerVolumeEvent(event:PlayerEvent):void {
			((_widget as SurroundedWidget).widget as VolumeSlider).value = event.info as Number
		}

		private function onVolumeChanged(event:Event):void {
			_player.volume = VolumeSlider(event.target).value;
		}
		
		// TODO: check this guy
		public function set tooltipTextFunc(tooltipTextFunc:Function):void {
            ((_widget as SurroundedWidget).widget as VolumeSlider).tooltipTextFunc = tooltipTextFunc;
        }

	}
}

