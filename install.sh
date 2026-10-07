#!/bin/bash

files=".gitconfig .config/vale .config/ghostty .claude/settings.json .claude/output-styles"

for file in $files
do
    echo "Symbolic linking $file"
    ln -s /home/jack/linux_home/$file /home/jack/$file
done
