# CC-AudioServer
Audio server for storing and accessing DFPWM and WAV files remotely in ComputerCraft

### Setup:
- Create text file with all directories containing audio (e.g disk1, disk2), seperated by new lines, like this:
```
./music/
./disk1/
./disk2/
...
```
- Select port on which to transmit the server (Default - 7101)
- Set these values in startup.lua
- Run startup.lua

### Server method types:
All methods work like this: make request with message being a table with mandatory "type" value, and optional method specific ones, and await response
* query - returns data for all tracks in the catalogue. Returns code 200
* refresh - update catalogue in case new tracks were added. Returns code 200
* track_info - gets index, returns details of a specific track. Additionally sends code 200 or 404 if index is invalid.
* track_chunk - gets index, starting second and length, and returns that bit of a sound. Additionally sends code 200 or 404 if index is invalid.
