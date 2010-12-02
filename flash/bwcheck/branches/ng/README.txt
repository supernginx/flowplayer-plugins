Version history:

3.2.4
-----
- Now works without configuring netConnectionUrl for the plugin, in this case the netConnectionUrl value is taken from the
  clip. Also works when it's resolved by the SMIL plugin etc.

3.2.3
-----
- new config
- new event onStreamSwitchBegin

3.2.2
-----
Fixes:
- fixing bwcheck with FMS, was unable to re-detect during playback

3.2.1
-----
Fixes:
- this plugin did not work properly with playlists, in fact it was only possible to use it with one configured clip
- stream selection now works properly if the bitrates array does not contain video width values
- stream selection works better if the configured bitrates all exceed available BW: In this case the default bitrate is
  selected and if the default is not configured the smallest bitrate is used

3.2.0
-----
- New configuration model
- Considers the screen size when selecting streams
- Switches when entering and exiting fullscreen
- Support for specifying bitrates in RSS files

3.1.3
-----
- issues fixed in FMS dynamic stream switching

3.1.2
-----
- compatible with 3.2 ConnectionProvider and URLResolver API
- Now the remembered bitrate is only cached for 24 hours by default. You can control the cache expiry using a new
  config option 'cacheExpiry' where the expiry period is given in seconds.
- With 'rememberBitrate' enabled now stores the detected bandwidth and the mapping to the bitrate happens every time
  the remembered bandwidth is used.

3.1.1
-----
- New external method dynamic(enabled) to toggle dynamic bitrate adaptation
- setBitrate() external method now disabled dynamic bitrate adaptation. Otherwise the manually set value would be immediately
  overridden by the dynamically adapted bitrate.
- Added new urlExtension, determines the 3rd token in the urlPattern
- Possibility to attach labels to bitrates. These are used with the urlPattern and urlExtension to generate the resolved file names.
- Gives an error message if neither 'netConnectionUrl' nor the 'hosts' array is not defined in config
- Now by default checks the bandwidth for every clip, where the plugin is not explicitly defined as urlResolver.
  New config option 'checkOnBegin' to turn of this default behavior
- Does not use the no-cache request header pragma any more
Fixes:
- autoPlay: false now honored when using "auto checking" i.e. when checkOnBegin is not explicitly set to false
- Fixed dynamic switching, it was interpreting the 'bitrates' array in reversed order
- Bandwidth is only detected once per clip. Because it was detected multiple times repeated plays did not work because
  repeated URL resolving mangled the URL

3.1.0
-----
- first public release

