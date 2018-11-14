#!/bin/zsh
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/.dotfiles                    # dotfiles directory
olddir=~/.dotfiles_old             # old dotfiles backup directory
files=(rdebugrc vimrc.after vimrc.before vimrc.old zshrc)   # list of files/folders to symlink in homedir

##########

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done\n"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
for file in $files; do
    echo "Moving any existing dotfiles from ~ to $olddir"
    mv ~/.$file ~/.dotfiles_old/
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/.$file
done
echo "...done\n"

# symlink theme to zsh dir
echo "copy agonz theme to zsh theme dir"
  ln -s $dir/agonz.zsh-theme ~/.oh-my-zsh/themes/agonz.zsh-theme
echo "...done\n"

# symlink janus directory to ~
echo "copying janus dir to ~"
ln -s $dir/janus ~/.janus
echo "...done\n"

# pull submodules
echo "fetching submodules"
git submodule init
git submodule update
echo "...done\n"

echo "install the_silver_searcher:"
echo "brew install the_silver_searcher"

echo "install ctrlp-cmatcher: "
echo "
export CFLAGS=-Qunused-arguments
export CPPFLAGS=-Qunused-arguments
~/.janus/ctrlp-cmatcher/install.sh
"




