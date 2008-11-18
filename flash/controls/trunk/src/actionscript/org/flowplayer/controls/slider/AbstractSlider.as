/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 * Copyright (c) 2008 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls.slider {
	import org.flowplayer.view.AnimationEngine;	
	import org.flowplayer.util.GraphicsUtil;			import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flowplayer.controls.Config;
	import org.flowplayer.controls.flash.Dragger;
	import org.flowplayer.view.AbstractSprite;	

	/**
	 * @author api
	 */
	public class AbstractSlider extends AbstractSprite {
		public static const DRAG_EVENT:String = "onDrag";
		
		protected var _dragger:Sprite;
		private var _dragTimer:Timer;
		private var _previousDragEventPos:Number;
		protected var _config:Config;
		private var _animationEngine:AnimationEngine;
		private var _currentPos:Number;

		public function AbstractSlider(config:Config) {
			_config = config;
			_dragTimer = new Timer(50);
			_dragTimer.addEventListener(TimerEvent.TIMER, onDrag);
			createDragger();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void {
			registerClickListeners(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpStage);
		}

		protected function registerClickListeners(event:String, listener:Function):void {
			addEventListener(event, listener);
		}

		private function createDragger():void {
			_dragger = new Dragger();
			_dragger.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_dragger.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_dragger.buttonMode = true;
			addChild(_dragger);
		}
		
		private function onMouseUpStage(event:MouseEvent):void {
			if (_dragTimer.running) {
				onMouseUp();
			}
		}
		
		private function onMouseUp(event:MouseEvent = null):void {
			if (event && event.target != this) return;
			_dragTimer.stop();
			onDrag();
			updateCurrentPosFromDragger();
			
			if (! dispatchOnDrag) {
				dispatchDragEvent();
			}
		}
		
		private function updateCurrentPosFromDragger():void {
			_currentPos = (_dragger.x / (width - _dragger.width)) * 100;
		}

		protected final function get isDragging():Boolean {
			return _dragTimer.running;
		}

		private function onMouseDown(event:MouseEvent):void {
			if (! event.target == this) return;
			_dragTimer.start();
		}

		private function onDrag(event:TimerEvent = null):void {
			var pos:Number = mouseX - _dragger.width / 2;
			if (pos < 0)
				pos = 0;
			if (pos > maxDrag) {
				pos = maxDrag;
			}
			
			_dragger.x = pos;

			// do not dispatch several times from almost the same pos
			if (Math.abs(_previousDragEventPos - _dragger.x) < 1) return;
			_previousDragEventPos = _dragger.x;
			
			if (dispatchOnDrag) {
				updateCurrentPosFromDragger();
				dispatchDragEvent();
			}
		}

		private function dispatchDragEvent():void {
			log.debug("dispatching drag event");
			dispatchEvent(new Event(DRAG_EVENT));
			dragEventDispatched();
		}
		
		protected function get dispatchOnDrag():Boolean {
			return true;		}
		protected function dragEventDispatched():void {
			// can be overridden in subclasses
		}

		protected function get maxDrag():Number {
			return width - _dragger.width;
		}
		
		/**
		 * Gets the curent value of the slider.
		 * @return the value that is between 0 and 100
		 */
		public function get value():Number {
			return _currentPos;
		}

		/**
		 * Sets the slider's current value.
		 * @param value the value between 0 and 100
		 */
		public final function set value(value:Number):void {
			if (value > 100) {
				value = 100;
			}
			_currentPos = value;
			if (_dragTimer && _dragTimer.running || ! allowSetValue) {
				log.debug("drag in progress");
				return;
			}
			var pos:Number = value/100 * (width - _dragger.width);
			_dragger.x = pos;
			onSetValue();
		}
		
		protected function onSetValue():void {
		}

		protected function get allowSetValue():Boolean {
			// can be overridden in sucbclasses
			return true;
		}

		protected override function onResize():void {
			drawBackground();
			_dragger.height = height;
			_dragger.scaleX = _dragger.scaleY;
			_dragger.y = height / 2 - _dragger.height / 2;
		}

		private function drawBackground():void {
			graphics.clear();
			graphics.beginFill(_config.style.sliderColor, 1);
			var radius:Number = height/1.5;
			graphics.drawRoundRect(0, 0, width, height, radius, radius);
			graphics.endFill();
			
			if (_config.style.sliderGradient) {
				GraphicsUtil.addGradient(this, 0, _config.style.sliderGradient, radius);
			}
		}
		
		public function redraw(config:Config):void {
			_config = config;
			drawBackground();
		}
		
		public function set animationEngine(animationEngine:AnimationEngine):void {
			_animationEngine = animationEngine;
		}
	}
}
