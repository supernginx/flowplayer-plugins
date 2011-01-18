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
package org.flowplayer.ui {
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.text.AntiAliasType;
    import flash.text.TextField;

    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.utils.Timer;

    import org.flowplayer.util.Arrange;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.StyleableSprite;


    /**
     * Creates a notification message that is shown in the player area. Usage example:
     * 
     * new Notification(player, "Hello world!").show().autoHide();
     */
    public class Notification extends StyleableSprite {
        private var _player:Flowplayer;
        private var _field:TextField;
        private var _hideTimer:Timer;

        public function Notification(player:Flowplayer, message:String) {
            super();
            super.rootStyle = { backgroundGradient: [ 0.1, 0.2 ], border: 'none' };
            _player = player;
            createTextField(player, message);
            addClickListener();
            this.width = 100;
        }

        private function addClickListener():void {
            addEventListener(MouseEvent.CLICK, createClickListener(_player, this));
        }

        private function createClickListener(player:Flowplayer, disp:DisplayObject):Function {
            return function(event:MouseEvent):void {
                log.debug("hiding Notification");
                player.animationEngine.cancel(disp);
                if (_hideTimer && _hideTimer.running) {
                    _hideTimer.stop();
                }
                player.animationEngine.fadeOut(disp, 500, function():void {
                    disp.parent.removeChild(disp);
                });
            };
        }

        public function show():Notification {
            log.debug("show(), width: " + this.width);
            _player.addToPanel(this, { left: '50pct', top: '50pct' });
            return this;
        }

        public function autoHide(hideDelay:int = 5000, onHiddenCallback:Function = null):Notification {
            createHideTimer(hideDelay, onHiddenCallback);
            return this;
        }

        private function createTextField(player:Flowplayer, message:String):void {
            _field = player.createTextField(12, true);
            _field.autoSize = TextFieldAutoSize.CENTER;
            _field.wordWrap = true;
            _field.multiline = true;
            _field.antiAliasType = AntiAliasType.ADVANCED;

            var newFormat:TextFormat = new TextFormat();
            newFormat.align = TextFormatAlign.CENTER;
            _field.defaultTextFormat = newFormat;

            _field.htmlText = message;
            _field.height = _field.textHeight + 4;
            addChild(_field);
            setSize(_field.width + 20, _field.height + 20);
        }

        override protected function onResize():void {
            log.debug("onResize() " + width + "x" + height);
            _field.width = width - 20;
            _field.x = 0;
            Arrange.center(_field, width, height);
            
        }

        protected function createHideTimer(delay:int, onHiddenCallback:Function = null):void {
            _hideTimer = new Timer(delay, 1);
            _hideTimer.addEventListener(TimerEvent.TIMER_COMPLETE, createTimerCompleteListener(_player, this, onHiddenCallback));
            _hideTimer.start();
        }

        private function createTimerCompleteListener(player:Flowplayer, disp:DisplayObject, onHiddenCallback:Function):Function {
            return function(event:TimerEvent):void {
                log.debug("hiding Notification");
                player.animationEngine.fadeOut(disp, 500,
                        function():void {
                            disp.parent.removeChild(disp);
                            if (onHiddenCallback != null) {
                                onHiddenCallback();
                            }
                        });
            };
        }
    }


}