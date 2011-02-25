/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009-2011 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.slowmotion {
    import flash.net.NetStream;
    import flash.utils.Dictionary;
	import flash.utils.*;
	import flash.events.*;
	import flash.display.Loader;
	import org.flowplayer.layout.LayoutEvent;
	
	import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginError;
    import org.flowplayer.model.PluginModel;
	import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.util.Log;
    import org.flowplayer.view.Flowplayer;
	import org.flowplayer.util.PropertyBinder;
	
	import org.flowplayer.ui.containers.WidgetContainer;
	import org.flowplayer.ui.containers.WidgetContainerEvent;
	
	import org.flowplayer.ui.controllers.GenericButtonController;
	
	import fp.*;

    public class SlowMotion implements Plugin {
        private var log:Log = new Log(this);
        private var _provider:StreamProvider;
        private var _model:PluginModel;
        private var _player:Flowplayer;
        private var _timeProvider:SlowMotionTimeProvider;
		private var _config:Config;
        private var _providerName:String;

		private var _speedIndicator:PluginModel;
		private var _speedIndicatorTimer:Timer;
		
		private var _requestedSpeed:Number;

        public function onConfig(model:PluginModel):void {
            _model = model;
			_config = new PropertyBinder(new Config(), null).copyProperties(model.config) as Config;
        }

        public function onLoad(player:Flowplayer):void {
            log.debug("onLoad()");
            _player = player;
			_requestedSpeed = 1;
			
			var handler:Function = function(event:KeyboardEvent, increaseSpeed:Boolean):void {
				if ( ! event.ctrlKey )	{
                    log.debug("control key not pressed");
                    return;
                }
				
				var nextSpeed:Number = getClosestSpeed(increaseSpeed);
				log.warn("Speeding now at "+ nextSpeed);
				forward(nextSpeed);
			};
			
			var fastmotion:Function = function(event:KeyboardEvent):void {};
			_player.addKeyListener(Keyboard.RIGHT, 	function(event:KeyboardEvent):void { handler(event, true); });
			_player.addKeyListener(76, 				function(event:KeyboardEvent):void { handler(event, true); }); 
			_player.addKeyListener(Keyboard.LEFT, 	function(event:KeyboardEvent):void { handler(event, false); }); 
			_player.addKeyListener(72, 				function(event:KeyboardEvent):void { handler(event, false); });
			
            try {
                lookupProvider(player.pluginRegistry.providers);
            } catch (e:Error) {
                _model.dispatchError(PluginError.INIT_FAILED, "Failed to lookup a RTMP plugin: " + e.message);
                return;
            }
            log.debug("Found RTMP provider " + _provider);

            _timeProvider = new SlowMotionTimeProvider(_model, _provider, _providerName, _player.playlist);
            _provider.timeProvider = _timeProvider;

			var resetSpeed:Function = function(event:ClipEvent):void {
				_requestedSpeed = 1;
			};
			
			_player.playlist.onSeek(resetSpeed);
			_player.playlist.onStop(resetSpeed);
			_player.playlist.onFinish(resetSpeed);
			_player.playlist.onPlaylistReplace(resetSpeed);

            lookupSpeedIndicator();

			var controlbar:* = player.pluginRegistry.plugins['controls'];
			controlbar.pluginObject.addEventListener(WidgetContainerEvent.CONTAINER_READY, addButtons);
			
			
            _model.dispatchOnLoad();
        }

		private function addButtons(event:WidgetContainerEvent):void {
			var container:WidgetContainer = event.container;
			
			var FBwdButtonController:GenericButtonController = new GenericButtonController("slowMotionFBwd", fp.SlowMotionFBwdButton, {
				enabled: true,
				visible: true,
				tooltipEnabled : true,
				tooltipLabel: 'Fast Backward'
			}, function():void {
				log.info("Fast backward clicked");
				onSlowMotionClicked(true, false);
			}, "slowmotion");
			
			var bwdButtonController:GenericButtonController = new GenericButtonController("slowMotionBwd", fp.SlowMotionBwdButton, {
				enabled: true,
				visible: true,
				tooltipEnabled : true,
				tooltipLabel: 'Slow Backward'
			}, function():void {
				log.info("Slow backward clicked");
				onSlowMotionClicked(false, false);
			}, "slowmotion");
			
			var fwdButtonController:GenericButtonController = new GenericButtonController("slowMotionFwd", fp.SlowMotionFwdButton, {
				enabled: true,
				visible: true,
				tooltipEnabled : true,
				tooltipLabel: 'Slow Forward'
			}, function():void {
				log.info("Slow Forward clicked");
				onSlowMotionClicked(false, true);
			}, "slowmotion");
			
			var FFwdButtonController:GenericButtonController = new GenericButtonController("slowMotionFFwd", fp.SlowMotionFFwdButton, {
				enabled: true,
				visible: true,
				tooltipEnabled : true,
				tooltipLabel: 'Fast Forward'
			}, function():void {
				log.info("Fast Forward clicked");
				onSlowMotionClicked(true, true);
			}, "slowmotion");
			
			container.addWidget(FBwdButtonController, "stop", false);
			container.addWidget(bwdButtonController, "slowMotionFBwd", false);
			container.addWidget(fwdButtonController, "play", false);
			container.addWidget(FFwdButtonController, "slowMotionFwd", false);
		}
		
		private function onSlowMotionClicked(fast:Boolean, goForward:Boolean):void
		{
			var nextSpeed:Number = getNextSpeed(fast, goForward);
				
			if ( nextSpeed == 0 )
				normal();
			else if ( goForward )
				forward(nextSpeed);
			else
				backward(nextSpeed);
		}

        [External]
        public function forward(multiplier:Number = 4, fps:Number = -1):void {
            log.debug("forward()");
            if (multiplier == 1) {
                normal();
                return;
            }

			_requestedSpeed = multiplier;
            setFastPlay(multiplier, fps, 1);
        }

        [External]
        public function backward(multiplier:Number = 4, fps:Number = -1):void {
            log.debug("backward()");

			_requestedSpeed = -multiplier;
            setFastPlay(multiplier, fps, -1);
        }

        [External]
        public function normal():void {
            log.debug("normal()");

			_requestedSpeed = 1;
			showSpeedIndicator(1, 0);
            _provider.netStream.seek(_timeProvider.getTime(netStream));
        }

        [External]
        public function get info():SlowMotionInfo {
            return _timeProvider.info();
        }

        private function setFastPlay(multiplier:Number, fps:Number, forward:int):void {
			showSpeedIndicator(multiplier, forward);
            var targetFps:Number = fps > 0 ? fps : multiplier * 50;
            _provider.netConnection.call("setFastPlay", null, multiplier, targetFps, forward);
            _provider.netStream.seek(_timeProvider.getTime(netStream));
        }

        private function setProvider(model:PluginModel):void {
            _providerName = model.name;
            _provider = model.pluginObject as StreamProvider;
        }

        private function lookupProvider(providers:Dictionary):void {
            log.debug("lookupProvider() " + providers);
            if (_model.config && _model.config["provider"]) {
                var model:PluginModel = _player.pluginRegistry.getPlugin(_model.config["provider"]) as PluginModel;
                if (! model) throw new Error("Failed to find plugin '" + _model.config["provider"] + "'");
                if (! (model.pluginObject is StreamProvider)) throw new Error("The specified provider is not a StreamProvider");
                setProvider(model);
                return;
            }
            for each (model in providers) {
                log.debug(model.name);
                if (model.name == "rtmp") {
                    setProvider(model);
                    return;
                }
                if (["http", "httpInstream"].indexOf(model.name) < 0 && model.pluginObject is StreamProvider) {
                    setProvider(model);
                    return;
                }
            }
        }

		private function lookupSpeedIndicator():void
		{
			_speedIndicator = _player.pluginRegistry.getPlugin(_config.speedIndicator) as PluginModel;
            log.debug("lookupSpeedIndicator() " + _speedIndicator ? "found speed indicator" : "speed indicator not present");

			if ( _speedIndicator && getQualifiedClassName(_speedIndicator.pluginObject) != 'org.flowplayer.content::Content' )
				throw new Error("The specified speedIndicator is not a Content plugin");
						
			_speedIndicatorTimer = new Timer(_config.speedIndicatorDelay, 1);
			_speedIndicatorTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void { 
				if ( _speedIndicator )
					_player.hidePlugin(_speedIndicator.name);
			});
		}

		private function showSpeedIndicator(multiplier:Number, forward:int):void
		{
			if ( ! _speedIndicator )
				return;

			var label:String = getSpeedIndicatorLabel(multiplier, forward);
			_speedIndicator.pluginObject.html = label;

			_speedIndicatorTimer.reset();
			_player.showPlugin(_speedIndicator.name);

			_speedIndicatorTimer.start();
		}

		private function getSpeedIndicatorLabel(multiplier:Number, forward:int):String
		{
			var label:String = '';
			if ( multiplier == 1 )
				label = _config.normalLabel;
			else if ( multiplier > 1 && forward > 0 )
				label = _config.fastForwardLabel;
			else if ( multiplier < 1 && forward > 0 )
				label = _config.slowForwardLabel;
			else if ( multiplier > 1 && forward < 0 )
				label = _config.fastBackwardLabel;
			else label = _config.slowBackwardLabel;

			if ( label.indexOf('{speed}') != -1 )
			{
				var multiplierAsString:String = null;
				if ( multiplier >= 1 )
					multiplierAsString = String(multiplier);
				else
				{
					for ( var i:int = 1; i <= 25; i++ )
					{
						if ( 1/i == multiplier )
						{
							multiplierAsString = '1/'+ String(i);
							break;
						}
					}

					if ( multiplierAsString == null )
						multiplierAsString = String(Math.round(multiplier*1000)/1000);
				}
				
				label = label.replace(/\{speed\}/ig, multiplierAsString);
			}

			return label;
		}


        public function getDefaultConfig():Object {
            return null;
        }

        private function get netStream():NetStream {
            return _provider.netStream;
        }

		public function getClosestSpeed(increaseSpeed:Boolean):Number {
			var speeds:Array = [1/8, 1/4, 1/2, 1, 2, 4, 8];
			
			log.debug("Current speed is "+ _requestedSpeed);
			
			var normalizedSpeedIndex:int = 0;
			if ( _requestedSpeed <= speeds[0] )
				normalizedSpeedIndex = 0;
			else if ( _requestedSpeed >= speeds[speeds.length -1] )
				normalizedSpeedIndex = speeds.length -1;
			else {	// we are somewhere between
				for ( var i:Number = 0; i < speeds.length - 2; i++ ) {
				//	log.debug("checking if "+_requestedSpeed+" >= "+ speeds[i] + " && "+ _requestedSpeed + " <= "+ speeds[i+1]); 
					if ( _requestedSpeed >= speeds[i] && _requestedSpeed <= speeds[i+1] ) {
						normalizedSpeedIndex = i+1;
						break;
					}
				}
			}
			
			log.debug("Current speed index "+ normalizedSpeedIndex + " = "+ speeds[normalizedSpeedIndex]);
			
			if ( (increaseSpeed && normalizedSpeedIndex == speeds.length -1) || (! increaseSpeed && normalizedSpeedIndex == 0) )
				return speeds[normalizedSpeedIndex];
			else 
				return speeds[normalizedSpeedIndex + (increaseSpeed ? 1 : -1)];			
		}

		public function getNextSpeed(fast:Boolean, goForward:Boolean):Number {
			var fastSpeeds:Array = [2, 4, 8, 1];
			var slowSpeeds:Array = [1/2, 1/4, 1/8, 1];
			
			var currentSpeed:Number = _requestedSpeed > 0 ? _requestedSpeed : -_requestedSpeed;
			var isForward:Boolean   = _requestedSpeed > 0;
			
			var nextSpeed:Number = 1;
			
			if ( goForward == isForward )	// same direction
			{
				if ( fast ) // fast
					nextSpeed   = fastSpeeds[((fastSpeeds.indexOf(currentSpeed)+1)%fastSpeeds.length)];
				else  // slow
					nextSpeed   = slowSpeeds[((slowSpeeds.indexOf(currentSpeed)+1)%slowSpeeds.length)];
			}
			else if ( fast )
				nextSpeed = fastSpeeds[0];
			else
				nextSpeed = slowSpeeds[0];
				
			log.debug("Next speed "+ nextSpeed + " forward ? "+ goForward);
			
			return nextSpeed;
		}
    }
}