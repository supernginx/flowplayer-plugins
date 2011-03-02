package org.flowplayer.playlist.ui {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;

    import org.flowplayer.ui.buttons.AbstractButton;
    import org.flowplayer.ui.buttons.ButtonConfig;
    import org.flowplayer.playlist.assets.CloseButton;
    import org.flowplayer.view.AnimationEngine;

    /**
     * @author api
     */
    public class CloseButton extends AbstractButton {
        private var _icon:DisplayObject;

        public function CloseButton(config:ButtonConfig, animationEngine:AnimationEngine) {
            super(config, animationEngine);
        }

        override protected function createFace():DisplayObjectContainer {
            return new org.flowplayer.playlist.assets.CloseButton();
        }
    }
}
