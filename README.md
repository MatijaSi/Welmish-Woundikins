# Welmish Woundikins 3%
Made using Ruby and Curses.

### Please note:
This is very early alpha, so there are some things you have to do to use it successfully:

1. Make sure the terminal in which you run the game is big enough (otherwise menus won't show)
2. Mapgen takes a lot of time, so be patient.


### New:
Raytracing fov, hoplite class.

### Current version:
Three player classes: Warriors (decent damage, more health than barbarians, smaller fov), Rogues (smaller damage, same health as warriors, bigger fov, can see fovs of monsters (useful for stealthing past them)) and Barbarians (smaller health, bigger damage when close to death). Or you can play as a goblin or as a scoundrel.

Monsters: Goblins, Goblin Warlords (summoners), Scoundrels (run away when wounded), Bombers (explode when close to player), Nazgul (you win when/if you kill him).

Map generators: Cavernous (drunkard walk alghoritm), Mazes (lots of corridors), Rooms (tend to generate big, merged rooms)

Items: Weapons, Armours, Potions of healing, Potions of poison, Teleport scrolls.

### Installation:
Linux:

1) Install dependencies (you do not need git if you manually download the source code):

sudo apt-get install ruby2.0 libncurses5 git

2) Clone the repository (unnecessary if you manually download the source):

git clone https://github.com/MatijaSi/Welmish-Woundikins.git

3) Run the game from the Welmish-Woundikins directory:

ruby main.rb

Maybe you will need to install curses gem: gem install curses

If you have Windows, good luck (maybe try cygwin?). It was only tested on linux.

### Controls:
Nethack keys to move and attack, for up-left move/attack you can use either y or z.

'?' for help, 'Q' to quit, '.' to wait one turn.

'i' - inventory, 'e' - equipment.

',' - pick up, 'd' - drop, 'w' - wear/wield, 'q' - quaff, 'r' - read, 't' - take off.

### Goals:
A story heavy and atmospheric roguelike. To add to replayability the story will be procedurally generated. Atmosphere will be mostly present through short descriptions of creatures, items, map features...

### Version goals:

Probably won't be followed, they are there just to give you an idea what's in the works. Goals are going to change frequently, to suit what is currently being developed.

1%    - Basic movement and combat, simple map generator, player can die, simple FoV.

2%    - Map made from sectors, each with its own map generator (cavernous, rooms, dungeons, ...).

3%    - Items and new monsters.

4%    - Better combat system (ranged combat, monster infighting), simple magic(ala magic missile, heal self)

5%    - "Social" mode (talking with friendly creatures)

6%    - New room-based mapgenerator (to make descriptions of sorroundings possible) with cavernous rooms, usual rooms, lakes, canyons, ... Map features (dwellings, temples, burrows, ...), floors (stairs).

...

10%   - Crafting (based on imbuing items with rare materials or spells, enchanting them with essences), ritual based magic system (based on crafting)

20%   - First version of story generator

30%   - First version of cultures generator

