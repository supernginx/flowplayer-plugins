package org.flowplayer.playlist.icons {

    import flash.display.DisplayObjectContainer;

    import org.flowplayer.ui.AbstractButton;
    import org.flowplayer.ui.ButtonConfig;
    import org.flowplayer.view.AnimationEngine;
    import org.flowplayer.playlist.assets.PlaylistIcon;
    

    public class PlaylistIcon extends AbstractButton {

        public function PlaylistIcon(config:ButtonConfig, animationEngine:AnimationEngine) {
            super(config, animationEngine);
        }

        override protected function createFace():DisplayObjectContainer {
            return new org.flowplayer.playlist.assets.PlaylistIcon();
        }
    }
}