3.2.6
-----

- Fixes for #367 removed depreciated code for f4m parsing and updated parser structure to match the latest osmf versions.
- Fixes for #367 put support back in for sd / hd flags to work with latest bitrateselect changes.
- Added in version config option to select which manifest parser version to use with support for embedded manifest files.
- #367 fixes for resolving single stream urls.
- #452 Provides features to set the live and dvr buffer times with seperate configurations. Allows to seek back into the dvr recorded portion of the stream
by setting the clip config to live and stopLiveOnPause to false when the manifest strea type is dvr.