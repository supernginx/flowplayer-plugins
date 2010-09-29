/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *Copyright (c) 2008, 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls {
    import flash.display.DisplayObject;
	import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.system.ApplicationDomain;
    import flash.system.Security;
    import flash.utils.Timer;

    import org.flowplayer.controls.button.AbstractButton;
    import org.flowplayer.controls.button.AbstractToggleButton;
    import org.flowplayer.controls.button.ButtonEvent;
    import org.flowplayer.controls.button.NextButton;
    import org.flowplayer.controls.button.PrevButton;
    import org.flowplayer.controls.button.SkinClasses;
    import org.flowplayer.controls.button.SlowMotionBwdButton;
    import org.flowplayer.controls.button.SlowMotionFBwdButton;
    import org.flowplayer.controls.button.SlowMotionFFwdButton;
    import org.flowplayer.controls.button.SlowMotionFwdButton;
    import org.flowplayer.controls.button.StopButton;
    import org.flowplayer.controls.button.ToggleFullScreenButton;
    import org.flowplayer.controls.button.TogglePlayButton;
    import org.flowplayer.controls.button.ToggleVolumeMuteButton;
    import org.flowplayer.controls.config.Config;
    import org.flowplayer.controls.config.ToolTips;
    import org.flowplayer.controls.config.WidgetBooleanStates;
    import org.flowplayer.controls.slider.Scrubber;
    import org.flowplayer.controls.slider.ScrubberSlider;
    import org.flowplayer.controls.slider.VolumeScrubber;
    import org.flowplayer.controls.slider.VolumeSlider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.PlayerEvent;
    import org.flowplayer.model.PlayerEventType;
    import org.flowplayer.model.Playlist;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginEventDispatcher;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.model.Status;
    import org.flowplayer.ui.AutoHide;
    import org.flowplayer.ui.AutoHideConfig;
    import org.flowplayer.util.Arrange;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.AnimationEngine;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.StyleableSprite;

    /**
     * @author anssi
     */
    public class Controls extends StyleableSprite implements Plugin {

        private static const DEFAULT_HEIGHT:Number = 28;

        private var _playButton:AbstractToggleButton;
        private var _fullScreenButton:AbstractToggleButton;
        private var _muteVolumeButton:AbstractToggleButton;
        private var _volumeSlider:VolumeScrubber;
        private var _prevButton:DisplayObject;
        private var _nextButton:DisplayObject;
		private var _slowMotionFwdButton:DisplayObject;
        private var _slowMotionBwdButton:DisplayObject;
		private var _slowMotionFFwdButton:DisplayObject;
        private var _slowMotionFBwdButton:DisplayObject;
        private var _stopButton:DisplayObject;
        private var _scrubber:Scrubber;
        private var _timeView:TimeView;

        private var _widgetMaxHeight:Number = 0;
        private var _config:Config;
        private var _timeUpdateTimer:Timer;
        private var _floating:Boolean = false;
        private var _controlBarMover:AutoHide;
        private var _immediatePositioning:Boolean = true;
        private var _animationTimer:Timer;
        private var _player:Flowplayer;
        private var _pluginModel:PluginModel;
        private var _initialized:Boolean;
        private var _currentControlsConfig:Object;
        private var _originalConfig:Object;
		private var _durationReached:Boolean;
		
		// #71, need to have a filled sprite who takes all the space to get events to work
		private var _bgFill:Sprite;

        public function Controls() {
            log.debug("creating ControlBar");
            this.visible = false;

			_bgFill = new Sprite();
			addChild(_bgFill);
			
            height = DEFAULT_HEIGHT;
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        [External(convert="true")]
        public function get config():Config {
            return _config;
        }

        [External]
        public function setTooltips(props:Object):void {
            initTooltipConfig(_config, props);
            redraw(props);
        }

        [External(convert="true")]
        public function getTooltips():ToolTips {
            return _config.tooltips;
        }

        [External]
        public function setAutoHide(props:Object = null):void {
            log.debug("autoHide()");
            if (props) {
                new PropertyBinder(_config.autoHide).copyProperties(props);
            }
            _pluginModel.config.autoHide = _config.autoHide.state;

            if (_controlBarMover) 
                _controlBarMover.stop();


            createControlBarMover();
            _controlBarMover.start();
        }

        [External(convert="true")]
        public function getAutoHide():AutoHideConfig {
            return _config.autoHide;
        }

        /**
         * Makes buttons and other widgets visible/hidden.
         * @param visibleWidgets the buttons visibilies, for example { all: true, volume: false, time: false }
         */
        [External]
        public function setWidgets(visibleWidgets:Object = null):Object {
            log.debug("widgets()");
            if (! visibleWidgets) return _config.visible;

            if (_animationTimer && _animationTimer.running) return _config.visible;
            setConfigBooleanStates("visible", visibleWidgets);
            recreateWidgets();
            return _config.visible;
        }


        [External(convert="true")]
        public function getWidgets():WidgetBooleanStates {
            return _config.visible;
        }

        /*
         * This is here for backward compatibility. Lots of ad plugins use this.
         */
        [External]
        public function enable(enabledWidgets:Object):void {
            setEnabled(enabledWidgets);   
        }

        /**
         * Enables and disables buttons and other widgets.
         */
        [External]
        public function setEnabled(enabledWidgets:Object):void {
            log.debug("enable()");
            setConfigBooleanStates("enabled", enabledWidgets);
            enableWidgets();
            enableFullscreenButton(_player.playlist.current);
        }

        [External(convert="true")]
        public function getEnabled():WidgetBooleanStates {
            return _config.enabled;
        }

        private function recreateWidgets():void {
            immediatePositioning = false;
            createChildren();
            onResize();
            immediatePositioning = true;
        }

        private function enableWidgets():void {
            var index:int = 0;
            while (index < numChildren) {
                var child:DisplayObject = getChildAt(index);
                log.debug("enabledWidget " + child.name + ":");
                if (child.hasOwnProperty("enabled") && _config.enabled.hasOwnProperty(child.name)) {
                    log.debug("enabled " + _config.enabled[child.name]);
                    child["enabled"] = _config.enabled[child.name];
                }
                index++;
            }
        }

        private function setConfigBooleanStates(propertyName:String, values:Object):void {
            log.debug("setConfigBooleanStates");
            if (values.hasOwnProperty("all")) {
                _config[propertyName].reset();
            }
            new PropertyBinder(_config[propertyName]).copyProperties(values);
        }

        private function set immediatePositioning(enable:Boolean):void {
            _immediatePositioning = enable;
            if (! enable) return;
            _animationTimer = new Timer(500, 1);
            _animationTimer.start();
        }

		override public function onBeforeCss(styleProps:Object = null):void 
		{
			if ( _controlBarMover )
				_controlBarMover.cancelAnimation();	
		}

        /**
         * @inheritDoc
         */
        override public function css(styleProps:Object = null):Object {
            var result:Object = super.css(styleProps);

			if ( _controlBarMover )
				_controlBarMover.show();
	
            var newStyleProps:Object = _config.style.addStyleProps(result);
            if (! styleProps) return newStyleProps;

            redraw(styleProps);
            return newStyleProps;
        }

        private function setAutoHideFullscreenOnly(config:Config, props:Object):void {
            if (props.hasOwnProperty("fullscreenOnly")) {
                _config.autoHide.fullscreenOnly = props.fullscreenOnly;
            } else if (config.autoHide.state == "never") {
                _config.autoHide.state = "fullscreen";
            }
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

			_bgFill.graphics.clear();
			_bgFill.graphics.beginFill(0, 0);
			_bgFill.graphics.drawRect(0, 0, width, height);
			_bgFill.graphics.endFill();

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
            // skinless controlbar does not have defaults
            if (! SkinClasses.defaults) return null;
            return SkinClasses.defaults;
        }

        private function initTooltipConfig(config:Config, styleProps:Object):void {
            new PropertyBinder(config.tooltips).copyProperties(styleProps);
        }

        private function redraw(styleProps:Object = null):void {
            if (styleProps) {
                _config.addStyleProps(styleProps);
            }
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
            createControlBarMover();
            enableWidgets();
        }

        private function createControlBarMover():void {
            if (_config.autoHide.state != 'never' && ! _controlBarMover) {
                _controlBarMover = new AutoHide(DisplayPluginModel(_pluginModel), _config.autoHide, _player, stage, this);
            }
        }

        public function onLoad(player:Flowplayer):void {
            log.info("received player API! autohide == " + _config.autoHide.state);
            _player = player;
            
            if (_config.skin) {
                initSkin();
            }
			
			_config.player = player;
//            _player.onLoad(onPlayerLoad);

            createChildren();
            loader = player.createLoader();
            createTimeView();
            addListeners(player.playlist);
            if (_playButton) {
                _playButton.down = player.isPlaying();
            }
            log.debug("setting root style to " + _config.style.bgStyle);
            rootStyle = _config.style.bgStyle;
            if (_muteVolumeButton) {
                _muteVolumeButton.down = player.muted;
            }
            _pluginModel.dispatchOnLoad();
        }

//        private function onPlayerLoad(event:PlayerEvent):void {
//            // creation of slowmotion buttons is delayed up to this point
//            createSlowmotionButtons(_player.animationEngine); 
//        }

        private function initSkin():void {
            // must allowDomain because otherwise the dynamically loaded buttons cannot access this controlbar
            Security.allowDomain("*");
            var skin:PluginModel = _player.pluginRegistry.getPlugin(_config.skin) as PluginModel;
            log.debug("using skin " + skin);
            SkinClasses.skinClasses = skin.pluginObject as ApplicationDomain;

            log.debug("skin has defaults", SkinClasses.defaults);
            Arrange.fixPositionSettings(_pluginModel as DisplayPluginModel, SkinClasses.defaults);
            new PropertyBinder(_pluginModel, "config").copyProperties(SkinClasses.defaults, false);
            _config = createConfig(_pluginModel.config);
        }

        public function onConfig(model:PluginModel):void {
            log.info("received my plugin config ", model.config);
            _pluginModel = model;
            storeOriginalConfig(model);
            log.debug("-");
            _config = createConfig(model.config);
            log.debug("config created");
        }

        private function storeOriginalConfig(model:PluginModel):void {
            _originalConfig = new Object();
            for (var prop:String in model.config) {
                _originalConfig[prop] = model.config[prop];
            }
        }

        private function createConfig(config:Object):Config {
            var result:Config = new PropertyBinder(new Config()).copyProperties(config) as Config;
            new PropertyBinder(result.autoHide).copyProperties(config.autoHide);
            new PropertyBinder(result.visible).copyProperties(config);
            new PropertyBinder(result.enabled).copyProperties(config.enabled);
            new PropertyBinder(result.spacing).copyProperties(config.spacing);
            result.addStyleProps(config);
            initTooltipConfig(result, config["tooltips"]);
            return result;
        }

        public function set floating(float:Boolean):void {
            _floating = float;
        }

		private function hasSlowMotion():Boolean
		{
			return _player.pluginRegistry.getPlugin("slowmotion") != null;
		}

        private function createSlowmotionButtons(animationEngine:AnimationEngine):void {
            var slomo:Boolean = hasSlowMotion() && SkinClasses.getSlowMotionBwdButton() != null;
            log.debug("createSlowmotionButtons(), hasSlowMotion? " + slomo);
            if (slomo)
            {
                _slowMotionFwdButton = addChildWidget(createWidget(_slowMotionFwdButton, "slowForward", SlowMotionFwdButton, _config, animationEngine), ButtonEvent.CLICK, function(e:ButtonEvent):void {
                    onSlowMotionClicked(false, true);
                });
                _slowMotionBwdButton = addChildWidget(createWidget(_slowMotionBwdButton, "slowBackward", SlowMotionBwdButton, _config, animationEngine), ButtonEvent.CLICK, function(e:ButtonEvent):void {
                    onSlowMotionClicked(false, false);
                });
                _slowMotionFFwdButton = addChildWidget(createWidget(_slowMotionFFwdButton, "fastForward", SlowMotionFFwdButton, _config, animationEngine), ButtonEvent.CLICK, function(e:ButtonEvent):void {
                    onSlowMotionClicked(true, true);
                });
                _slowMotionFBwdButton = addChildWidget(createWidget(_slowMotionFBwdButton, "fastBackward", SlowMotionFBwdButton, _config, animationEngine), ButtonEvent.CLICK, function(e:ButtonEvent):void {
                    onSlowMotionClicked(true, false);
                });
            }
        }

        private function createChildren():void {
            log.debug("creating fullscren ", _config);
            var animationEngine:AnimationEngine = _player.animationEngine;
            _fullScreenButton = addChildWidget(createWidget(_fullScreenButton, "fullscreen", ToggleFullScreenButton, _config, animationEngine)) as AbstractToggleButton;
            log.debug("creating play");
            _playButton = addChildWidget(createWidget(_playButton, "play", TogglePlayButton, _config, animationEngine), ButtonEvent.CLICK, onPlayClicked) as AbstractToggleButton;
            log.debug("creating stop");
            _stopButton = addChildWidget(createWidget(_stopButton, "stop", StopButton, _config, animationEngine), ButtonEvent.CLICK, onStopClicked);
            _nextButton = addChildWidget(createWidget(_nextButton, "playlist", NextButton, _config, animationEngine), ButtonEvent.CLICK, "next");
            _prevButton = addChildWidget(createWidget(_prevButton, "playlist", PrevButton, _config, animationEngine), ButtonEvent.CLICK, "previous");
            createSlowmotionButtons(animationEngine);
            _muteVolumeButton = addChildWidget(createWidget(_muteVolumeButton, "mute", ToggleVolumeMuteButton, _config, animationEngine), ButtonEvent.CLICK, onMuteVolumeClicked) as AbstractToggleButton;
            _volumeSlider = addChildWidget(createWidget(_volumeSlider, "volume", VolumeScrubber, _config, animationEngine, this), VolumeSlider.DRAG_EVENT, onVolumeSlider) as VolumeScrubber;

            _scrubber = addChildWidget(createWidget(_scrubber, "scrubber", Scrubber, _config, animationEngine, this), Scrubber.DRAG_EVENT, onScrubbed) as Scrubber;

            createTimeView();
            createScrubberUpdateTimer();
            _initialized = true;
        }

        private function createTimeView():void {
            if (! _player) return;
            if (_config.visible.time) {
                if (_timeView) return;
                _timeView = addChildWidget(new TimeView(_config, _player), TimeView.EVENT_REARRANGE, onTimeViewRearranged) as TimeView;
                _timeView.visible = false;
            } else if (_timeView) {
                removeChildAnimate(_timeView);
                _timeView = null;
            }
        }

        private function onTimeViewRearranged(event:Event):void {
            onResize();
        }

        private function createWidget(existing:DisplayObject, name:String, Widget:Class, constructorArg:Object, constructorArg2:Object = null, constructorArg3:Object = null):DisplayObject {
            var doAdd:Boolean = _config.visible[name];
            if (!doAdd) {
                log.debug("not showing widget " + Widget);
                if (existing) {
                    removeChildAnimate(existing);
                }
                return null;
            }
            if (existing) return existing;
            log.debug("creating " + Widget);
            var widget:DisplayObject;

            if (constructorArg3) {
                widget = new Widget(constructorArg, constructorArg2, constructorArg3);
            } else if (constructorArg2) {
                widget = new Widget(constructorArg, constructorArg2);
            } else {
                widget = constructorArg ? new Widget(constructorArg) : new Widget();
            }

            _widgetMaxHeight = Math.max(_widgetMaxHeight, widget.height);

            widget.visible = false;
            widget.name = name;
            return widget;
        }

        private function removeChildAnimate(child:DisplayObject):DisplayObject {
            if (! _player || _immediatePositioning) {
                removeChild(child);
                return child;
            }
            _player.animationEngine.fadeOut(child, 1000, function():void {
                removeChild(child);
            });
            return child;
        }

        private function addChildWidget(widget:DisplayObject, eventType:String = null, listener:Object = null):DisplayObject {
            if (!widget) return null;
            addChild(widget as DisplayObject);
            if (eventType) {
                widget.addEventListener(eventType, listener is Function ? listener as Function : function():void {
                    _player[listener]();
                });
            }
            log.debug("added control bar child widget  " + widget);
            return widget;
        }

        private function createScrubberUpdateTimer():void {
            _timeUpdateTimer = new Timer(100);
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
                if (status.clip) {
                    _scrubber.tooltipTextFunc = function(percentage:Number):String {
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
            if (_timeView) {
                _timeView.duration = status.clip.live && duration == 0 ? -1 : duration;
                _timeView.time = _durationReached ? duration : status.time;
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
            playlist.onBegin(onPlayBegin);
            playlist.onMetaData(onPlayStarted);
            playlist.onStart(onPlayStarted); // bug #120
            playlist.onPause(onPlayPaused);
            playlist.onResume(onPlayResumed);
            playlist.onStop(onPlayStopped);
            playlist.onBufferStop(onPlayStopped);
            playlist.onFinish(onPlayStopped);
			playlist.onBeforeFinish(durationReached);
            _player.onFullscreen(onPlayerFullscreenEvent);
            _player.onFullscreenExit(onPlayerFullscreenEvent);
            _player.onMute(onPlayerMuteEvent);
            _player.onUnmute(onPlayerMuteEvent);
            _player.onVolume(onPlayerVolumeEvent);
        }

		private function durationReached(event:ClipEvent):void {
			_durationReached = true;
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

        private function onPlayBegin(event:ClipEvent):void {
            log.debug("onPlayBegin(): received " + event);
			_durationReached = false;
            var clip:Clip = event.target as Clip;
            handleClipConfig(clip);
        }

        private function handleClipConfig(clip:Clip):void {
            var controlsConfig:Object = clip.getCustomProperty("controls");
            if (controlsConfig) {
                if (controlsConfig == _currentControlsConfig) {
                    return;
                }
                log.debug("onPlayBegin(): clip has controls configuration, reconfiguring");
                reconfigure(controlsConfig);
            } else if (_currentControlsConfig) {
                log.debug("onPlayBegin(): reverting to original configuration");
                _config = createConfig(_originalConfig);
				_config.player = _player;	// setting back player, #48
                rootStyle = _config.style.bgStyle;
                recreateWidgets();
                enableWidgets();
                redraw();
            }
        }

        private function reconfigure(controlsConfig:Object):void {
            _currentControlsConfig = controlsConfig;
            setWidgets(controlsConfig);
            if (controlsConfig.hasOwnProperty("tooltips")) {
                initTooltipConfig(_config, controlsConfig["tooltips"]);
            }
            css(controlsConfig);
            if (controlsConfig.hasOwnProperty("enabled")) {
                setEnabled(controlsConfig["enabled"]);
            }
        }

        private function onPlayStarted(event:ClipEvent):void {
            log.debug("received " + event);
            if (_playButton) {
                _playButton.down = ! event.isDefaultPrevented() && _player.isPlaying();
            }
			_durationReached = false;
            enableFullscreenButton(event.target as Clip);
        }

        private function enableFullscreenButton(clip:Clip):void {
            if (!_fullScreenButton) return;
            var enabled:Boolean = clip && (clip.originalWidth > 0 || ! clip.accelerated) && _config.enabled.fullscreen;
            _fullScreenButton.enabled = enabled;
            if (enabled) {
                _fullScreenButton.addEventListener(ButtonEvent.CLICK, toggleFullscreen);
            } else {
                _fullScreenButton.removeEventListener(ButtonEvent.CLICK, toggleFullscreen);
            }
        }

        private function enableScrubber(enabled:Boolean):void {
            if (!_scrubber) return;
            _scrubber.enabled = enabled;
            if (enabled) {
                _scrubber.addEventListener(Scrubber.DRAG_EVENT, onScrubbed);
            } else {
                _scrubber.removeEventListener(Scrubber.DRAG_EVENT, onScrubbed);
            }
        }

        private function toggleFullscreen(event:ButtonEvent):void {
            _player.toggleFullscreen();
        }

        private function onPlayPaused(event:ClipEvent):void {
            log.info("received " + event);
            if (!_playButton) return;
            _playButton.down = false;
            var clip:Clip = event.target as Clip;
            log.info("clip.seekableOnBegin: " + clip.seekableOnBegin);
            if (_player.status.time == 0 && ! clip.seekableOnBegin) {
                enableScrubber(false);
            }
        }

        private function onPlayStopped(event:ClipEvent):void {
            log.debug("received " + event);

            var clip:Clip = event.target as Clip;
            if (clip.isMidroll) {
                handleClipConfig(clip.parent);
            }

            if (!_playButton) return;
            log.debug("setting playButton to up state");
            _playButton.down = false;
        }

        private function onPlayResumed(event:ClipEvent):void {
			_durationReached = false;
            log.info("received onResume, time " + _player.status.time);
            if (!_playButton) return;
            _playButton.down = true;
            if (_player.status.time < 0.5) {
                enableScrubber(true);
            }
        }

        private function onPlayerFullscreenEvent(event:PlayerEvent):void {
            log.debug("onPlayerFullscreenEvent");
            if (!_fullScreenButton) return;
            _fullScreenButton.down = event.eventType == PlayerEventType.FULLSCREEN;
        }

        private function onPlayClicked(event:ButtonEvent):void {
            _player.toggle();
        }

        private function onStopClicked(event:ButtonEvent):void {
            _player.stop();
        }

        private function onMuteVolumeClicked(event:ButtonEvent):void {
            _player.muted = ! _player.muted;
        }

		private function onSlowMotionClicked(fast:Boolean, forward:Boolean):void
		{
			if ( ! hasSlowMotion() )
				return;
							
			var slowMotionPlugin:*  = _player.pluginRegistry.getPlugin("slowmotion").pluginObject;
			var nextSpeed:Number = slowMotionPlugin.getNextSpeed(fast, forward);
				
			if ( nextSpeed == 0 )
				slowMotionPlugin.normal();
			else if ( forward )
				slowMotionPlugin.forward(nextSpeed);
			else
				slowMotionPlugin.backward(nextSpeed);
		}


        private function onVolumeSlider(event:Event):void {
            log.debug("volume slider changed to pos " + VolumeSlider(event.target).value);
            _player.volume = VolumeSlider(event.target).value;
        }

        private function onScrubbed(event:Event):void {
            _player.seekRelative(ScrubberSlider(event.target).value);
        }

        private function arrangeLeftEdgeControls():Number {
            var leftEdge:Number = _config.style.margins[3];
            var leftControls:Array = [_stopButton];
			
			if ( hasSlowMotion() && _slowMotionFBwdButton )
				leftControls.push(_slowMotionFBwdButton);
				
			if ( hasSlowMotion() && _slowMotionBwdButton )
				leftControls.push(_slowMotionBwdButton);		
		
			
			leftControls.push(_playButton);
			
			if ( hasSlowMotion() && _slowMotionFwdButton )
				leftControls.push(_slowMotionFwdButton);
				
			if ( hasSlowMotion() && _slowMotionFFwdButton )		
				leftControls.push(_slowMotionFFwdButton);	
			
			leftControls.push(_prevButton);
			leftControls.push(_nextButton);
			
            leftEdge = arrangeControls(leftEdge, leftControls, arrangeToLeftEdge);
            return leftEdge;
        }

        private function arrangeRightEdgeControls(leftEdge:Number):void {
            var edge:Number = _config.visible.scrubber ? (width - margins[1]) : leftEdge;
            var rightControls:Array;

            // set volume slider width first so that we know how to arrange the other controls
            if (_volumeSlider) {
                _volumeSlider.width = getVolumeSliderWidth();
            }
            if (_config.visible.scrubber) {
                // arrange from right to left (scrubber takes the remaining space)
                rightControls = [_fullScreenButton, _volumeSlider, _muteVolumeButton, _timeView];
                edge = arrangeControls(edge, rightControls, arrangeToRightEdge);
                edge = arrangeScrubber(leftEdge, edge, firstNonNull(rightControls.reverse(), 0));
            } else {
                // no scrubber --> stack from left to right
                rightControls = [_timeView, _muteVolumeButton, _volumeSlider, _fullScreenButton];
                edge = arrangeControls(edge, rightControls, arrangeToLeftEdge);
            }

            arrangeVolumeControl();
        }

        private function firstNonNull(controls:Array, start:int):DisplayObject {
            for (var i:Number = start; i < controls.length; i++) {
                if (controls[i]) return controls[i] as DisplayObject;
            }
            return null;
        }

        private function arrangeControls(edge:Number, controls:Array, arrangeFunc:Function):Number {
            for (var i:Number = 0; i < controls.length; i++) {
                if (controls[i]) {
                    var control:DisplayObject = controls[i] as DisplayObject;
                    arrangeYCentered(control);
                    edge = arrangeFunc(edge, getSpaceAfterWidget(control), control) as Number;
                }
            }
            return edge;
        }

        private function get margins():Array {
            return _config.style.margins;
        }

        private function arrangeVolumeControl():void {
            if (! _config.visible.volume) return;
            _volumeSlider.height = height - margins[0] - margins[2];
            _volumeSlider.y = margins[0];
        }

        private function arrangeScrubber(leftEdge:Number, rightEdge:Number, nextToRight:DisplayObject):Number {
            if (! _config.visible.scrubber) return rightEdge;
            _scrubber.setRightEdgeWidth(getScrubberRightEdgeWidth(nextToRight))
            arrangeX(_scrubber, leftEdge);
            var scrubberWidth:Number = rightEdge - leftEdge - 2 * getSpaceAfterWidget(_scrubber);
            if (! _player || _immediatePositioning) {
                _scrubber.width = scrubberWidth;
            } else {
                _player.animationEngine.animateProperty(_scrubber, "width", scrubberWidth);
            }
            _scrubber.height = height - margins[0] - margins[2];
            _scrubber.y = _height - margins[2] - _scrubber.height;
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
            clip.y = margins[0];
            clip.height = height - margins[0] - margins[2];
            clip.scaleX = clip.scaleY;

            Arrange.center(clip, 0, height);
        }

        private function getSpaceAfterWidget(widget:DisplayObject):int {
            if (widget == lastOnRight) return _config.style.margins[1];
            return _config.spacing.getSpaceAfterWidget(widget);
        }

        private function getScrubberRightEdgeWidth(nextWidgetToRight:DisplayObject):int {
            return SkinClasses.getScrubberRightEdgeWidth(nextWidgetToRight);
        }

		private function getVolumeSliderWidth():int {
            return SkinClasses.getVolumeSliderWidth();
        }

        private function get lastOnRight():DisplayObject {
            if (_fullScreenButton) return _fullScreenButton;
            if (_volumeSlider) return _volumeSlider;
            if (_muteVolumeButton) return _muteVolumeButton;
            if (_timeView) return _timeView;
            return null;
        }
    }
}
