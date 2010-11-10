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
    import org.flowplayer.view.Flowplayer;

    public class AbstractCommand {
        private var _player:Flowplayer;

        public function AbstractCommand(player:Flowplayer) {
            _player = player;
        }

        public final function execute():void {
            process();
        }

        protected function process():void {
        }

        protected function get player():Flowplayer {
            return _player;
        }
    }
}