/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <api@iki.fi>
 *
 * Copyright (c) 2008-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.captions {
    import flexunit.framework.TestCase;

    import org.flowplayer.captions.parsers.JSONParser;

    import org.flowplayer.captions.parsers.SRTParser;
    import org.flowplayer.captions.parsers.TTXTParser;

    import org.flowplayer.model.Clip;

    public class CaptionTest extends TestCase {
        private var _caption:Caption;
        private var _clip:Clip;

        override public function setUp():void {
            _caption = new Caption();
            _caption.config = new Config();
            _clip = new Clip();
        }

        public function testCreateSubRipParser():void {
            _clip.setCustomProperty("captionFormat", "subrip");
            assertTrue(_caption.createParser(_clip,  {}, false) is SRTParser);
        }

        public function testCreateJSONParser():void {
            _clip.setCustomProperty("captionFormat", "json");
            assertTrue(_caption.createParser(_clip,  {}, false) is JSONParser);
        }

        public function testCreateTimedTextParser():void {
            _clip.setCustomProperty("captionFormat", "tt");
            assertTrue(_caption.createParser(_clip,  {}, false) is TTXTParser);
        }
    }
}
