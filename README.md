# Installation

Clone this repo to `~/linux_home` and then edit `install.sh` and run `install.sh`.

# Things to install

## General tools

```bash
sudo apt install git easyeffects nodejs ripgrep
sudo snap install ghostty nvim slack spotify astral-uv vale
```

* `easyeffects` is useful to filter audio during video calls, to reduce "boomy" noises and high-pitched hisses.
* `nodejs` is required for neovim's copilot plugin
* `vale`: The `.config/vale` config is used for the Vale formatter, which is used in my `nvim` config as a linter for English text.

## `fzf`

1. Download [latest fzf binary](https://github.com/junegunn/fzf/releases) and move to `/bin/`
2. [Set up shell integration](https://github.com/junegunn/fzf?tab=readme-ov-file#setting-up-shell-integration).

## `zoxide`

Install: `cargo install zoxide --locked`

(also use the same `cargo` command to update zoxide)

And append this to the end of `~/.bashrc`:

```bash
# Set up zoxide
eval "$(zoxide init --cmd cd bash)"
```

# Emacs

**NOTE THAT MY EMACS CONFIG HASN'T BEEN UPDATED FOR A FEW YEARS! I SWITCHED TO VS CODE AROUND 2023. AND THEN I SWITCHED TO NEOVIM IN 2024! You can find my nvim config [here](https://github.com/JackKelly/kickstart-modular.nvim)**

After installing the `.emacs` in this repo, you'll need to manually do `alt-x`, `package-install` then `use-package`.
Spelling: `sudo apt install aspell-en`
The `.emacs` in this repo already sets up Emacs to use aspell (instead of ispell).

If goto-last-change complains `Cannot open load file, No such file or directory, goto-last-change` then try
doing `alt-x package-install goto-last-change`.

