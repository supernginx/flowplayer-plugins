Version history:

3.2.6
-----

- added new adobe http streaming plugin with dynamic bitrate switching support
- fixed switchStream api method with dynamic stream switching support. #339
- added transition and transition completion events required by bitrateselect. #339
- Fixes for #367, removed depreciated code for httpstreaming and updated to the latest osmf changes.
- #367 fixes for dynamic switching and hd toggling features.
- #452 provide dvr live stream integration. seeks to the current dvr duration with an offset to obtain the live stream.
Provides features to set the live and dvr buffer times. Allows to seek back into the dvr recorded portion of the stream
by setting the clip config to live and stopLiveOnPause to false.