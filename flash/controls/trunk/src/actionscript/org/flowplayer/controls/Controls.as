/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 * Copyright (c) 2008 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls {
	import org.flowplayer.model.PluginEventType;	
	import org.flowplayer.controls.button.AbstractButton;	import org.flowplayer.controls.button.AbstractToggleButton;	import org.flowplayer.controls.button.ButtonEvent;	import org.flowplayer.controls.button.NextButton;	import org.flowplayer.controls.button.PrevButton;	import org.flowplayer.controls.button.StopButton;	import org.flowplayer.controls.button.ToggleFullScreenButton;	import org.flowplayer.controls.button.TogglePlayButton;	import org.flowplayer.controls.button.ToggleVolumeMuteButton;	import org.flowplayer.controls.slider.AbstractSlider;	import org.flowplayer.controls.slider.Scrubber;	import org.flowplayer.controls.slider.VolumeSlider;	import org.flowplayer.model.Clip;	import org.flowplayer.model.ClipEvent;	import org.flowplayer.model.PlayerEvent;	import org.flowplayer.model.PlayerEventType;	import org.flowplayer.model.Playlist;	import org.flowplayer.model.Plugin;	import org.flowplayer.model.PluginModel;	import org.flowplayer.model.Status;	import org.flowplayer.util.Arrange;	import org.flowplayer.util.PropertyBinder;	import org.flowplayer.view.AbstractSprite;	import org.flowplayer.view.Flowplayer;	import org.flowplayer.view.StyleableSprite;		import flash.display.DisplayObject;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.events.TimerEvent;	import flash.utils.Timer;			/**
	 * @author anssi
	 */
	public class Controls extends StyleableSprite implements Plugin {

		private static const DEFAULT_HEIGHT:Number = 28;

		private var _playButton:AbstractToggleButton;
		private var _fullScreenButton:AbstractToggleButton;
		private var _muteVolumeButton:AbstractToggleButton;
		private var _volumeSlider:VolumeSlider;
		private var _progressTracker:DisplayObject;
		private var _prevButton:DisplayObject;
		private var _nextButton:DisplayObject;
		private var _stopButton:DisplayObject;
		private var _scrubber:Scrubber;
		private var _timeView:TimeView;

		private var _margins:Array = [2, 6, 2, 6];
		private var _config:Config;
		private var _timeUpdateTimer:Timer;
		private var _floating:Boolean = false;
		private var _controlBarMover:ControlsAutoHide;
		private var _immediatePositioning:Boolean = true;
		private var _animationTimer:Timer;
		private var _player:Flowplayer;
		private var _pluginModel:PluginModel;
		private var _initialized:Boolean;

		public function Controls() {
			log.debug("creating ControlBar");
			this.visible = false;
			height = DEFAULT_HEIGHT;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		

		/**
		 * Enables and disabled buttons and other widgets.
		 * @param enabledWidgets the buttons visibilies, for example { all: true, volume: false, time: false }		 */		
		[External]
		public function enable(enabledWidgets:Object):void {
			log.debug("enable()");
			if (_animationTimer && _animationTimer.running) return;
			if (enabledWidgets.hasOwnProperty("all")) {
				_config.resetVisibilities();
			}
			new PropertyBinder(_config).copyProperties(enabledWidgets);
			immediatePositioning = false;
			createChildren();
			onResize();
			immediatePositioning = true;
		}
		
		private function set immediatePositioning(enable:Boolean):void {
			_immediatePositioning = enable;
			if (! enable) return;
			_animationTimer = new Timer(500, 1);
			_animationTimer.start();
		}

		/**
		 * @inheritDoc
		 */
		override public function css(styleProps:Object = null):Object {
			var result:Object = super.css(styleProps);
			redraw(styleProps);
			return _config.style.addStyleProps(result);
		}
		

		/**
		 * @inheritDoc
		 */
		override public function animate(styleProps:Object):Object {
			var result:Object = super.animate(styleProps);
			return _config.style.addStyleProps(result);
		}
		
		/**
		 * Rearranges the buttons when size changes.
		 */
		override protected function onResize():void {
			if (! _initialized) return;
			log.debug("arranging, width is " + width);
			var leftEdge:Number = arrangeLeftEdgeControls();
			arrangeRightEdgeControls(leftEdge);		
			initializeVolume();
			log.debug("arranged to x " + this.x + ", y " + this.y);
		}

		/**
		 * Makes this visible when the superclass has been drawn.
		 */
		override protected function onRedraw():void {
			log.debug("onRedraw, making controls visible");
			this.visible = true;
		}
		
		/**
		 * Default properties for the controls.
		 */		
		public function getDefaultConfig():Object {
			return { bottom: 0, left: 0, height: 24, width: "100%", zIndex: 2, 
					backgroundColor: "#25353C", 
					backgroundGradient: [.6, 0.3, 0, 0, 0], 
					border: "0px", borderRadius: "0px", 
					timeColor: "#01DAFF",
					durationColor: "#ffffff", 
					sliderColor: "#000000",
					sliderGradient: "none", 
					buttonColor: "#5F747C",
					buttonOverColor: "#728B94", 
					progressColor: "#015B7A",
					progressGradient: "medium", 
					bufferColor: "#6c9cbc",
					bufferGradient: "none" };
		}
		
		private function redraw(styleProps:Object):void {
			_config.addStyleProps(styleProps);
			if (_scrubber) {
				_scrubber.redraw(_config);
			}
			if (_volumeSlider) {
				_volumeSlider.redraw(_config);
			}
			if (_timeView) {
				_timeView.redraw(_config);
			}
			for (var j:int = 0; j < numChildren; j++) {
				var child:DisplayObject = getChildAt(j);
				if (child is AbstractButton) {
					AbstractButton(child).redraw(_config);
				}
			}
		}
		private function onAddedToStage(event:Event):void {
			log.debug("addedToStage, config is " + _config);
			if (_config.autoHide != 'never' && ! _controlBarMover) {
				_controlBarMover = new ControlsAutoHide(_config, _player, stage, this);
			}
		}

		public function onLoad(player:Flowplayer):void {
			log.info("received player API! autohide == " + _config.autoHide);
			loader = player.createLoader();
			_player = player;
			createTimeView();
			addListeners(player.playlist);
			if (_scrubber) {
				_scrubber.playlist = player.playlist;
			}
			enableFullscreenButton(player.playlist.current);
			log.debug("setting root style to " + _config.style.bgStyle);
			rootStyle = _config.style.bgStyle;
			if (_scrubber) {
				_scrubber.animationEngine = player.animationEngine;
			}
			if (_muteVolumeButton) {
				_muteVolumeButton.down = player.muted;
			}
			_pluginModel.dispatchOnLoad();
		}
		public function onConfig(model:PluginModel):void {
			log.info("received my plugin config ", model.config);
			_pluginModel = model;
			log.debug("-");
			_config = createConfig(model);
			log.debug("config created");
			// set style properties to superclass, the properties can be given in the top level of config
			createChildren();
		}
		
		private function createConfig(plugin:PluginModel):Config {
			var config:Config = new PropertyBinder(new Config()).copyProperties(plugin.config) as Config;
			config.addStyleProps(plugin.config);
			return config;
		}
		
		public function set floating(float:Boolean):void {
			_floating = float;
		}

		private function createChildren():void {
			log.debug("creating fullscren ", _config );
			_fullScreenButton = addChildWidget(createWidget(_fullScreenButton, _config.fullscreen, ToggleFullScreenButton, _config)) as AbstractToggleButton;
			log.debug("creating play");
			_playButton = addChildWidget(createWidget(_playButton, _config.play, TogglePlayButton, _config), ButtonEvent.CLICK, onPlayClicked) as AbstractToggleButton;
			log.debug("creating stop");
			_stopButton = addChildWidget(createWidget(_stopButton, _config.stop, StopButton, _config), MouseEvent.CLICK, onStopClicked);
			_nextButton = addChildWidget(createWidget(_nextButton, _config.playlist, NextButton, _config), MouseEvent.CLICK, "next");
			_prevButton = addChildWidget(createWidget(_prevButton, _config.playlist, PrevButton, _config), MouseEvent.CLICK, "previous");
			_muteVolumeButton = addChildWidget(createWidget(_muteVolumeButton, _config.mute, ToggleVolumeMuteButton, _config), ButtonEvent.CLICK, onMuteVolumeClicked) as AbstractToggleButton;
			_volumeSlider = addChildWidget(createWidget(_volumeSlider, _config.volume, VolumeSlider, _config), VolumeSlider.DRAG_EVENT, onVolumeSlider, 1) as VolumeSlider;
			_scrubber = addChildWidget(createWidget(_scrubber, _config.scrubber, Scrubber, _config), Scrubber.DRAG_EVENT, onScrubbed, 1) as Scrubber;
			createTimeView();
			createScrubberUpdateTimer();
			log.debug("created all buttons");
			_initialized = true;
		}
		
		private function createTimeView():void {
			if (! _player) return;
			if (_config.time) {
				if (_timeView) return;
				_timeView = addChildWidget(new TimeView(_config, _player), TimeView.EVENT_REARRANGE, onTimeViewRearranged, 1) as TimeView;
				_timeView.visible = false;
			} else if (_timeView) {
				removeChildAnimate(_timeView);
				_timeView = null;
			}
		}

		private function onTimeViewRearranged(event:Event):void {
			onResize();
		}

		private function createWidget(existing:DisplayObject, doAdd:Boolean, Widget:Class, constructorArg:Object):DisplayObject {
			if (!doAdd) {
				log.debug("not showing widget " + Widget);
				if (existing) {
					removeChildAnimate(existing);
				}
				return null;
			}
			if (existing) return existing;
			log.debug("creating " + Widget);
			var widget:DisplayObject = constructorArg ? new Widget(constructorArg) : new Widget();
			widget.visible = false;
			return widget;
		}

		private function removeChildAnimate(child:DisplayObject):DisplayObject {
			if (! _player || _immediatePositioning) {
				removeChild(child);
				return child;
			}
			_player.animationEngine.fadeOut(child, 1000, function():void { removeChild(child); 
			});
			return child;
		}

		private function addChildWidget(widget:DisplayObject, eventType:String = null, listener:Object = null, alpha:Number = 1):DisplayObject {
			if (!widget) return null;
			widget.alpha = alpha;
			addChild(widget as DisplayObject);
			if (eventType) {
				widget.addEventListener(eventType, listener is Function ? listener as Function : function():void { _player[listener](); });
			}
			log.debug("created control bar child widget  " + widget);
			return widget;
		}
		
		private function createScrubberUpdateTimer():void {
			_timeUpdateTimer = new Timer(500);
			_timeUpdateTimer.addEventListener(TimerEvent.TIMER, onTimeUpdate);
			_timeUpdateTimer.start();
		}
		
		private function initializeVolume():void {
			if (!_volumeSlider) return;
			var volume:Number = _player.volume;
			log.info("initializing volume to " + volume);
			_volumeSlider.value = volume;
		}

		private function onTimeUpdate(event:TimerEvent):void {
			if (! (_scrubber || _timeView)) return;
			if (! _player) return;
			var status:Status = getPlayerStatus();
			if (! status) return;
			var duration:Number = status.clip ? status.clip.duration : 0;
//			log.debug("duration " + duration + ", bufferStart " + status.bufferStart + ", bufferEnd " + status.bufferEnd + ", clip " + status.clip);
			if (_scrubber) {
				if (duration > 0) { 
					_scrubber.value = (status.time / duration) * 100;
					_scrubber.setBufferRange(status.bufferStart / duration, status.bufferEnd / duration);
					_scrubber.allowRandomSeek = status.allowRandomSeek;
				} else {
					_scrubber.value = 0;
					_scrubber.setBufferRange(0, 0);
					_scrubber.allowRandomSeek = false;
				}
			}
			if (_timeView) {
				_timeView.duration = status.clip.live ? -1 : duration;
				_timeView.time = status.time;
			}
		}
		
		private function getPlayerStatus():Status {
			try {
				return _player.status;
			} catch (e:Error) {
				log.error("error querying player status, will stop query timer, error message: " + e.message);
				_timeUpdateTimer.stop();
				throw e;
			}
			return null;
		}

		private function addListeners(playlist:Playlist):void {
			playlist.onConnect(onPlayStarted);
			playlist.onBeforeBegin(onPlayStarted);
			playlist.onPause(onPlayPaused);
			playlist.onResume(onPlayResumed);
			playlist.onStop(onPlayStopped);
			playlist.onBufferStop(onPlayStopped);
			playlist.onFinish(onPlayStopped);
			_player.onFullscreen(onPlayerFullscreenEvent);
			_player.onFullscreenExit(onPlayerFullscreenEvent);
			_player.onMute(onPlayerMuteEvent);
			_player.onUnmute(onPlayerMuteEvent);
			_player.onVolume(onPlayerVolumeEvent);
		}
				
		private function onPlayerVolumeEvent(event:PlayerEvent):void {
			if (! _volumeSlider) return;
			_volumeSlider.value = event.info as Number;
		}

		private function onPlayerMuteEvent(event:PlayerEvent):void {
			log.info("onPlayerMuteEvent, _muteButton " + _muteVolumeButton);
			if (! _muteVolumeButton) return;
			_muteVolumeButton.down = event.eventType == PlayerEventType.MUTE;
		}

		private function onPlayStarted(event:ClipEvent):void {
			log.debug("received " + event);
			if (_playButton) {
				_playButton.down = ! event.isDefaultPrevented();
			}
			if (_fullScreenButton) {
				enableFullscreenButton(event.target as Clip);
			}
		}
		
		private function enableFullscreenButton(clip:Clip):void {
			if (!_fullScreenButton) return;
			var enabled:Boolean = clip && (clip.originalWidth > 0 || ! clip.accelerated);
			_fullScreenButton.enabled = enabled;
			if (enabled) {
				_fullScreenButton.addEventListener(MouseEvent.CLICK, toggleFullscreen);
			} else {
				_fullScreenButton.removeEventListener(MouseEvent.CLICK, toggleFullscreen);
			}
		}
		
		private function toggleFullscreen(event:MouseEvent):void  {
			_player.toggleFullscreen();
		}

		private function onMetaData(event:ClipEvent):void {
			if (!_fullScreenButton) return;
			enableFullscreenButton(event.target as Clip);
		}

		private function onPlayPaused(event:ClipEvent):void {
			log.info("received " + event);
			if (!_playButton) return;
			_playButton.down = false;
		}

		private function onPlayStopped(event:ClipEvent):void {
			log.debug("received " + event);
			if (!_playButton) return;
			log.debug("setting playButton to up state");
			_playButton.down = false;
		}

		private function onPlayResumed(event:ClipEvent):void {
			log.info("received " + event);
			if (!_playButton) return;
			_playButton.down = true;
		}
		
		private function onPlayerFullscreenEvent(event:PlayerEvent):void {
			log.debug("onPlayerFullscreenEvent");
			if (!_fullScreenButton) return;
			_fullScreenButton.down = event.eventType == PlayerEventType.FULLSCREEN;
		}

		private function onPlayClicked(event:ButtonEvent):void {
			_player.toggle();
		}
		private function onStopClicked(event:MouseEvent):void {
			_player.stop();
		}

		private function onMuteVolumeClicked(event:ButtonEvent):void {
			_player.muted = ! _player.muted;
		}

		private function onVolumeSlider(event:Event):void {
			log.debug("volume slider changed to pos " + VolumeSlider(event.target).value);
			_player.volume = VolumeSlider(event.target).value;
		}
		
		private function onScrubbed(event:Event):void {
			_player.seekRelative(Scrubber(event.target).value);
		}

		private function arrangeLeftEdgeControls():Number {
			var leftEdge:Number = _margins[3];
			var leftControls:Array = [_stopButton, _playButton, _prevButton, _nextButton];
			leftEdge = arrangeControls(leftEdge, leftControls, arrangeToLeftEdge);
			return leftEdge;
		}

		private function arrangeRightEdgeControls(leftEdge:Number):void {
			var edge:Number =  _config.scrubber ? (width - _margins[1]) : leftEdge;
			var rightControls:Array;

			// set volume slider width first so that we know how to arrange the other controls
			if (_volumeSlider) {
				_volumeSlider.width = 40;
			}
			if (_config.scrubber) {
				// arrange from right to left (scrubber takes the remaining space)
				rightControls = [_fullScreenButton, _volumeSlider, _muteVolumeButton, _timeView];
				edge = arrangeControls(edge, rightControls, arrangeToRightEdge);
				edge = arrangeScrubber(leftEdge, edge);
			} else {
				// no scrubber --> stack from left to right
				rightControls = [_timeView, _muteVolumeButton, _volumeSlider, _fullScreenButton];
				edge = arrangeControls(edge, rightControls, arrangeToLeftEdge);
			}

			arrangeVolumeControl();
			arrangeMuteVolumeButton();
		}
		
		private function arrangeControls(edge:Number, controls:Array, arrangeFunc:Function):Number {
			for (var i:Number = 0; i < controls.length; i++) {
				if (controls[i]) {
					var control:DisplayObject = controls[i] as DisplayObject;
					arrangeYCentered(control);
					edge = arrangeFunc(edge, getSpaceAfterWidget(control), control);
				}
			}
			return edge;
		}

		private function arrangeVolumeControl():void {
			if (! _config.volume) return;
			_volumeSlider.height = height/3;
			_volumeSlider.y = height/2 - height/6;;
//			Arrange.center(_volumeSlider, 0, height);
		}

		private function arrangeMuteVolumeButton():void {
			if (! _config.mute) return;
			Arrange.center(_muteVolumeButton, 0, height);
			return;
		}
		
		private function arrangeScrubber(leftEdge:Number, rightEdge:Number):Number {
			if (! _config.scrubber) return rightEdge;
			arrangeX(_scrubber, leftEdge);
			var scrubberWidth:Number = rightEdge - leftEdge - 2 * getSpaceAfterWidget(_scrubber); 
			if (! _player || _immediatePositioning) { 
				_scrubber.width = scrubberWidth;
			} else {
				_player.animationEngine.animateProperty(_scrubber, "width", scrubberWidth);
			}
			_scrubber.height = height/3;
			Arrange.center(_scrubber, 0, height);
			return rightEdge - getSpaceAfterWidget(_scrubber) - scrubberWidth;
		}
	
		private function arrangeToRightEdge(rightEdgePos:Number, spaceBetweenClips:Number, clip:DisplayObject):Number {
			if (! clip) return rightEdgePos;
			rightEdgePos = rightEdgePos - clip.width - spaceBetweenClips;
			arrangeX(clip, rightEdgePos);
			return rightEdgePos;
		}
		
		private function arrangeX(clip:DisplayObject, pos:Number):void {
			clip.visible = true;
			if (! _player || _immediatePositioning) {
				clip.x = pos;
				return;
			}
			if (clip.x == 0) {
				// we are arranging a newly created widget, fade it in
				clip.x = pos;
				fadeIn(clip);
			}
			// rearrange a previously arrange widget
			_player.animationEngine.animateProperty(clip, "x", pos);
		}
		
		private function fadeIn(clip:DisplayObject):void {
			var currentAlpha:Number = clip.alpha;
			clip.alpha = 0;
			_player.animationEngine.animateProperty(clip, "alpha", currentAlpha);
		}

		private function arrangeToLeftEdge(leftEdgePos:Number, spaceBetween:Number, clip:DisplayObject):int {
			if (! clip) return leftEdgePos;
			arrangeX(clip, leftEdgePos);
			return leftEdgePos + clip.width + spaceBetween;
		}
		
		private function arrangeYCentered(clip:DisplayObject):void {
			clip.y = _margins[0];
			clip.height = getHeight(clip);
			clip.scaleX = clip.scaleY;
			Arrange.center(clip, 0, height);
		}
	
		private function getSpaceAfterWidget(widget:DisplayObject):int {
			var space:int = 4;
			
			if (widget == lastOnRight)
				space = 0;
			else if (widget == _volumeSlider)
				space = 8;
			else if (widget == _progressTracker)
				space = 8;
			else if (widget == _timeView)
				space = 8;
			return space;
		}
		
		private function get lastOnRight():DisplayObject {
			if (_fullScreenButton) return _fullScreenButton;
			if (_volumeSlider) return _volumeSlider;
			if (_muteVolumeButton) return _muteVolumeButton;
			if (_timeView) return _timeView;
			return null;
		}

		private function getHeight(widget:DisplayObject):int {
			if (widget == _timeView)
				return height/1.7;
			if (widget == _muteVolumeButton)
				return height/3;
			if (widget == _fullScreenButton)
				return height - _margins[0] - _margins[2] - height/6;
			return height - _margins[0] - _margins[2];
		}
	}
}
