/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>, Anssi Piirainen Flowplayer Oy
 * Copyright (c) 2009 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.bwcheck.detect.event
{
	import org.flowplayer.model.EventType;
	
	public class BWDetectEventType extends EventType
	{
		public static const DETECT_FAILED:BWDetectEventType = new BWDetectEventType("onDetectFailed");
		public static const DETECT_COMPLETE:BWDetectEventType = new BWDetectEventType("onDetectComplete");
		public static const DETECT_STATUS:BWDetectEventType = new BWDetectEventType("onDetectStatus");
		public static const DETECT_START:BWDetectEventType = new BWDetectEventType("onDetectStart");
		
		public function BWDetectEventType(name:String)
		{
			super(name);
		}

	}
}