NOTE:

To compile your plugin against the latest sources you should checkout the flowplayer
core sources from SVN and compile the flowplayer.swc library from sources. This
module contains a 'recent' library version only.


Version history:

3.0.2
-----
- Introduced new plugin event types PluginEventType#LOAD and PluginEventType#ERROR
  The PluginModel interface has new methods for dispatching these events. 

rc3
---
- renamed configureLog() to logging()

rc2
---
- added close() to the Flowplayer API

rc1
---
- added configureLog() into the Flowplayer API
- added attachStream() to the StreamProvider interface

beta4
-----
- flowplayer.swc was missing from the lib
