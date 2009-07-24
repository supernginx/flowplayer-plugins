Version history:

3.1.3
-----
- Added new urlExtension, determines the 3rd token in the urlPattern
- Possibility to attach labels to bitrates. These are used with the urlPattern and urlExtension to generate the resolved file names.
Fixes:
- Fixed dynamic switching, it was interpreting the 'bitrates' array in reversed order
- Bandwidth is only detected once per clip. Because it was detected multiple times repeated plays did not work because
  repeated URL resolving mangled the URL

3.1.2
-----
- Gives an error message if neither netConnectionUrl nor the hosts array is not defined in config 

3.1.1
-----
- Now by default checks the bandwidth for every clip, where the plugin is not explicitly defined as urlResolver
- Does not use the no-cache request header pragma any more

3.1.0
-----
- first public release

