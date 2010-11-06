package org.flowplayer.playlist.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import org.flowplayer.playlist.assets.PlaylistItem;
	import org.flowplayer.ui.AbstractToggleButton;
	import org.flowplayer.ui.ButtonConfig;
	import org.flowplayer.view.AnimationEngine;
	import org.flowplayer.view.FlowStyleSheet;
	import org.flowplayer.util.TextUtil;



	public class PlaylistButton extends AbstractToggleButton
	{
		private var _label:String;
		private var _isDown:Boolean;
		private var _style:FlowStyleSheet;
		private var _overArea:Sprite;
		private var _content:TextField;
		
		public function PlaylistButton(label:String, config:ButtonConfig, animationEngine:AnimationEngine, style:FlowStyleSheet)
		{
			_label = label;
			_style = style;
			super(config, animationEngine);
		}
		
		override protected function onResize():void {
			_upStateFace.width = width;
			_upStateFace.height = height;
			
			_content.width = width;
			
			_overArea.graphics.clear();
            _overArea.graphics.beginFill(0,0);
            _overArea.graphics.drawRect(0, 0, width, height);
            _overArea.graphics.endFill();
		}
		
		override protected function createUpStateFace():DisplayObjectContainer {
			return new PlaylistItem();
		}
		
		override public function get isDown():Boolean {
			return  _isDown;
		}
		
		override public function set down(down:Boolean):void {
			if (isDown == down) return;
			log.error(down + "");
			_isDown = down;
		 }
		
		public function reset():void {
			down = false;
			resetDispColor(_upStateFace.getChildByName(HIGHLIGHT_INSTANCE_NAME));
		}

		override protected function onMouseOver(event:MouseEvent):void {

			if (!isDown) transformDispColor(_upStateFace.getChildByName(HIGHLIGHT_INSTANCE_NAME));
		}
		
		override protected function onMouseOut(event:MouseEvent = null):void {
			if (!isDown) resetDispColor(_upStateFace.getChildByName(HIGHLIGHT_INSTANCE_NAME));
		}
		
		override protected function onMouseDown(event:MouseEvent):void {

			if (_isDown) {
				resetDispColor(_upStateFace.getChildByName(HIGHLIGHT_INSTANCE_NAME));
				_isDown = false;
			} else {
				transformToggleDispColor(_upStateFace.getChildByName(HIGHLIGHT_INSTANCE_NAME));
				
				_isDown = true;
			}
		}
		
		override protected function childrenCreated():void {

            _content = TextUtil.createTextField(false, "Arial", 12);
            
            //var content:TextField = _upStateFace.getChildByName("playlistContent") as TextField;
            _content.selectable = false;
            _content.textColor = 0xFFFFFF;
            _content.htmlText = _label;
            _content.wordWrap = true;
           
            addChild(_content);
            
            _overArea = new Sprite();
            addChild(_overArea);
		}
		
		public function content():TextField {
			return _content;
		}
		
		override protected function doEnable(enabled:Boolean):void {
            registerEventListeners(enabled, _overArea);
        }


	}
}