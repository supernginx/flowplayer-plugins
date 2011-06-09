/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.net {

/**
 * @author danielr
 */
public class BitrateItem {
    public var bitrate:Number;
    public var width:Number;
    public var height:Number;
    public var url:String;
    public var isDefault:Boolean;
    public var index:int;
    public var label:String;
    public var hd:Boolean;
    public var sd:Boolean;

    public function BitrateItem():void {

    }

    public function toString():String {
        return url + ", " + bitrate;
    }

    public function get streamName():String {
        return url;
    }
}
}

