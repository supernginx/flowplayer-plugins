package org.flowplayer.playlist.ui {

    import flash.display.DisplayObjectContainer;

    import org.flowplayer.ui.buttons.AbstractButton;
    import org.flowplayer.ui.buttons.ButtonConfig;
    import org.flowplayer.view.AnimationEngine;
    import org.flowplayer.playlist.assets.PlaylistIcon;
    

    public class PlaylistButton extends AbstractButton {

        public function PlaylistButton(config:ButtonConfig, animationEngine:AnimationEngine) {
            super(config, animationEngine);
        }

        override protected function createFace():DisplayObjectContainer {
            return new org.flowplayer.playlist.assets.PlaylistIcon();
        }
    }
}