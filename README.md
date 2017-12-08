# How to use this fancy star gravity simulator:

* Arrow keys to move your camera around
* Left click to create star
* Right click to erase star
* Middle click to reset each star's velocity
* G to generate a new universe with stars
* W to enable/disable the walls that is on your screen's border
* N to empty the universe
* Space to pause
* I to show universe info, fps etc...
* C to enable/disable the star's random color
* S to change the star's style between sprite, circle and point
* V to show each star's velocity
* A to show each star's acceleration
* O to save your universe

## Application parameters:

What's an applicaton parameter? You can type them by opening a terminal/cmd, launching the game by typing `love gravity.love`, and then type these extra piece of text to do extra stuff.

* `-g` to generate a new universe with stars at startup
* `-l <SAVE FILE>` to load a save file

# Where are my saved universe located?

It's simple, here:

OS | Path
--- | ---
Windows | `%appdata%\LOVE\gravity\saves`
Mac | `/Users/<YOU>/Library/Application Support/LOVE/gravity/saves`
Linux | `~/.local/share/love/gravity/saves`

The higher the number of the file is, the more recent it is.
