#!/bin/bash

files=".condarc .emacs .gitconfig .bash_aliases .config/vale .config/ghostty"

for file in $files
do
    echo "Symbolic linking $file"
    ln -s /home/jack/linux_home/$file /home/jack/$file
done
