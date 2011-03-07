package org.flowplayer.playlist.ui
{
	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.view.AbstractSprite;
	import org.flowplayer.model.Clip;
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.Status;
	import org.flowplayer.model.PlayerEvent;
	
	import org.flowplayer.ui.buttons.ConfigurableWidget;
	import org.flowplayer.ui.controllers.AbstractWidgetController;
	import org.flowplayer.ui.buttons.WidgetDecorator;
	
	
	import flash.events.Event;
	
	import flash.display.DisplayObjectContainer;
	
	import org.flowplayer.playlist.config.SliderConfig;
	
	import fp.*;
	
	public class ScrollBarController extends AbstractWidgetController {
		
		public function ScrollBarController() {
			super();
		}
		
		override public function init(player:Flowplayer, controlbar:DisplayObjectContainer, defaultConfig:Object):ConfigurableWidget {
			super.init(player, controlbar, defaultConfig);
			//initializeVolume();		
			
			return _widget;
		}
		
		override public function get name():String {
			return "hscrollbar";
		}
		
		override public function get defaults():Object {
			return {
				tooltipEnabled: true,
				visible: true,
				enabled: true
			};
		}
		
		/*public function initializeVolume():void {
			var volume:Number = _player.volume;
			log.info("initializing volume to " + volume);
			(_widget as VolumeSlider).value = volume;
		}*/
		
		override protected function createWidget():void {
			_widget = new ScrollBarSlider(_config as SliderConfig, _player, _controlbar);
		}
		
		
		override protected function createDecorator():void {
			_decoratedView = new WidgetDecorator(new fp.ScrollBarTopEdge(),
				new fp.ScrollBarRightEdge(),
				new fp.ScrollBarBottomEdge(),
				new fp.ScrollBarLeftEdge()).init(_widget);
		}
		
		
		override protected function initWidget():void {
			//_widget.addEventListener(VolumeSlider.DRAG_EVENT, onVolumeChanged);
			//initializeVolume();
		}
		
		/*
		override protected function addPlayerListeners():void {
			_player.onVolume(onPlayerVolumeEvent);
		}*/
		
		/*
		private function onPlayerVolumeEvent(event:PlayerEvent):void {
			(_widget as VolumeSlider).value = event.info as Number
		}*/
		
		/*
		private function onVolumeChanged(event:Event):void {
			_player.volume = VolumeSlider(event.target).value;
		}*/
		
		// TODO: check this guy
		public function set tooltipTextFunc(tooltipTextFunc:Function):void {
			//(_widget as VolumeSlider).tooltipTextFunc = tooltipTextFunc;
		}
		
	}
}