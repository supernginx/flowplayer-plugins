/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2009 AdoTube
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
 package com.adotube.adapter {
	import flash.events.*;
	import flash.display.*;
	import flash.utils.Timer;
 	
	import org.flowplayer.model.PluginModel;
	import org.flowplayer.view.Flowplayer;	
	import org.flowplayer.model.Clip;

	public class OPWrapper extends MovieClip {

		private var model:PluginModel;
		private var plugin:MovieClip;
		private var player:Flowplayer;
		
		var playbackDuration:Number;
		var playbackTime:Number;
		var playerVolume:Number;
		var playerState:String;
		var checkForChange:Timer;
		
		public function OPWrapper(player:Flowplayer, model:PluginModel, plugin:MovieClip) {
			this.player = player;
			this.model = model;
			this.plugin = plugin;
			this.addChild(plugin);
			init();			
		}
		
		
		function init():void {
			plugin.onPlayerVolumeChanged(player.volume);
			
			checkForChange = new Timer(30);
			checkForChange.addEventListener("timer",checkPlayer);
			checkForChange.start();
		}
		
		public function onResize(width:Number, height:Number):void {
			plugin.onLayoutSizeChanged(width, height);
		}
		
		//////////////////////// Plugin Callback Methods //////////////////////		
		public function getPlaybackTime():Number {
			var tempTime:Number;
			if (player) {
				tempTime = player.status.time;
			}
			if (!tempTime) {
				tempTime = 0;
			}
			return tempTime;
		}
		
		public function requestPlayerPause():void {
			player.pause();
			trace("[Flowplayer][Adotube Plugin] requestPlayerPause().");
		}
		
		public function requestPlayerPlay():void {
			player.resume();
			trace("[Flowplayer][Adotube Plugin] requestPlayerPlay().");
		}
		
		public function requestPlayerStream(streamURL:String,duration:Number):void {
			player.play(Clip.create(streamURL));
			trace("[Flowplayer][Adotube Plugin] requestPlayerStream().");			
		}
		private function checkPlayer(event:TimerEvent):void {
			var tempState:String = checkState();
			if (tempState) {
				if (playerState != tempState) {
					if (plugin) {
						playerState = tempState;
						trace("++++"+tempState);
						plugin.onPlayerStateChanged(playerState);
					}
				}
			};
			var tempDuration:Number = checkDuration();
			if (tempDuration) {
				if (playbackDuration !=tempDuration) {
					playbackDuration = tempDuration;
					plugin.onPlaybackDurationAvailable(playbackDuration);
				}
			}
		}
		private function checkState():String {
			var tempState:String;
			if (player) {
				if (player.isPlaying()) {
					tempState = "playing";
				} else {
					tempState = "paused";
				}
			} else {
				//Warning! Player has not loaded!
			}
			return tempState;
		}
		private function checkDuration():Number{
			var returned:Number;
			if (player) {
				if (player.currentClip.duration) {
					returned = player.currentClip.duration;
				}
			}
			return returned;
		}
	}
}
