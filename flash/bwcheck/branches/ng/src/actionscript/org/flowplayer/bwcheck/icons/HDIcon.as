package org.flowplayer.bwcheck.icons
{
    import flash.display.DisplayObjectContainer;
    
    import org.flowplayer.ui.AbstractToggleButton;
    import org.flowplayer.ui.ButtonConfig;
    import org.flowplayer.view.AnimationEngine;
    
    import org.flowplayer.bwcheck.assets.HDToggleOn;
    import org.flowplayer.bwcheck.assets.HDToggleOff;

    public class HDIcon extends AbstractToggleButton
    {
 

        
        public function HDIcon(config:ButtonConfig, animationEngine:AnimationEngine)
        {
            super(config, animationEngine);
        }
        
        override protected function onResize():void {
            _upStateFace.width = width;
            _upStateFace.height = height;
            
            if (_downStateFace) {
            	_downStateFace.width = width;
                _downStateFace.height = height;
            }
        }
        
        override protected function createUpStateFace():DisplayObjectContainer {
            return new HDToggleOff();
        }
        
        override protected function createDownStateFace():DisplayObjectContainer {
            return new HDToggleOn();
        }
        


    }
}