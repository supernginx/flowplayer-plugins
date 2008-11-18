/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2008 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
 
package org.flowplayer.rtmp.bwcheck.event
{
	import org.flowplayer.model.EventType;
	
	public class BWDetectEventType extends EventType
	{
		public static const DETECT_FAILED:BWDetectEventType = new BWDetectEventType("onDetectFailed", 17);
		public static const DETECT_COMPLETE:BWDetectEventType = new BWDetectEventType("onDetectComplete", 18);
		public static const DETECT_STATUS:BWDetectEventType = new BWDetectEventType("onDetectStatus", 19);
		public static const DETECT_START:BWDetectEventType = new BWDetectEventType("onDetectStart", 20);
		
		public function BWDetectEventType(name:String, code:Number)
		{
			super(name,code);
		}

	}
}