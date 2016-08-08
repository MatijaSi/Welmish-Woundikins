# Welmish Woundikins
Made using Ruby and Curses.

## I stopped working on this project, so don't expect any new updates soon. Feel free to fork it though.

### DevBlog:
http://welmish.blogspot.si/

### Please note:
You will need to have a 256 colour supporting terminal. While most terminals today support 256 colours, most do not report themselves as such. Because of that you will have to temporarily change TERM variable in linux (for windows I don't have a clue).

If game runs slow you can change the number of monsters (will have bigger impact) or map size in file config.rb

### Linux

1) Install dependencies (you do not need git if you manually download the source code):

sudo apt-get install ruby2.0 libncurses5 git

2) Clone the repository (unnecessary if you manually download the source):

git clone https://github.com/MatijaSi/Welmish-Woundikins.git

3) Run the game from the Welmish-Woundikins directory:

ruby main.rb

3) (Alternative) If colours don't work, you will have to run the program with changed TERM variable:
if your terminal is xterm:

env TERM=xterm-256color ruby main.rb

for other terminals the change is similar.

4) (Optional) You may need to install curses gem

gem install curses

### Windows (Msys2)

1) Get Msys2 from http://msys2.github.io and follow the installation instructions (close and reopen after each step).

2) Install dependencies (you do not need git if you manually download the source code) (this will take a little while:

pacman -S git ruby base-devel gcc gmp-devel libcrypt-devel ncurses-devel

3) Make sure ruby gems are in the $PATH. To do this, edit the file: msys**/home/USER/.bashrc and add the following lines, then restart msys:

```
# Local Ruby gems inclusion.
if which ruby >/dev/null && which gem >/dev/null; then
    PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi
```
4) Install the curses gem (this will take a little while):

gem install curses

5) Clone the repository (unnecessary if you manually download the source):

git clone https://github.com/MatijaSi/Welmish-Woundikins.git

6) Run the game from the Welmish-Woundikins directory:

ruby main.rb
