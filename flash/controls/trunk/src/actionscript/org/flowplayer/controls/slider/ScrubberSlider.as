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
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.*;

    import org.flowplayer.controls.config.Config;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.ClipType;
    import org.flowplayer.model.Playlist;
    import org.flowplayer.model.PluginEvent;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.model.Status;
    import org.flowplayer.util.GraphicsUtil;
    import org.flowplayer.view.AnimationEngine;
    import org.flowplayer.view.Flowplayer;

    /**
	 * @author api
	 */
	public class ScrubberSlider extends AbstractSlider {
		
		private var _bufferEnd:Number;
		private var _bufferBar:Sprite;
		private var _allowRandomSeek:Boolean;
		private var _seekInProgress:Boolean;
		private var _progressBar:Sprite;
		private var _bufferStart:Number;
		private var _enabled:Boolean = true;
        private var _startDetectTimer:Timer;
        private var _trickPlayTrackTimer:Timer;
        private var _slowMotionInfo:Object;

		private var _currentClip:Clip;

        public function ScrubberSlider(config:Config, animationEngine:AnimationEngine, controlbar:DisplayObject) {
            super(config, animationEngine, controlbar);
            lookupPluginAndBindEvent(config.player, "slowmotion", onSlowMotionEvent);
            lookupPluginAndBindEvent(config.player, "audio", onAudioEvent);
            createBars();
            addPlaylistListeners(config.player.playlist);
        }

        private function lookupPluginAndBindEvent(player:Flowplayer, pluginName:String, eventHandler:Function):void {
            var plugin:PluginModel = player.pluginRegistry.getPlugin(pluginName) as PluginModel;
            if (plugin) {
                log.debug("found plugin " +plugin);
                plugin.onPluginEvent(eventHandler);
            }
        }

        public function addPlaylistListeners(playlist:Playlist):void {
            playlist.onStart(setSeekDone);
            playlist.onBeforeSeek(setSeekBegin);
            playlist.onSeek(setSeekDone);
			
            playlist.onBegin(function(event:ClipEvent):void {
                _currentClip = event.target as Clip;
            });
            playlist.onResume(function(event:ClipEvent):void {
                _currentClip = event.target as Clip;
            });
			
            playlist.onStart(start);

            playlist.onResume(resume);

            playlist.onPause(stop);

            // cannot have this, causes trouble!
//            playlist.onBufferEmpty(stop);

            playlist.onStop(stopAndRewind);
            playlist.onFinish(stopAndRewind);
            
            playlist.onBeforeSeek(beforeSeek);
            playlist.onSeek(seek);
        }

        private function onSlowMotionEvent(event:PluginEvent):void {
            log.debug("onSlowMotionEvent()");
            _slowMotionInfo = event.info2;
            stop(null);

            if (! isTrickPlay) {
                stopTrickPlayTracking();
                doStart(_slowMotionInfo["clip"], adjustedTime(_config.player.status.time));

            } else {
                startTrickPlayTracking();
            }
        }

        private function onAudioEvent(event:PluginEvent):void {
            log.debug("onAudioEvent()");
            stop(null);
            doStart(_config.player.playlist.current);

        }

        private function stopTrickPlayTracking():void {
            if (_trickPlayTrackTimer) {
                _trickPlayTrackTimer.stop();
            }
        }

        private function startTrickPlayTracking():void {
            stopTrickPlayTracking();
            _trickPlayTrackTimer = new Timer(200);
            _trickPlayTrackTimer.addEventListener(TimerEvent.TIMER, onTrickPlayProgress);
            _trickPlayTrackTimer.start();
        }

        private function onTrickPlayProgress(event:TimerEvent):void {
            updateDraggerPos(_config.player.status.time, _slowMotionInfo["clip"] as Clip);
        }

		protected override function onResize():void {
			super.onResize();
			
			doDrawBufferBar(0, 0);
			drawProgressBar(0, 0);
			
			if ( _currentClip )
			{
				stop(null);
				updateDraggerPos(_config.player.status.time, _currentClip);
				doStart(_currentClip, _config.player.status.time);
			}
			
        }

        private function beforeSeek(event:ClipEvent):void {
            log.debug("beforeSeek()");
            if (event.isDefaultPrevented() ) {
				log.debug("Default prevented ")
				stop(null);
				updateDraggerPos(_config.player.status.time, event.target as Clip);
				doStart(event.target as Clip, _config.player.status.time);
				return;
			}

			
            updateDraggerPos(event.info as Number, event.target as Clip);
            stop(null);

			doDrawBufferBar(0, 0);
        }

        private function updateDraggerPos(time:Number, clip:Clip):void {
           	_dragger.x = (time / clip.duration) * (width - _dragger.width);            
        }

        private function seek(event:ClipEvent):void {
            log.debug("seek(), isPlaying: " + _config.player.isPlaying() + ", seek target time is " + event.info);
            if (! _config.player.isPlaying()) return;
			
			_currentClip = (event.target as Clip);
            doStart(_currentClip, event.info as Number);
        }

        private function start(event:ClipEvent):void {
			_currentClip = (event.target as Clip);
            log.debug("start() " + _currentClip);
            if (_currentClip.duration == 0 && _currentClip.type == ClipType.IMAGE) return;
			stop(null);
            doStart(_currentClip);
        }

        private function resume(event:ClipEvent):void {
            log.debug("resume() " + event.target);
			_currentClip = (event.target as Clip);
			stop(null);
            doStart(_currentClip);
        }

        private function doStart(clip:Clip, startTime:Number = 0):void {
            log.debug("doStart() " + clip);
            if (isTrickPlay) {
                log.debug("doStart(), trickplay in progress, returning");
                return;
            }

            var status:Status = _config.player.status;
            var time:Number = startTime > 0 ? startTime : status.time;

            if (! _config.player.isPlaying()) {
                log.debug("doStart(), not playing, returning");
                return;
            }
            if (_startDetectTimer && _startDetectTimer.running) {
                log.debug("doStart(), not playing, returning");
                return;
            }
            if (animationEngine.hasAnimationRunning(_dragger)) {
                log.debug("doStart(), animation already running, returning");
                return;
            }

            _startDetectTimer = new Timer(200);
            _startDetectTimer.addEventListener(TimerEvent.TIMER,
                    function(event:TimerEvent):void {
                        log.debug("on startDetectTimer()");
                        var currentTime:Number = _config.player.status.time;
                        if (Math.abs(currentTime - time) > 0.2) {
                            _startDetectTimer.stop();
                            var endPos:Number = width - _dragger.width;
                            var duration:Number = (clip.duration - time) * 1000;  
                            log.debug("doStart(), starting an animation to x pos " + endPos + ", the duration is " + clip.duration + ", current pos is " + _dragger.x);
                            updateDraggerPos(currentTime, clip);
//                            animationEngine.cancel(_dragger);
                            animationEngine.animateProperty(_dragger, "x", endPos, duration, null,
                                    function():void {
                                        drawProgressBar(_bufferStart * width);
                                    },
                                    function(t:Number, b:Number, c:Number, d:Number):Number {
                                        return c * t / d + b;
                                    });
                        } else {
                            log.debug("not started yet, currentTime " + currentTime + ", time " + time);
                        }
                    });
            log.debug("doStart(), starting timer");
            _startDetectTimer.start();
        }

        private function adjustedTime(time:Number):Number {
            if (! _slowMotionInfo) return time;
            if (_slowMotionInfo) {
                log.debug("adjustedTime: " + _slowMotionInfo["adjustedTime"](time));
                return _slowMotionInfo["adjustedTime"](time);
            }
            return time;
        }

        private function get isTrickPlay():Boolean {
            return _slowMotionInfo && _slowMotionInfo["isTrickPlay"]; 
        }

        private function stop(event:ClipEvent):void {
            log.debug("stop()");
            if (_startDetectTimer) {
                _startDetectTimer.stop();
            }
            animationEngine.cancel(_dragger);
        }

        private function stopAndRewind(event:ClipEvent):void {
            var clip:Clip = event.target as Clip;
            log.debug("stopAndRewind() " + clip);

            stop(event);
            if (clip.isMidroll) {
                log.debug("midroll stopped, not rewinding to beginning");
                return;
            }

            _dragger.x = 0;

            clearBar(_progressBar);
        }

		override protected function get dispatchOnDrag():Boolean {
			return false;
		}

		override protected function getClickTargets(enabled:Boolean):Array {
			_enabled = enabled;
			var targets:Array = [_bufferBar, _progressBar];
			if (! enabled || _allowRandomSeek) {
				targets.push(this);
			}
			return targets;
		}
		
		override protected function isToolTipEnabled():Boolean {
			return _config.tooltips && _config.tooltips.scrubber;
		}

		private function doDrawBufferBar(leftEdge:Number, rightEdge:Number):void {
			drawBar(_bufferBar, _config.style.bufferColor, _config.style.bufferAlpha, _config.style.bufferGradient, leftEdge, rightEdge);
		}
		
		private function drawProgressBar(leftEdge:Number, rightEdge:Number = 0):void {
			drawBar(_progressBar, _config.style.progressColor, _config.style.progressAlpha, _config.style.progressGradient, leftEdge || 0, rightEdge || _dragger.x + _dragger.width - 2);
		}

		override protected function get sliderAlpha():Number {
            return _config.style.sliderAlpha;
        }

		override protected function get borderWidth():Number {
			return _config.style.sliderBorderWidth;
		}
		
		override protected function get borderColor():Number {
			return _config.style.sliderBorderColor;
		}
		
		override protected function get borderAlpha():Number {
			return _config.style.sliderBorderAlpha;
		}

		private function createBars():void {
			_progressBar = new Sprite();
			addChild(_progressBar);
			
			_bufferBar = new Sprite();
			addChild(_bufferBar);
			swapChildren(_dragger, _bufferBar);
		}
		
//
//		override protected function onSetValue():void {
//			if (_seekInProgress) return;
//			drawProgressBar(_bufferStart * width);
//		}

		

		public function set allowRandomSeek(value:Boolean):void {
			_allowRandomSeek = value;
			if (_enabled) {
				if (value) {
					addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				} else {
					removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				}
				buttonMode = _allowRandomSeek;
			}
		}

		override internal function get maxDrag():Number {
			if (_allowRandomSeek) return width - _dragger.width;
			return _bufferEnd * (width - _dragger.width);
		}

		public function setBufferRange(start:Number, end:Number):void {
			_bufferStart = start;
			_bufferEnd = Math.min(end, 1);
			drawBufferBar();
		}
		
		override protected function canDragTo(xPos:Number):Boolean {
			if (_allowRandomSeek) return true;
			return xPos < _bufferBar.x + _bufferBar.width;
		}

		override protected function onDispatchDrag():void {
			drawBufferBar();
			_seekInProgress = true;
		}

        private function drawBufferBar():void {
            if (_seekInProgress)  {
                log.debug("drawBars(): seek in progress");
                return;
            }
            if (_dragger.x + _dragger.width / 2 > _bufferStart * width) {
                doDrawBufferBar(_bufferStart * width, _bufferEnd * width);
//                drawProgressBar(_bufferStart * width);
            } else {
                clearBar(_bufferBar);
//                _progressBar.graphics.clear();
//                GraphicsUtil.removeGradient(_progressBar);
            }
        }

        private function clearBar(bar:Sprite):void {
            bar.graphics.clear();
            GraphicsUtil.removeGradient(bar);
        }

        private function setSeekBegin(event:ClipEvent):void {
            log.debug("onBeforeSeek");
            _seekInProgress = ! event.isDefaultPrevented();
        }

		private function setSeekDone(event:ClipEvent):void {
			log.debug("seek done! target " + event.info);
			_seekInProgress = false;
		}

		override protected function get allowSetValue():Boolean {
			return ! _seekInProgress;
		}
		
		override public function redraw(config:Config):void {
			super.redraw(config);
			drawBar(_progressBar, _config.style.progressColor, _config.style.progressAlpha, _config.style.progressGradient, _progressBar.x, _progressBar.width);
			drawBar(_bufferBar, _config.style.bufferColor, _config.style.bufferAlpha, _config.style.bufferGradient, _bufferBar.x, _bufferBar.width);
		}

        override protected function get barHeight():Number {
            return Math.ceil(height * _config.style.scrubberBarHeightRatio);

        }

        override protected function get sliderGradient():Array {
            return _config.style.sliderGradient;
        }

        override protected function get sliderColor():Number {
            return _config.style.sliderColor;
        }

        override protected function get barCornerRadius():Number {
            if (isNaN(_config.style.scrubberBorderRadius)) return super.barCornerRadius;
            return _config.style.scrubberBorderRadius;
        }
//
        override protected function onDragging():void {
            stop(null);
            drawProgressBar(_bufferStart * width);
        }
	}
}
