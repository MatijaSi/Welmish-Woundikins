# Welmish Woundikins 1,5%
Made using Ruby and Curses.

### Please note:
This is very early alpha, so there are some things you have to do to use it successfully:

1. Make sure the terminal in which you run the game is big enough (otherwise menus won't show)
2. Mapgen takes a lot of time, so be patient.


### New:
Rogues can now see fovs of monsters (so stealth-ing past monsters is now easier), increased difficulty.

### Installation:
You will need to have one of the newer versions of Ruby installed and maybe the curses gem.

Put all files into one directory. Then run in terminal: ruby main.rb

It should work on Linux (and other *nixes), however if it doesn't, make sure you have ncurses installed. If you have Windows, good luck (maybe try cygwin?). It was only tested on linux.

### Controls:
Nethack keys to move and attack, for up-left move/attack you can use either y or z. '?' for help, 'q' to quit, '.' to wait one turn.

### Goals:
A story heavy and atmospheric roguelike. To add to replayability the story will be procedurally generated. Atmosphere will be mostly present through short descriptions of creatures, items, map features...

### Version goals:
1%    - Basic movement and combat, simple map generator, player can die, simple FoV.

2%    - Map made from sectors, each with its own map generator (cavernous, rooms, dungeons, ...), floors (up and down stairs).

3%    - Items

4%    - Better combat system, simple magic

5%    - "Social" mode (talking with friendly creatures)

6%    - Map features (dwellings, temples, burrows, ...)

...

10%   - Crafting, ritual based magic system

20%   - First version of story generator

30%   - First version of cultures generator

