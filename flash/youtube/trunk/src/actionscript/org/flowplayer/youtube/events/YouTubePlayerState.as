/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.youtube.events {

	/**
	 * @author danielr
	 */
	public class YouTubePlayerState {
		public static const ENDED:Number = 0;
    	public static const PLAYING:Number = 1;
    	public static const PAUSED:Number = 2;
    	public static const BUFFERING:Number = 3;
    	public static const CUED:Number = 5;
	}
}
