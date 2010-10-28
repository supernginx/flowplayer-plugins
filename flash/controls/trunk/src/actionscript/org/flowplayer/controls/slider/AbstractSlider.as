/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *Copyright (c) 2008, 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls.slider {
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
	import flash.display.Sprite;

    import org.flowplayer.controls.config.Config;
    import org.flowplayer.controls.DefaultToolTip;
    import org.flowplayer.controls.NullToolTip;
    import org.flowplayer.controls.ToolTip;
    import org.flowplayer.controls.button.DraggerButton;
    import org.flowplayer.util.GraphicsUtil;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.AnimationEngine;

    /**
	 * @author api
	 */
	public class AbstractSlider extends AbstractSprite {
		public static const DRAG_EVENT:String = "onDrag";
		
		protected var _dragger:DraggerButton;
		private var _dragTimer:Timer;
		private var _previousDragEventPos:Number;
		protected var _config:Config;
		private var _animationEngine:AnimationEngine;
		private var _currentPos:Number;
		private var _tooltip:ToolTip;
		private var _tooltipTextFunc:Function;
        private var _controlbar:DisplayObject;
        private var _mouseOver:Boolean;
		private var _border:Sprite;
		
        public function AbstractSlider(config:Config, animationEngine:AnimationEngine, controlbar:DisplayObject) {
            _config = config;
            _animationEngine = animationEngine;
            _controlbar = controlbar;
            _dragTimer = new Timer(50);
            createDragger();
            toggleTooltip();
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
            addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
        }
 
        private function onMouseMove(event:MouseEvent):void {
            if (! _mouseOver) return;
//            log.debug("onMouseMove(), changing tooltip text to " + tooltipText);
            var text:String = tooltipText;
            if (! tooltipText) {
                _tooltip.hide();
            } else if (_tooltip.visible) {
                showTooltip();
            } else {
			    _tooltip.text = tooltipText;
            }
        }

        private function get tooltipText():String {
            if (_tooltipTextFunc == null) return null;
            return _tooltipTextFunc(((mouseX - _dragger.width/2) / (width - _dragger.width)) * 100);
        }

        protected function onMouseOut(event:MouseEvent = null):void {
//            if (event && isParent(event.relatedObject as DisplayObject, this)) return;
            log.debug("onMouseOut");
            hideTooltip();
            _mouseOver = false;
            removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }

        protected function onMouseOver(event:MouseEvent):void {
            log.debug("onMouseOver");
            showTooltip();
            _mouseOver = true;
            addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }


        protected function hideTooltip():void {
            _tooltip.hide();
        }

        protected function showTooltip():void {
            if (tooltipText) {
                _tooltip.show(this, tooltipText, true);
            }
        }

		private function toggleTooltip():void {
			if (isToolTipEnabled()) {
				if (_tooltip && _tooltip is DefaultToolTip) return;
				log.debug("enabling tooltip");
				_tooltip = new DefaultToolTip(_config, _animationEngine);
			} else {
				log.debug("tooltip disabled");
				_tooltip = new NullToolTip();
			}
		}
		
		protected function isToolTipEnabled():Boolean {
			return false;
		}

		public function set enabled(value:Boolean) :void {
			log.debug("setting enabled to " + value);
            _dragTimer.addEventListener(TimerEvent.TIMER, dragging);
			var func:String = value ? "addEventListener" : "removeEventListener";

			this[func](MouseEvent.MOUSE_UP, _onMouseUp);
			_dragger[func](MouseEvent.MOUSE_DOWN, _onMouseDown);
			_dragger[func](MouseEvent.MOUSE_UP, _onMouseUp);
			stage[func](MouseEvent.MOUSE_UP, onMouseUpStage);
			stage[func](Event.MOUSE_LEAVE, onMouseLeaveStage);
			
			toggleClickListeners(value);

			alpha = value ? 1 : 0.5;
			_dragger.buttonMode = value;
		}

        public function get enabled():Boolean {
            return _dragger.buttonMode;
        }
		
		private function onAddedToStage(event:Event):void {
			enabled = true;
		}

		private function toggleClickListeners(add:Boolean):void {
			var targets:Array = getClickTargets(add);
			log.debug("click targets", targets);
			for (var i:Number = 0; i < targets.length; i++) {
				if (add) {
					EventDispatcher(targets[i]).addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
				} else {
					EventDispatcher(targets[i]).removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
				}
				if (targets[i].hasOwnProperty("buttonMode")) {
					targets[i]["buttonMode"] = add;
				}
			}
		}
		
		protected function getClickTargets(enabled:Boolean):Array {
			return [this];
		}

		protected function createDragger():void {
 			_dragger = new DraggerButton(_config, _animationEngine);
			_dragger.buttonMode = true;
			addChild(_dragger);
		}
		
		private function onMouseUpStage(event:MouseEvent):void {
			if (_dragTimer.running) {
				_onMouseUp();
			}
            _dragTimer.stop();
		}
		
		private function onMouseLeaveStage(event:Event):void {
			_tooltip.hide();
			
			if (_dragTimer.running) {
				_onMouseUp();
			}
            _dragTimer.stop();
		}
		
		private function _onMouseUp(event:MouseEvent = null):void {
            onMouseUp(event);
			log.debug("onMouseUp");
//			_tooltip.hide();
			if (event && event.target != this) return;
			if (! canDragTo(mouseX) && _dragger.x > 0) return;
						
			_dragTimer.stop();
			dragging();
			updateCurrentPosFromDragger();
			
			if (! dispatchOnDrag) {
				dispatchDragEvent();
			}
		}

        protected function onMouseUp(event:MouseEvent):void {
        }
        
		protected function canDragTo(xPos:Number):Boolean {
			return true;
		}

		private function updateCurrentPosFromDragger():void {
			_currentPos = (_dragger.x / (width - _dragger.width)) * 100;
		}

		protected final function get isDragging():Boolean {
			return _dragTimer.running;
		}

		private function _onMouseDown(event:MouseEvent):void {
			if (! event.target == this) return;
            onMouseDown(event);
			_dragTimer.start();
		}

        protected function onMouseDown(event:MouseEvent):void {
        }

		private function dragging(event:TimerEvent = null):void {
			var pos:Number = mouseX - _dragger.width / 2;
            if (pos < 0) {
                pos = 0;
            }
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
            onDragging();
		}

        protected function onDragging():void {
        }

		private function dispatchDragEvent():void {
			log.debug("dispatching drag event");
			onDispatchDrag();
			dispatchEvent(new Event(DRAG_EVENT));
		}
		
		protected function get dispatchOnDrag():Boolean {
			return true;
		}

		protected function onDispatchDrag():void {
			// can be overridden in subclasses
		}

		internal function get maxDrag():Number {
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
            onSetValue();
//			if (_dragTimer && _dragTimer.running || ! allowSetValue) {
//				log.debug("drag in progress");
//				return;
//			}
//			var pos:Number = value/100 * (width - _dragger.width);
//            _animationEngine.animateProperty(_dragger, "x", pos, 200, function():void { onSetValue() });
		}

        protected function onSetValue():void {
        }
//
//		protected function onSetValue():void {
//		}

		protected function get allowSetValue():Boolean {
			// can be overridden in sucbclasses
			return true;
		}

		protected override function onResize():void {
			log.debug("onResize");
			super.onResize();
			
			_dragger.height = height;
            _dragger.scaleX = _dragger.scaleY;
            drawBackground();
			drawBorder();
        }

		private function drawBackground():void {
			graphics.clear();
			graphics.beginFill(sliderColor, sliderAlpha);
			graphics.drawRoundRect(0, height/2 - barHeight/2, width, barHeight, barCornerRadius, barCornerRadius);
            graphics.endFill();
                                                                                                                     
            if (sliderGradient) {
                GraphicsUtil.addGradient(this, 1, sliderGradient, barCornerRadius, 0, height/2 - barHeight/2, barHeight);
            }
        }

		private function drawBorder():void {
			
			if (_border && _border.parent == this) {
				removeChild(_border);
			}
			if (! borderWidth > 0) return;
			_border = new Sprite();
			addChild(_border);
			swapChildren(_border, _dragger);
			log.info("border weight is " + borderWidth + ", color is "+ String(borderColor) + ", alpha "+ String(borderAlpha));		
			_border.graphics.lineStyle(borderWidth, borderColor, borderAlpha);
			GraphicsUtil.drawRoundRectangle(_border.graphics, 0, height/2 - barHeight/2, width, barHeight, barCornerRadius);
		}

		protected function get borderWidth():Number {
			return 0;
		}
		
		protected function get borderColor():Number {
			return 0xffffff;
		}
		
		protected function get borderAlpha():Number {
			return 0;
		}

        protected function get barCornerRadius():Number {
            return barHeight/1.5;
        }

        protected function get sliderGradient():Array {
            return null;
        }

        protected function get sliderColor():Number {
            return 0x000000;
        }

		protected function get sliderAlpha():Number {
            return 1;
        }

        protected function get barHeight():Number {
            return height;
        }

		protected function drawBar(bar:Sprite, color:Number, alpha:Number, gradientAlphas:Array, leftEdge:Number, rightEdge:Number):void {
			bar.graphics.clear();
			if (leftEdge > rightEdge) return;
			bar.scaleX = 1;
			
			bar.graphics.beginFill(color, alpha);
			bar.graphics.drawRoundRect(leftEdge, height/2 - barHeight/2, rightEdge - leftEdge, barHeight, barCornerRadius, barCornerRadius);
			bar.graphics.endFill();
			
			if (gradientAlphas) {
				GraphicsUtil.addGradient(bar, 0, gradientAlphas, barCornerRadius, leftEdge,  height/2 - barHeight/2 , barHeight);
			} else {
				GraphicsUtil.removeGradient(bar);
			}
		}

        protected final function get animationEngine():AnimationEngine {
            return _animationEngine;
        }

		public function redraw(config:Config):void {
			_config = config;
            drawBackground();
			drawBorder();
			toggleTooltip();
			_tooltip.redraw(config);
		}

		public function set tooltipTextFunc(tooltipTextFunc:Function):void {
			_tooltipTextFunc=tooltipTextFunc;
		}
    }
}
