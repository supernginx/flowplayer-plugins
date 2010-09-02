package org.flowplayer.bwcheck.icons {
    import flash.display.DisplayObjectContainer;

    import org.flowplayer.ui.AbstractButton;
    import org.flowplayer.ui.ButtonConfig;
    import org.flowplayer.view.AnimationEngine;
    import org.flowplayer.bwcheck.assets.HdIcon;

    import flash.events.MouseEvent;
    import flash.display.MovieClip;
    import flash.display.DisplayObject;

    public class HDIcon extends AbstractButton {

        private var toggleStateOn:Boolean = false;

        public function HDIcon(config:ButtonConfig, animationEngine:AnimationEngine) {
            super(config, animationEngine);
        }

        override protected function createFace():DisplayObjectContainer {
            return new org.flowplayer.bwcheck.assets.HdIcon();
        }

        override protected function onMouseDown(event:MouseEvent):void {


            var hdText:DisplayObject = face.getChildByName("hdText");

            this.toggle = (toggleStateOn ? false : true);

            log.debug(this.toggle.toString());
            //toggle = toggleStateOn;

            if (hdText && hdText is MovieClip) {
                log.debug("calling gotoAndStop(10) on " + face);
                MovieClip(face).gotoAndStop(toggleStateOn ? 2 : 1);
            }

            super.onMouseDown(event);
        }

        override protected function showMouseOutState(clip:DisplayObjectContainer):void {

            super.showMouseOutState(clip);

            //toggle = toggleStateOn;

            var hdText:DisplayObject = clip.getChildByName("hdText");

            if (hdText is MovieClip) {
                log.debug("calling gotoAndStop(1) on " + hdText);
                MovieClip(hdText).gotoAndStop(toggleStateOn ? 2 : 1);
            }
        }

        public function set toggle(toggle:Boolean):void {

            /*var hdText:DisplayObject = face.getChildByName("hdText");

             toggleStateOn = toggle;

             if (hdText && hdText is MovieClip) {
             log.debug("calling gotoAndStop(10) on " + face);
             MovieClip(face).gotoAndStop(toggleStateOn ? 2 : 1);
             }*/
            toggleStateOn = toggle;

        }

        public function get toggle():Boolean {
            return toggleStateOn;
        }

    }
}
