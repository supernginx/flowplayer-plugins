/* * This file is part of Flowplayer, http://flowplayer.org * * Copyright (c) 2008 Flowplayer Ltd * * Released under the MIT License: * http://www.opensource.org/licenses/mit-license.php */package org.flowplayer.ui.buttons {    import flash.display.DisplayObject;    import flash.display.DisplayObjectContainer;    import flash.display.MovieClip;    import flash.events.Event;    import flash.events.MouseEvent;    import flash.events.TimerEvent;    import flash.geom.ColorTransform;    import flash.utils.Timer;    import org.flowplayer.util.GraphicsUtil;    import org.flowplayer.util.GraphicsUtil;    import org.flowplayer.util.GraphicsUtil;    import org.flowplayer.view.AnimationEngine;    /**     * @author api     */    public class AbstractButton extends ConfigurableWidget {        protected var _face:DisplayObjectContainer;        protected var _config:ButtonConfig;        private var _mouseTrackTimer:Timer;        private static const HIGHLIGHT_INSTANCE_NAME:String = "mOver";        protected static const ICON_INSTANCE_NAME:String = "mIcon";        private static const LINE_DECORATIONS_INSTANCE_NAME:String = "lines";        protected var _animationEngine:AnimationEngine;        public function AbstractButton(config:ButtonConfig, animationEngine:AnimationEngine) {            _config = config;            _animationEngine = animationEngine;            _mouseTrackTimer = new Timer(200);            _face = DisplayObjectContainer(addFaceIfNotNull(createFace()));            childrenCreated();            enabled = config.enabled;            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);        }        internal function setToggledColor(isToggled:Boolean):void {            log.debug("setToggledColor(), isToggled == " + isToggled + ", face is " + _face);            var icon:DisplayObject = iconDisplayObject;            if (! icon) {                log.debug("setToggledColor(): face " + _face + " does not have a display object with name '" + ICON_INSTANCE_NAME + "' to be highlighted");                return;            }            log.debug("setToggledColor(), changing highlight of " + icon);            var colors:Array = isToggled ? _config.onRGBA : _config.offRGBA;            GraphicsUtil.transformColor(icon, colors);        }        protected function childrenCreated():void {        }        public function addFaceIfNotNull(child:DisplayObject):DisplayObject {            if (! child) return child;            return addChild(child);        }        protected function onAddedToStage(event:Event):void {            onMouseOut();        }        override protected function onResize():void {            log.debug("onResize() " + width + " x " + height);            _face.width = width;            _face.height = height;        }        protected function get faceWidth():Number {            return _face.width;        }        protected function get faceHeight():Number {            return _face.height;        }        override public function configure(config:Object):void {            _config = config as ButtonConfig;            enabled = _config.enabled;            onMouseOut();        }        protected function drawLines():void {            if (_face) {                var lines:DisplayObject = linesDisplayObject;                if (lines) {                    log.debug("lines alpha initial value is " + lines.alpha);                    GraphicsUtil.transformColor(lines, _config.lineColorRGBA);                }            }        }        protected function registerEventListeners(addListeners:Boolean, target:DisplayObject):void {            if (addListeners) {                //set the priority high so internal events get called first                target.addEventListener(MouseEvent.ROLL_OVER, onMouseOver, false, 100);                target.addEventListener(MouseEvent.ROLL_OUT, onMouseOut, false, 100);                target.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 100);                target.addEventListener(MouseEvent.CLICK, onClicked, false, 100);                _mouseTrackTimer.addEventListener(TimerEvent.TIMER, onMouseMove);            } else {                target.removeEventListener(MouseEvent.ROLL_OVER, onMouseOver);                target.removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);                target.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);                target.removeEventListener(MouseEvent.CLICK, onClicked);                _mouseTrackTimer.addEventListener(TimerEvent.TIMER, onMouseMove);            }        }        override public function set enabled(value:Boolean):void {            log.debug("setEnabled(), new enabled value == " + value);            _config.setEnabled(value);            buttonMode = enabled;            registerEventListeners(enabled, this);            if (disabledDisplayObject) {                log.debug("setEnabled(), disabledDisplayObject == " + disabledDisplayObject);                log.debug("setEnabled() normal color", _config.colorRGBA);                log.debug("setEnabled() disabled color", _config.disabledRGBA);                var colors:Array = value ? _config.colorRGBA : _config.disabledRGBA;                GraphicsUtil.transformColor(disabledDisplayObject, colors);            }            doEnable(enabled);        }        /**         * The display object to be highlighted on mouse-over.         */        protected function get highlightDisplayObject():DisplayObject {            return _face.getChildByName(HIGHLIGHT_INSTANCE_NAME) || this;        }        /**         * The display object to be highlighted when toggled. For toggle buttons.         * This icon is also highlighted on mouse over.         */        protected function get iconDisplayObject():DisplayObject {            return _face.getChildByName(ICON_INSTANCE_NAME) || this;        }        /**         * Line decorations.         */        protected function get linesDisplayObject():DisplayObject {            return _face.getChildByName(LINE_DECORATIONS_INSTANCE_NAME);        }        /**         * The display object whose color is changed when the button is disabled. By default this is the same         * as highlightDisplayObject.         */        protected function get disabledDisplayObject():DisplayObject {            return highlightDisplayObject;        }        protected function doEnable(enabled:Boolean):void {        }        override public function get enabled():Boolean {            return _config.enabled;        }        protected function onClicked(event:MouseEvent):void {            log.debug("clicked!");        }        protected function onMouseOut(event:MouseEvent = null):void {            log.debug("onMouseOut");            resetDispColor(highlightDisplayObject);            showMouseOutState(_face);            _mouseTrackTimer.stop();        }        protected function onMouseOver(event:MouseEvent):void {            transformDispColor(highlightDisplayObject);            if (event.relatedObject is AbstractButton) {                AbstractButton(event.relatedObject).onMouseOut();            }            showMouseOverState(_face);            _mouseTrackTimer.start();        }        private function onMouseMove(event:TimerEvent):void {            if (! stage) return;            if (! this.hitTestPoint(stage.mouseX, stage.mouseY)) {                onMouseOut();            }        }        protected function showMouseOverState(clip:DisplayObjectContainer):void {            log.debug("showMouseOverState " + clip);            if (clip is MovieClip) {                log.debug("calling play() on " + clip);                if (MovieClip(clip).currentFrame == 1) {                    MovieClip(clip).play();                }            }            animateClip(highlightDisplayObject, true);            animateClip(iconDisplayObject, true);        }        private function animateClip(clip:DisplayObject, over:Boolean):void {            if (clip && clip is MovieClip) {                if (over) {                    try {                        MovieClip(clip).gotoAndPlay("over");                    } catch (e:Error) {                        // we did not have the the "over" label there, ignore                    }                } else {                    MovieClip(clip).gotoAndStop(1);                }            }        }        protected function showMouseOutState(clip:DisplayObjectContainer):void {            if (clip is MovieClip) {                log.debug("calling gotoAndStop(1) on " + clip);                MovieClip(clip).gotoAndStop(1);            }            animateClip(highlightDisplayObject, false);            animateClip(iconDisplayObject, false);        }        protected function transformDispColor(disp:DisplayObject):void {            log.debug("transformDispColor() disp == " + disp + " to color: " + _config.overColorRGBA.toString());            GraphicsUtil.transformColor(disp, _config.overColorRGBA);        }        protected function resetDispColor(disp:DisplayObject):void {            log.debug("resetDispColor()");            GraphicsUtil.transformColor(disp, _config.colorRGBA);            if (enabled) {                GraphicsUtil.transformColor(disp, _config.colorRGBA);            } else {                if (disabledDisplayObject) {                    GraphicsUtil.transformColor(disp, _config.disabledRGBA);                }            }        }        protected function createFace():DisplayObjectContainer {            return null;        }        protected function onMouseDown(event:MouseEvent):void {            var overClip:DisplayObject = highlightDisplayObject;            try {                if (overClip && overClip is MovieClip)                    MovieClip(overClip).gotoAndPlay("down");            } catch (e:Error) {            }        }        protected function get face():DisplayObjectContainer {            return _face;        }        protected function get config():Object {            return _config;        }    }}