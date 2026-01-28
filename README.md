# Installation

Clone this repo to `~/linux_home` and then edit `install.sh` and run `install.sh`.

# Things to install

In `.bashrc`, set `export GEMINI_API_KEY=` to my Gemini API key (for use in neovim).

## General tools

```bash
sudo apt install git easyeffects nodejs ripgrep python3-venv fzf zoxide
sudo snap install ghostty nvim slack spotify astral-uv vale
```

* `easyeffects` is useful to filter audio during video calls, to reduce "boomy" noises and high-pitched hisses.
* `nodejs` is required for neovim's copilot plugin
* `vale`: The `.config/vale` config is used for the Vale formatter, which is used in my `nvim` config as a linter for English text.
* `python3-venv` is required to install `ruff` with `neovim`.
* `fzf` and `zoxide`: see below for more installation instructions.

## `fzf`

1. `sudo apt install fzf`
2. [Set up shell integration](https://github.com/junegunn/fzf?tab=readme-ov-file#setting-up-shell-integration). (This is still necessary even after installing `fzf` is via APT.)

## `zoxide`

Install: `sudo apt install zoxide`

(also use the same `cargo` command to update zoxide)

And append this to the end of `~/.bashrc`:

```bash
# Set up zoxide
eval "$(zoxide init --cmd cd bash)"
```

## Environment variables to append to `~/.bashrc`

```bash
# ----------------------------------------------
# ---------- Configured by Jack ----------------

# Configure editor for `fc` command (and others)
export EDITOR=nvim

# Hugging Face
export HF_TOKEN=

# Gemini API token for jack@openclimatefix.org, in the solar-pv-nowcasting Google project:
export GEMINI_API_KEY=
export GOOGLE_GENERATIVE_AI_API_KEY=

# Enphase token for accessing Envoy over LAN.
# If you need an API key then go to https://entrez.enphaseenergy.com/entrez_tokens and start
# typing "Kelly" in the "Select System". And then select the gateway.
export ENPHASE_TOKEN=
```

# Emacs

**NOTE THAT MY EMACS CONFIG HASN'T BEEN UPDATED FOR A FEW YEARS! I SWITCHED TO VS CODE AROUND 2023. AND THEN I SWITCHED TO NEOVIM IN 2024! You can find my nvim config [here](https://github.com/JackKelly/kickstart-modular.nvim)**

After installing the `.emacs` in this repo, you'll need to manually do `alt-x`, `package-install` then `use-package`.
Spelling: `sudo apt install aspell-en`
The `.emacs` in this repo already sets up Emacs to use `aspell` (instead of `ispell`).

If goto-last-change complains `Cannot open load file, No such file or directory, goto-last-change` then try
doing `alt-x package-install goto-last-change`.

