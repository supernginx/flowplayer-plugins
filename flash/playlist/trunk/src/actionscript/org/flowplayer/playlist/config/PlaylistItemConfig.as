/**
 * Created by IntelliJ IDEA.
 * User: danielr
 * Date: 3/03/11
 * Time: 1:25 AM
 * To change this template use File | Settings | File Templates.
 */
package org.flowplayer.playlist.config {

    import org.flowplayer.ui.buttons.ButtonConfig;
    import org.flowplayer.ui.buttons.TooltipButtonConfig;

    public class PlaylistItemConfig {
        private var _buttons:TooltipButtonConfig;

        public function PlaylistItemConfig() {
            _buttons = new TooltipButtonConfig();
            _buttons.setColor("rgba(20,20,20,0.5)");
            _buttons.setOverColor("rgba(0,0,0,1)");

            _buttons.setOnColor("rgba(255,255,255,1)");
            _buttons.setOffColor("rgba(130,130,130,1)");
        }

        public function get buttons():TooltipButtonConfig {
            return _buttons;
        }

        public function set buttons(value:TooltipButtonConfig):void {
            _buttons = value;
        }
    }
}
