# Welmish Woundikins 2,5%
Made using Ruby and Curses.

### Please note:
This is very early alpha, so there are some things you have to do to use it successfully:

1. Make sure the terminal in which you run the game is big enough (otherwise menus won't show)
2. Mapgen takes a lot of time, so be patient.


### New:
Rogues can now see fovs of monsters (so stealth-ing past monsters is now easier), increased difficulty. Added bombers and scoundrels, each with their own additions to AI. Added Goblin Warlords, which are basically summoners. Barbarian class, whose damage is bigger when close to death.

### Current version:
Three player classes: Warriors (decent damage, more health than barbarians, smaller fov), Rogues (smaller damage, same health as warriors, bigger fov, can see fovs of monsters (useful for stealthing past them) and Barbarians (smaller health, bigger damage when close to death).

Monsters: Goblins, Goblin Warlords (summoners), Scoundrels (run away when wounded), Bombers (explode when close to player).

Map generators: Cavernous (drunkard walk alghoritm), Mazes (lots of corridors), Rooms (tend to generate big, merged rooms)

### Installation:
You will need to have one of the newer versions of Ruby installed and maybe the curses gem.

Put all files into one directory. Then run in terminal: ruby main.rb

It should work on Linux (and other *nixes), however if it doesn't, make sure you have ncurses installed. If you have Windows, good luck (maybe try cygwin?). It was only tested on linux.

### Controls:
Nethack keys to move and attack, for up-left move/attack you can use either y or z. '?' for help, 'q' to quit, '.' to wait one turn.

### Goals:
A story heavy and atmospheric roguelike. To add to replayability the story will be procedurally generated. Atmosphere will be mostly present through short descriptions of creatures, items, map features...

### Version goals:

Probably won't be followed, they are there just to give you an idea what's in the works. Goals are going to change frequently, to suit what is currently being developed.

1%    - Basic movement and combat, simple map generator, player can die, simple FoV.

2%    - Map made from sectors, each with its own map generator (cavernous, rooms, dungeons, ...).

3%    - Items and new monsters.

4%    - Better combat system, simple magic

5%    - "Social" mode (talking with friendly creatures)

6%    - Map features (dwellings, temples, burrows, ...), floors (stairs).

...

10%   - Crafting, ritual based magic system

20%   - First version of story generator

30%   - First version of cultures generator

