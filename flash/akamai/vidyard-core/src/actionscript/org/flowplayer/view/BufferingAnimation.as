/*
 *    Copyright (c) 2008-2011 Flowplayer Oy *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    Flowplayer is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with Flowplayer.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.flowplayer.view {
    import flash.display.Sprite;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.geom.ColorTransform;

    import org.flowplayer.util.StyleSheetUtil;
    import org.flowplayer.model.PlayButtonOverlay;

    import com.vidyard.assets.*;

    public class BufferingAnimation extends AbstractSprite {

        private var _bufferingBackground:Sprite = new BufferingBackground();
		private var _bufferingMask:Sprite = new BufferingMask();
		private var _bufferingProgressBar:Sprite = new BufferingProgressBar();
		private var _bufferingContainer:Sprite;
		private var _bufferingTimer:Timer;
        private var _bufferingProgressBarStart:Number = 0.5;
        private var _playOverlay:PlayButtonOverlay;


        public function BufferingAnimation(playOverlay:PlayButtonOverlay) {
            _playOverlay = playOverlay;
            createBufferingAnimation();
            _bufferingTimer = new Timer(_playOverlay.bufferingSpeed);
			_bufferingTimer.addEventListener(TimerEvent.TIMER, animate);

            _bufferingTimer.start();
        }

        public function start():void {
            _bufferingTimer.start();
        }

        public function stop():void {
            _bufferingTimer.stop();
        }

        protected override function onResize():void {
            arrange(width, height);
        }

        private function animate(event:TimerEvent):void {
            _bufferingProgressBar.scaleX = _bufferingProgressBar.scaleX+0.1;
            if (_bufferingProgressBar.scaleX == 1) _bufferingProgressBar.scaleX = 0;
        }

        private function setBackgroundColor():void {
            if (_playOverlay.bufferingColor) {
                var color:ColorTransform = _bufferingBackground.transform.colorTransform;
                color.color = StyleSheetUtil.colorValue(_playOverlay.bufferingColor);
                _bufferingBackground.transform.colorTransform = color;
                _bufferingBackground.alpha = _playOverlay.bufferingAlpha;
            }
        }

        private function setBackgroundMaskColor():void {
            if (_playOverlay.bufferingMaskColor) {
                var color:ColorTransform = _bufferingMask.transform.colorTransform;
                color.color = StyleSheetUtil.colorValue(_playOverlay.bufferingMaskColor);
                _bufferingMask.transform.colorTransform = color;
            }

            _bufferingMask.alpha = _playOverlay.bufferingMaskAlpha;
        }

        private function createBufferingAnimation():void {
            _bufferingBackground = new BufferingBackground();
            setBackgroundColor();
            _bufferingMask = new BufferingMask();
            setBackgroundMaskColor();

            _bufferingProgressBar = new BufferingProgressBar();


            _bufferingContainer = new Sprite();
            _bufferingContainer.addChild(_bufferingBackground);
			_bufferingContainer.addChild(_bufferingMask);

            _bufferingMask.mask = _bufferingProgressBar;

            _bufferingContainer.addChild(_bufferingProgressBar);
			_bufferingProgressBar.width = _bufferingMask.width + _bufferingProgressBarStart;

            _bufferingProgressBar.x = -_bufferingProgressBarStart;

			_bufferingProgressBar.scaleX = 0;

            addChild(_bufferingContainer);
        }

        private function arrange(width:Number, height:Number):void {
            if (_bufferingBackground) {
                _bufferingContainer.x = (width - _bufferingBackground.width)/2;
                _bufferingContainer.y = (height - _bufferingBackground.height)/2;
            }
        }
    }
}
