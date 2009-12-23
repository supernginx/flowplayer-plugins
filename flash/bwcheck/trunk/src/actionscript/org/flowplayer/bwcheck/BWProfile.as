package org.flowplayer.bwcheck {

	import flash.net.SharedObject;
	/**
	 * @author danielr
	 */
	 
	public class BWProfile {
		private var _profile:SharedObject;
		private var _expiry:Number;
		private var _timestamp:Number;
			
		public function BWProfile(profileName:String, path:String) {
			_profile = SharedObject.getLocal(profileName, path);
		}
		
		public function set expiry(value:Number):void
		{
			_expiry = value;
		}
		
		public function set bitrate(value:String):void
		{
			_profile.data.bitrate = value;
		}
	
		public function get bitrate():String
		{
			return _profile.data.bitrate;
		}
		
		public function set bandwidth(value:Number):void
		{
			_profile.data.bandwidth = value;
			_profile.data.timestamp = (new Date()).getTime();
		}
	
		public function get bandwidth():Number
		{
			return _profile.data.bandwidth;
		}
		
		public function set maxBandwidth(value:Number):void
		{
			_profile.data.maxBandwidth = value;
		}
		
		public function get maxBandwidth():Number
		{
			return _profile.data.maxBandwidth;
		}
		
		
		public function clear():void
		{
			_profile.clear();
		}
		
		/*		
		public function set timestamp(value:Number):void
		{
			_profile.data.timestamp = value;
		}
	
		public function get timestamp():Number
		{
			return _profile.data.timestamp;
		}*/
		
		public function get age():Number {
			return ((new Date()).getTime() - _profile.data.timestamp) / 1000;
		}
		
		public function get isExpired():Boolean {
			return age > _expiry;		
		}
	}
}
