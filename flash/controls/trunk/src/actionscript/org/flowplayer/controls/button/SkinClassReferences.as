package org.flowplayer.controls.button {
    import org.flowplayer.controls.flash.FullScreenOnButton;
    import org.flowplayer.controls.flash.FullScreenOffButton;
    import org.flowplayer.controls.flash.Dragger;
    import org.flowplayer.controls.flash.NextButton;
    import org.flowplayer.controls.flash.PauseButton;
    import org.flowplayer.controls.flash.PlayButton;
    import org.flowplayer.controls.flash.PrevButton;
    import org.flowplayer.controls.flash.StopButton;
    import org.flowplayer.controls.flash.VolumeIcon;
    import org.flowplayer.controls.flash.VolumeOffIcon;


    /**
     * Holds references to classes contained in the buttons.swc lib.
     * These are needed here because the classes are instantiated dynamically and without these
     * the compiler will not include thse classes into the controls.swf
     */
    internal class SkinClassReferences {

        CONFIG::skin {
            private var foo:org.flowplayer.controls.flash.FullScreenOnButton;
            private var bar:org.flowplayer.controls.flash.FullScreenOffButton;
            private var next:org.flowplayer.controls.flash.NextButton;
            private var prev:org.flowplayer.controls.flash.PrevButton;
            private var dr:org.flowplayer.controls.flash.Dragger;
            private var pause:org.flowplayer.controls.flash.PauseButton;
            private var play:org.flowplayer.controls.flash.PlayButton;
            private var stop:org.flowplayer.controls.flash.StopButton;
            private var vol:org.flowplayer.controls.flash.VolumeIcon;
            private var volOff:org.flowplayer.controls.flash.VolumeOffIcon;
        }
    }
}