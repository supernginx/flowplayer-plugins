package org.flowplayer.playlist.config
{
	import org.flowplayer.util.StyleSheetUtil;
	import org.flowplayer.ui.buttons.TooltipButtonConfig;

	
	public class SliderConfig extends BorderedWidgetConfig {
		private var _color:String;
		private var _gradient:Array;
		
		private var _barHeightRatio:Number;
		private var _draggerButtonConfig:TooltipButtonConfig;
		
		private var _enabled:Boolean = true;
		
		/*
		* Color.
		*/
		
		public function get color():Number {
			return StyleSheetUtil.colorValue(_color);
		}
		
		public function get alpha():Number {
			return StyleSheetUtil.colorAlpha(_color);
		}
		
		public function setColor(color:String):void {
			_color = color;
		}
		
		public function get gradient():Array {
			return _gradient;
		}
		
		public function setGradient(gradient:Array):void {
			_gradient = gradient;
		}
		
		public function get barHeightRatio():Number {
			return _barHeightRatio;
		}
		
		public function setBarHeightRatio(ratio:Number):void {
			_barHeightRatio = ratio;
		}
		
		public function get draggerButtonConfig():TooltipButtonConfig {
			return _draggerButtonConfig;
		}
		
		public function setDraggerButtonConfig(config:TooltipButtonConfig):void {
			_draggerButtonConfig = config;
		}
		
		/*
		* Enabled 
		*/
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function setEnabled(value:Boolean):void {
			_enabled = value;
		}
	}

}