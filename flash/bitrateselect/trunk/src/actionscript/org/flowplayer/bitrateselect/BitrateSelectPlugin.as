package org.flowplayer.bitrateselect {
    import org.flowplayer.model.PluginFactory; 
    import flash.display.Sprite;

    public class BitrateSelectPlugin extends Sprite implements PluginFactory  {
        
        public function BitrateSelectPlugin() {
            
        }
        
        public function newPlugin():Object {
            return new BitrateSelectProvider();
        }
    }
}