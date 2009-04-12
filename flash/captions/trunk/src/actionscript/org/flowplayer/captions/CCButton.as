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

        public function CCButton(player:Flowplayer) {
            createText(player);
            buttonMode = true;
            addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        }

        private function onMouseOver(event:MouseEvent):void {
            this.alpha = 1;
        }

        private function onMouseOut(event:MouseEvent = null):void {
            this.alpha = 0.8;
        }


        protected override function onResize():void {
            drawBackground();
            _text.x = 2;
            _text.y = 0;
            onMouseOut();
        }

        private function drawBackground():void {
            graphics.lineStyle(2, 0x555555);
            graphics.beginFill(0xeeeeee, 1);
            graphics.drawRoundRect(0, 0, width, height, 6, 6);
            graphics.endFill();
        }

        private function createText(player:Flowplayer):void {
            _text = player.createTextField(8, true);
            _text.text = "CC";
            _text.textColor = 0;
            addChild(_text);
            _text.selectable = false;
            _text.mouseEnabled = false;
        }
    }
}