/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.shareembed {
    import flash.events.FocusEvent;
    import flash.text.AntiAliasType;
    import flash.text.TextField;

    import flash.text.TextFieldAutoSize;

    import flash.text.TextFieldType;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.util.StyleSheetUtil;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.StyleableSprite;

    public class StyleableView extends StyleableSprite {
        protected const PADDING_X:int = 20;
        protected const PADDING_Y:int = 3;
        protected const PADDING_Y_TALL:int = 6;
        protected const MARGIN_Y:int = 10;
        protected const MARGIN_X:int = 10;

        private var _model:DisplayPluginModel;
        private var _player:Flowplayer;

        public function StyleableView(styleName:String, plugin:DisplayPluginModel, player:Flowplayer, style:Object) {
            super(styleName, player, player.createLoader());
            rootStyle = style;
            css(style);
            _player = player;
            _model = plugin;
        }

        protected function get model():DisplayPluginModel {
            return _model;
        }

        protected function get player():Flowplayer {
            return _player;
        }

        public function show():void {
            this.visible = true;
            this.alpha = 1;
        }

        protected function createLabelField():TextField {
            var field:TextField = player.createTextField();
            field.selectable = false;
            field.focusRect = false;
            field.tabEnabled = false;
            field.autoSize = TextFieldAutoSize.LEFT;
            field.antiAliasType = AntiAliasType.ADVANCED;
            field.height = 15;

            field.styleSheet = style.styleSheet;
            return field;
        }

        protected function get inputFieldBackgroundColor():String {
            return style.getStyle(".input").backgroundColor as String;
        }

        protected function get inputFieldTextColor():String {
            return style.getStyle(".input").color as String;
        }

        protected function createInputField(selectTextOnFocus:Boolean = true):TextField {
            var field:TextField = player.createTextField();

            field.addEventListener(FocusEvent.FOCUS_IN, function(event:FocusEvent):void {
                var field:TextField = event.target as TextField;
//                field.borderColor = 0xCCFFCC;
                if (selectTextOnFocus) {
                    var text:String = field.text;
                    if (text && text.length > 0) {
                        field.setSelection(0, text.length);
                        field.scrollH = field.scrollV = 0;
                    }
                }
            });
            field.addEventListener(FocusEvent.FOCUS_OUT, function(event:FocusEvent):void {
                var field:TextField = event.target as TextField;
//                field.borderColor = 0xffffff;
                if (selectTextOnFocus) {
                    field.setSelection(0, 0);
                }
            });

            field.type = TextFieldType.INPUT;
            field.alwaysShowSelection = true;
            field.antiAliasType = AntiAliasType.ADVANCED;
            field.background = true;
            field.tabEnabled = true;
            field.textColor = 0;
            field.height = 20;
            field.backgroundColor = StyleSheetUtil.colorValue(inputFieldBackgroundColor);
            field.alpha = StyleSheetUtil.colorAlpha(inputFieldBackgroundColor);
            field.textColor = StyleSheetUtil.colorValue(inputFieldTextColor);
            return field;
        }
    }

}