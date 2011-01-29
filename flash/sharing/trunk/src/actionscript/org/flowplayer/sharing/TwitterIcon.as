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
package org.flowplayer.sharing {
    import org.flowplayer.sharing.assets.TwitterIcon;
    import flash.display.DisplayObjectContainer;

    import org.flowplayer.ui.ButtonConfig;
    import org.flowplayer.view.AnimationEngine;
    import org.flowplayer.viralvideos.icons.AbstractIcon;

    public class TwitterIcon extends AbstractIcon {

        public function TwitterIcon(config:ButtonConfig, animationEngine:AnimationEngine, label:String = "Twitter") {
            super(config, animationEngine);
        }

        override protected function createIcon():DisplayObjectContainer {
            return new org.flowplayer.sharing.assets.TwitterIcon();
        }
    }
}