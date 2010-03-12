/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *Copyright (c) 2008, 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.ui {
    import flash.display.DisplayObject;
    import flash.display.Stage;
    import flash.display.StageDisplayState;
    import flash.events.Event;
    import flash.events.FullScreenEvent;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Rectangle;
    import flash.utils.Timer;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.model.DisplayPropertiesImpl;
    import org.flowplayer.model.Playlist;
    import org.flowplayer.model.PluginEventType;
    import org.flowplayer.util.Assert;
    import org.flowplayer.util.Log;
    import org.flowplayer.view.Flowplayer;

    /**
     * @author api
     */
    public class AutoHide {

        private var log:Log = new Log(this);
        private var _disp:DisplayObject;
        private var _hideTimer:Timer;
        private var _mouseOutTimer:Timer;
        private var _stage:Stage;
        private var _playList:Playlist;
        private var _config:AutoHideConfig;
        private var _player:Flowplayer;
        private var _originalPos:Object;
        private var _mouseOver:Boolean = false;
        private var _hwFullScreen:Boolean;
        private var _model:DisplayPluginModel;

        public function AutoHide(model:DisplayPluginModel, config:AutoHideConfig, player:Flowplayer, stage:Stage, displayObject:DisplayObject) {
//            Assert.notNull(model, "model cannot be null");
            Assert.notNull(config, "config cannot be null");
            Assert.notNull(player, "player cannot be null");
            Assert.notNull(stage, "stage cannot be null");
            Assert.notNull(displayObject, "displayObject cannot be null");
            _model = model;
            _config = config;
            _playList = player.playlist;
            _player = player;
            _stage = stage;
            _disp = displayObject;

            if (_config.state != "fullscreen") {
                startTimerAndInitializeListeners();
            }
            _stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
			_stage.addEventListener(Event.MOUSE_LEAVE, startMouseOutTimer);
        }

        public function stop(leaveVisible:Boolean = true):void {
            log.debug("stop(), leaveVisible? " + leaveVisible);
            if (! isShowing() && leaveVisible) {
                show();
            }
            if (! leaveVisible) {
                hide(null, true);
            }
            stopHideTimer();
			stopMouseOutTimer();
            _stage.removeEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
            _stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            _stage.removeEventListener(Event.RESIZE, onStageResize);
			_stage.removeEventListener(Event.MOUSE_LEAVE, startMouseOutTimer);
            _disp.removeEventListener(MouseEvent.ROLL_OVER, onMouseOver);
            _disp.removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
        }

        public function start():void {
            show();
            log.debug("start(), autoHide is " + _config.state);
            if (_config.state == 'fullscreen') {

                fullscreenStart();
                return;
            }
            if (_config.state == "always") {
                startTimerAndInitializeListeners();
                return;
            }
        }

        private function getDisplayProperties():Object {
            if (_model && _model.getDisplayObject() == _disp) {
                return DisplayProperties(_player.pluginRegistry.getPlugin(_model.name)).clone() as DisplayProperties;
            } else {
                return { top: _disp.y, left: _disp.x, width: _disp.width, height: _disp.height, alpha: _disp.alpha };
            }
        }

        private function clone(obj:Object):Object {
            if (obj is DisplayProperties) {
                return obj.clone() as DisplayProperties;
            } else {
                var clone:Object = {};
                for (var prop:String in obj) {
                    clone[prop] = obj[prop];
                }
                return clone;
            }
        }

        private function get hiddenPos():Object {
            _originalPos = getDisplayProperties();
            var hiddenPos:Object = clone(_originalPos);
            if (useFadeOut) {
                _hwFullScreen = true;
                hiddenPos.alpha = 0;
            } else {
                _hwFullScreen = false;
                hiddenPos.top = getHiddenPosition();
            }
            return hiddenPos;
        }

        private function onFullScreen(event:FullScreenEvent):void {
            if (event.fullScreen) {
                startTimerAndInitializeListeners();
                show();
            } else {
                if (_config.state != 'always') {
                    stop();
                }
                _disp.alpha = 0;
                _player.animationEngine.cancel(_disp);
                show();
            }
        }

        private function fullscreenStart():void {
            if (isInFullscreen()) {
                startTimerAndInitializeListeners();
            } else {
                stopHideTimer();
                stopMouseOutTimer();
                _stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
            }
        }

        private function startTimerAndInitializeListeners():void {
//            log.info("startTimerAndInitializeListeners()");
            startHideTimer();
            _stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
            _stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            _stage.addEventListener(Event.RESIZE, onStageResize);
            _disp.addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
            _disp.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
        }

        private function onMouseOver(event:MouseEvent):void {
            _mouseOver = true;
        }

        private function onMouseOut(event:MouseEvent):void {
            _mouseOver = false;
        }



		private function mouseLeave(event:Event = null):void {
			stopHideTimer();
			stopMouseOutTimer();
			_player.animationEngine.cancel(_disp);
			hide();
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}



		private function startMouseOutTimer(event:Event = null):void {
            log.debug("startMouseOutTimer(), delay is " + _config.mouseOutDelay);
            if (_config.mouseOutDelay == 0) {
                mouseLeave();
                return;
            }
            if (! _mouseOutTimer) {
                _mouseOutTimer = new Timer(_config.mouseOutDelay);
            }
            // check if hideDelay has changed
            else if (_config.mouseOutDelay != _mouseOutTimer.delay) {
                log.debug("startMouseOutTimer(), using new delay " + _config.mouseOutDelay);
                _mouseOutTimer.stop();
                _mouseOutTimer = new Timer(_config.mouseOutDelay);
            }

            _mouseOutTimer.addEventListener(TimerEvent.TIMER, mouseLeave);
            _mouseOutTimer.start();
        }

        private function stopMouseOutTimer():void {
            if (! _mouseOutTimer) return;
            _mouseOutTimer.stop();
            _mouseOutTimer = null;
        }




        private function onMouseMove(event:MouseEvent):void {
            _stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            _player.animationEngine.cancel(_disp);
            show();
            if (isShowing() && _hideTimer) {
//                log.debug("onMouseMove(): already showing");
                _hideTimer.stop();
                _hideTimer.start();
                return;
            }
        }

        private function isShowing():Boolean {
            return _disp.alpha > 0 && _disp.y < getHiddenPosition();
        }

        private function onStageResize(event:Event):void {
            if (! _hideTimer) return;
            _hideTimer.stop();
            _hideTimer.start();
        }

        private function startHideTimer():void {
//            log.info("startHideTimer(), delay is " + _config.hideDelay);
            if (_config.hideDelay == 0) {
                hide();
                return;
            }
            if (! _hideTimer) {
                _hideTimer = new Timer(_config.hideDelay);
            }
            // check if hideDelay has changed
            else if (_config.hideDelay != _hideTimer.delay) {
//                log.info("startHideTimer(), using new delay " + _config.hideDelay);
                _hideTimer.stop();
                _hideTimer = new Timer(_config.hideDelay);
            }

            _hideTimer.addEventListener(TimerEvent.TIMER, hide);
            _hideTimer.start();
        }

        private function stopHideTimer():void {
            if (! _hideTimer) return;
            _hideTimer.stop();
            _hideTimer = null;
        }

        private function isInFullscreen():Boolean {
            return _stage.displayState == StageDisplayState.FULL_SCREEN;
        }

        private function hide(event:TimerEvent = null, ignoreMouseOver:Boolean = false):void {
            if (! isShowing()) return;

            log.debug("mouse pos " + _stage.mouseX + "x" + _stage.mouseY + " mouse on stage " + _mouseOver);
            if (! ignoreMouseOver && _mouseOver) return;

            log.debug("dispatching onBeforeHidden");
            if (_model && ! _model.dispatchBeforeEvent(PluginEventType.PLUGIN_EVENT, "onBeforeHidden")) {
                log.debug("hide() onHidden event was prevented, not hiding");
                return;
            }

            log.debug("animating to hidden position");
            _player.animationEngine.animate(_disp, hiddenPos, _config.hideDuration, onHidden);
            if (_hideTimer) {
                _hideTimer.stop();
            }
        }

        private function onHidden():void {
            log.debug("onHidden()");
            dispatchEvent("onHidden");
        }

        private function show():void {
            // fetch the current props, they might have changed because of some
            var currentProps:Object = getDisplayProperties();
            if (!_originalPos) {
                _originalPos = getDisplayProperties();
            }

            if (_hwFullScreen) {
                currentProps.alpha = _originalPos.alpha;
            } else {
                // restore top or bottom from our pre-hide position
                if (_originalPos is DisplayProperties) {
                    if (_originalPos.position.top.hasValue()) {
                        currentProps.top = _originalPos.position.top;
                    }
                    if (_originalPos.position.bottom.hasValue()) {
                        currentProps.bottom = _originalPos.position.bottom;
                    }
                } else {
                    currentProps.y = _originalPos.y;
                }
            }

            if (_model && ! _model.dispatchBeforeEvent(PluginEventType.PLUGIN_EVENT, "onBeforeShowed")) {
                log.debug("show() onShowed event was prevented, not showing");
                return;
            }

            _player.animationEngine.animate(_disp, currentProps, 400, onShowed);
        }

        private function dispatchEvent(string:String):void {
            if (! _model) return;
            _model.dispatch(PluginEventType.PLUGIN_EVENT, string);
        }

        private function onShowed():void {
            dispatchEvent("onShowed");
            _stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

            if (_config.state == "fullscreen") {
                fullscreenStart();
            }
            if (_config.state == "always") {
                startTimerAndInitializeListeners();
            }
        }

        private function get useFadeOut():Boolean {
            if (_config.hideStyle == "fade") return true;
            // always use fading when using accelerated fullscreen
            return isInFullscreen() && _stage.hasOwnProperty("fullScreenSourceRect") && _stage.fullScreenSourceRect != null;
        }

        private function getHiddenPosition():Object {
            if (_stage.displayState == StageDisplayState.FULL_SCREEN && _stage.hasOwnProperty("fullScreenSourceRect")) {
                var rect:Rectangle = _stage.fullScreenSourceRect;
                if (rect) {
                    return rect.height;
                }
            }
            return _stage.stageHeight;
        }
    }
}
