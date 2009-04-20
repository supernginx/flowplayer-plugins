/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *Copyright (c) 2008, 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.captions {
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;

    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.Flowplayer;

    public class CCButton extends AbstractSprite {
        private var _text:TextField;
        private var _hitArea:Sprite;
        private var _textColor:Number;
        private var _label:String;

        public function CCButton(player:Flowplayer, label:String) {
            _label = label;
            createText(player);
            buttonMode = true;
            isDown = true;
        }

        protected override function onResize():void {
            drawBackground();
            _text.x = 2;
            _text.y = 0;
        }

        private function drawBackground():void {
            graphics.clear(),
            graphics.lineStyle(2, 0x555555);
            graphics.beginFill(0xaaaaaa, 1);
            graphics.drawRoundRect(0, 0, width, height, 6, 6);
            graphics.endFill();
        }

        private function createText(player:Flowplayer):void {
            _text = player.createTextField(8, true);
            _text.text = _label;
            _text.textColor = _textColor;
            addChild(_text);
            _text.selectable = false;
            _text.mouseEnabled = false;
        }

        public function set isDown(isDown:Boolean):void {
            _textColor = isDown ? 0 : 0xff2222;
            _text.textColor = _textColor;
        }

    }
}