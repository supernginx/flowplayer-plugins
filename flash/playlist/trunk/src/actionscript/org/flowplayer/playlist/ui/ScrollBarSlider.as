package org.flowplayer.playlist.ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import org.flowplayer.playlist.config.Config;
	import org.flowplayer.playlist.config.SliderConfig;
	import org.flowplayer.view.AnimationEngine;
	import org.flowplayer.view.Flowplayer;
	
	/**
	 * @author api
	 */
	public class ScrollBarSlider extends AbstractSlider {
		public static const DRAG_EVENT:String = AbstractSlider.DRAG_EVENT;
		
		private var _volumeBar:Sprite;
		
		override public function get name():String {
			return "volume";
		}
		
		public function ScrollBarSlider(config:SliderConfig, player:Flowplayer, controlbar:DisplayObject) {
			super(config, player, controlbar);
			tooltipTextFunc = function(percentage:Number):String {
				if (percentage > 100) return "100%";
				if (percentage < 0) return "0%";
				return Math.round(percentage) + "%";
			};
		
			
			createBars();
		}
		
		private function createBars():void {
			_volumeBar = new Sprite();
			addChild(_volumeBar);
			swapChildren(_dragger, _volumeBar);
			value = _dragger.width - (_dragger.width / 2);
			//drawBar(_volumeBar, volumeColor, volumeAlpha, _config.gradient, 0, width - _dragger.width);
		}
		
		override public function configure(config:Object):void {
			super.configure(config);
			
			onSetValue();
		}
		
		override protected function onSetValue():void {
			//var pos:Number = value/100 * (width - _dragger.width);	
			var pos:Number = value;
			if ( pos < 0 )
				return;
			animationEngine.animateProperty(_dragger, "x", pos, 200);
			
			//trace(_dragger.x);
	
			drawBar(_volumeBar, volumeColor, volumeAlpha, _config.gradient, 0, width);
			
			_dragger.x = _dragger.width  / 2;
			_dragger.y = height / 2;
			
			
			
			//drawBar(_volumeBar, volumeColor, volumeAlpha, _config.gradient, 0, pos + _dragger.width / 2);
		}
		
		override protected function isToolTipEnabled():Boolean {
			return _config.draggerButtonConfig.tooltipEnabled;
		}
		
		protected function get volumeColor():Number {			
			if (isNaN(_config.color) || _config.color == -2 ) return backgroundColor;
			return _config.color;
		}
		
		protected function get volumeAlpha():Number {
			if (isNaN(_config.alpha) || _config.alpha == -2 ) return backgroundAlpha;
			return _config.alpha;
		}
	}
}