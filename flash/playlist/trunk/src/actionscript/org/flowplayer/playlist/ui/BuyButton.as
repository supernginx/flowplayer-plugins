package org.flowplayer.playlist.ui {

    import org.flowplayer.playlist.assets.BuyIcon;
    import flash.display.DisplayObjectContainer;

    import org.flowplayer.ui.AbstractButton;
    import org.flowplayer.ui.ButtonConfig;
    import org.flowplayer.view.AnimationEngine;

    

    public class BuyButton extends AbstractButton {

        public function BuyButton(config:ButtonConfig, animationEngine:AnimationEngine) {
            super(config, animationEngine);
        }

        override protected function createFace():DisplayObjectContainer {
            return new org.flowplayer.playlist.assets.BuyIcon();
        }
    }
}