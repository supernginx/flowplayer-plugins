Version history:

3.1.2
-----
- Now the remembered bitrate is only cached for 24 hours by default. You can control the cache expiry using a new
  config option 'cacheExpiry' where the expiry period is given in seconds.

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

