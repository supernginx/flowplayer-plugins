package org.flowplayer.playlist.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import org.flowplayer.playlist.assets.PlaylistItem;

	import org.flowplayer.view.AnimationEngine;
	import org.flowplayer.view.FlowStyleSheet;
	import org.flowplayer.util.TextUtil;

    import org.flowplayer.ui.buttons.ButtonEvent;
    import org.flowplayer.ui.buttons.ToggleButton;
    import org.flowplayer.ui.controllers.AbstractToggleButtonController;

    import org.flowplayer.playlist.assets.PlaylistItem;



	public class PlaylistItemController extends AbstractToggleButtonController
	{
		private var _label:String;
		private var _isDown:Boolean;
		private var _style:FlowStyleSheet;
		private var _overArea:Sprite;
		private var _content:TextField;
		
		//public function PlaylistButton(label:String, config:ButtonConfig, animationEngine:AnimationEngine, style:FlowStyleSheet)
		public function PlaylistItemController()
        {
			//_label = label;
			//_style = style;
            super();
			//super(config, animationEngine);
		}

        override public function get name():String {
			return "playlist-off";
		}

		override public function get defaults():Object {
			return {
				tooltipEnabled: false,
				tooltipLabel: "HD is off",
				visible: true,
				enabled: false
			};
		}

        override protected function setDefaultState():void {
            (_widget as ToggleButton).setToggledColor(false);
        }

        override public function get downName():String {
			return "playlist-on";
		}

		override public function get downDefaults():Object {
			return {
				tooltipEnabled: false,
				tooltipLabel: "SD is on",
				visible: true,
				enabled: false
			};
		}
		
		override protected function get faceClass():Class {
			return PlaylistItem;
		}

		override protected function get downFaceClass():Class {
            return PlaylistItem;
		}

        override protected function onButtonClicked(event:ButtonEvent):void {
			//log.debug("HD button clicked");
			//_provider.hd = ! isDown;
		}

		/*public function reset():void {
			down = false;
			resetDispColor(_upStateFace.getChildByName(HIGHLIGHT_INSTANCE_NAME));
		} */

        /*
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
        }*/


	}
}