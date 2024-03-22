# Installation

Clone this repo to `~/linux_home` and then edit `install.sh` and run `install.sh`.

# Emacs

**NOTE THAT MY EMACS CONFIG HASN'T BEEN UPDATED FOR A FEW YEARS! I SWITCHED TO VS CODE AROUND 2023. AND THEN I SWITCHED TO NEOVIM IN 2024!**

After installing the .emacs in this repo, you'll need to manually do `alt-x`, `package-install` then `use-package`.
Spelling: `sudo apt install aspell-en`
The `.emacs` in this repo already sets up Emacs to use aspell (instead of ispell).

If goto-last-change complains `Cannot open load file, No such file or directory, goto-last-change` then try
doing `alt-x package-install goto-last-change`.
