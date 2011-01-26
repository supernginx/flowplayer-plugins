/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */


package org.flowplayer.controls {
   
	import org.flowplayer.view.AbstractSprite;
	import org.flowplayer.view.StyleableSprite;
	import org.flowplayer.view.Flowplayer;
		
	import org.flowplayer.util.Arrange;	
		
	import org.flowplayer.ui.buttons.ConfigurableWidget;
	import org.flowplayer.ui.buttons.ToggleButtonConfig;
	
	import org.flowplayer.controls.config.Config;
	import org.flowplayer.controls.controllers.*;
	import org.flowplayer.controls.time.TimeViewController;
	import org.flowplayer.controls.scrubber.ScrubberController;
	import org.flowplayer.controls.volume.VolumeController;
	import org.flowplayer.controls.buttons.SurroundedWidget;
	
	import flash.utils.*
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	
    public class Controlbar extends StyleableSprite {


		private static var _registeredControllers:Array = [];
		
		private var _widgets:Dictionary;

        private var _config:Config;
        private var _immediatePositioning:Boolean = true;
        private var _animationTimer:Timer;
        private var _player:Flowplayer;
		
		// #71, need to have a filled sprite who takes all the space to get events to work
		private var _bgFill:Sprite;
		
		
		private var _widgetsOrder:Array = ['stop', 'play', 'previous', 'next', 'scrubber', 'time', 'mute', 'volume', 'fullscreen'];
		private const SCRUBBER:String = "scrubber";
		
		
        public function Controlbar(player:Flowplayer, config:Config) {
			_player = player;
			_config = config;
		
            this.visible = false;
			_widgets = new Dictionary();

            rootStyle = _config.bgStyle;
			_bgFill = new Sprite();
			addChild(_bgFill);

            createChildren();
        }

		public static function get registeredControllers():Array {
			return Controlbar._registeredControllers;
		}

	
		private function addController(controllerClass:Class):void {
			if ( Controlbar._registeredControllers.indexOf(controllerClass) == -1 )
				Controlbar._registeredControllers.push(controllerClass);
			
			var controller:AbstractWidgetController = createWidgetController(controllerClass);
			_widgets[controller.name] = controller;
			// TimeView.EVENT_REARRANGE, onTimeViewRearranged
			controller.view.visible = false;
		}
		
		private function createWidgetController(controllerClass:Class):AbstractWidgetController {
			var config:Object = _config.getWidgetConfiguration(controllerClass);
			var controller:AbstractWidgetController = new controllerClass(config, _player, this);

			return controller;
		}
	

        private function createChildren():void {
            //log.error("creating createChildren ", _config);

			addController(ToggleFullScreenButtonController);
			addController(TogglePlayButtonController);
			addController(StopButtonController);
			addController(NextButtonController);
			addController(PrevButtonController);
			addController(StopButtonController);
			addController(ToggleMuteButtonController);
			addController(VolumeController);
			addController(TimeViewController);
			addController(ScrubberController);

			// now that we have registered all our controllers, clear config cache
			_config.clearCaches();
        }

		public function configure(config:Config, animation:Boolean = false):void {
			log.warn("Configuring new controls");
			_config = config;
			
			immediatePositioning = ! animation;
			
			for ( var i:String in _widgets ) {
				var widget:AbstractWidgetController = _widgets[i];
				var widgetConfig:Object = _config.getWidgetConfiguration(Object(widget).constructor);
			//	log.debug("Got config for widget " + widget.name, widgetConfig);
				widget.configure(widgetConfig);
			}
			
			enableWidgets();
			
			updateWidgetsVisibility();
			
			onResize();
			
			immediatePositioning = true;
		}
		
	
		
		// TODO : connect me somewhere :)
		private function onTimeViewRearranged(event:Event):void {
            onResize();
        }
		
	
		/** Visibility stuff **/
		
		private function enableWidgets():void {
			for ( var i:String in _widgets ) {
				(_widgets[i] as AbstractWidgetController).view.enabled = _config.enabled[i];
			}
        }
		
		private function updateWidgetsVisibility():void {
			
			for ( var i:String in _widgets ) {
				var controller:AbstractWidgetController = _widgets[i];
				var show:Boolean = _config.visible[i];
				
			//	log.debug("Getting visibility for " + i + " "+ show);
				
				// remove it
				if ( contains(controller.view) && ! show ) {
					log.debug("Removing "+ i)
					removeChildAnimate(controller.view);
				} else if ( ! contains(controller.view) && show ) {
					// add it
					log.debug("Adding "+ i);
					resetView(controller.view);
					addChild(controller.view);
				}
			}

		}
		
		private function resetView(view:DisplayObject):void {
			view.visible = false;
			view.x = view.y = 0;
			view.scaleX = view.scaleY = 1;
			view.alpha = 1;
		}

        private function removeChildAnimate(child:DisplayObject):DisplayObject {
            if (! _player || _immediatePositioning) {
                removeChild(child);
				resetView(child);
                return child;
            }
            _player.animationEngine.fadeOut(child, 1000, function():void {
                removeChild(child);
				resetView(child);
            });
            return child;
        }


		/* Widgets positionning stuff */
		
		 /**
         * Rearranges the buttons when size changes.
         */
        override protected function onResize():void {
            log.debug("arranging, width is " + width);

			_bgFill.graphics.clear();
			_bgFill.graphics.beginFill(0, 0);
			_bgFill.graphics.drawRect(0, 0, width, height);
			_bgFill.graphics.endFill();

			log.debug("----------------- onResize --------------");

			rearrangeWidgets();

			// TODO: Check me
			//_volumeSlider.initializeVolume();
            log.debug("arranged to x " + this.x + ", y " + this.y);
        }

        /**
         * Makes this visible when the superclass has been drawn.
         */
        override protected function onRedraw():void {
            log.debug("onRedraw, making controls visible");
            this.visible = true;
        }
		
		// not sure why we need this guy ?
		public function get animationTimerRunning():Boolean {
			return _animationTimer && _animationTimer.running;
		}


        private function set immediatePositioning(enable:Boolean):void {
            _immediatePositioning = enable;
            if (! enable) return;

			// not sure to know what this is about
            _animationTimer = new Timer(500, 1);
            _animationTimer.start();
        }
		
		
		private function rearrangeWidgets():void {
			
			var leftWidgets:Array = _widgetsOrder.slice(0, _widgetsOrder.indexOf(SCRUBBER));
			var rightWidgets:Array = _widgetsOrder.slice(_widgetsOrder.indexOf(SCRUBBER) + 1);
			
			if ( _config.visible.scrubber ) {
				var leftEdge:Number  = arrangeWidgets(leftWidgets);
				var rightEdge:Number = arrangeWidgets(rightWidgets, true);
				
				arrangeScrubber(leftEdge, rightEdge, nextVisibleWidget(SCRUBBER).view);
			} else {
				arrangeWidgets(_widgetsOrder);
			}
			
		}
		
		private function arrangeWidgets(widgets:Array, reverse:Boolean = false):Number {
			widgets = reverse ? widgets.reverse() : widgets;
			var x:Number = reverse ? width : _config.style.margins[3];
			
			for ( var i:int = 0; i < widgets.length; i++ ) {
				var widget:AbstractWidgetController = _widgets[widgets[i]];
				
				if ( ! _config.visible[widget.name] ) 
					continue;
				
				// some exception
				if ( widget.name == 'volume' )
					arrangeVolumeControl(widget.view)
				else
					arrangeYCentered(widget.view);
				
				var newX:Number = x + (widget.view.width + getSpaceAfterWidget(widget.name)) * (reverse ? -1 : 1);
				
				arrangeX(widget.view, reverse ? newX : x);
				
				x = newX;
			}
			
			return x;
		}

        private function arrangeVolumeControl(view:DisplayObject):void {
			view.width  = getVolumeSliderWidth();
            view.height = height - margins[0] - margins[2];
            view.y = margins[0];
        }
		
		private function get margins():Array {
            return _config.style.margins;
        }
		
		private function arrangeScrubber(leftEdge:Number, rightEdge:Number, nextToRight:DisplayObjectContainer):Number {
			var view:SurroundedWidget = (_widgets[SCRUBBER] as AbstractWidgetController).view as SurroundedWidget;
			
            view.setRightEdgeWidth(getScrubberRightEdgeWidth(nextToRight))
            arrangeX(view, leftEdge);
            var scrubberWidth:Number = rightEdge - leftEdge - 2 * getSpaceAfterWidget(SCRUBBER);
            if (! _player || _immediatePositioning) {
                view.width = scrubberWidth;
            } else {
                _player.animationEngine.animateProperty(view, "width", scrubberWidth);
            }
            view.height = height - margins[0] - margins[2];
            view.y = _height - margins[2] - view.height;
            return rightEdge - getSpaceAfterWidget(SCRUBBER) - scrubberWidth;
        }
		
		private function nextVisibleWidget(afterWidget:String):AbstractWidgetController {
			var widgets:Array = _widgetsOrder.slice(_widgetsOrder.indexOf(afterWidget) +1);
			for ( var i:int = 0; i < widgets.length; i++ )
				if ( _config.visible[widgets[i]] )
					return _widgets[widgets[i]];
			
			return null;
		}
		
		private function arrangeX(clip:DisplayObject, pos:Number):void {
			var a:AbstractSprite = clip as AbstractSprite
        //    log.debug("arrangeX " + a.name + " x:" + pos);
	
            clip.visible = true;
            if (! _player || _immediatePositioning) {
                clip.x = pos;
                return;
            }
            if (clip.x == 0) {
                // we are arranging a newly created widget, fade it in
                clip.x = pos;
                
				var currentAlpha:Number = 1;//clip.alpha;
	            clip.alpha = 0;

	            _player.animationEngine.animateProperty(clip, "alpha", currentAlpha);
            }
            // rearrange a previously arrange widget
            _player.animationEngine.animateProperty(clip, "x", pos);
        }

      

		private function arrangeYCentered(view:AbstractSprite):void {
			view.y = margins[0];
			
			var h:Number = height - margins[0] - margins[2];
			var w:Number =  h / view.height * view.width;
			view.setSize(w, h); 

			Arrange.center(view, 0, height);
		}

		private function getSpaceAfterWidget(name:String):int {
			if (nextVisibleWidget(name) == null) return _config.style.margins[1];
			return _config.spacing[name];
		}

		private function getScrubberRightEdgeWidth(nextWidgetToRight:DisplayObjectContainer):int {
			return SkinClasses.getScrubberRightEdgeWidth(nextWidgetToRight);
		}

		private function getVolumeSliderWidth():int {
			return SkinClasses.getVolumeSliderWidth();
		}
    }
}
