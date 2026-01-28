# Installation

Clone this repo to `~/linux_home` and then edit `install.sh` and run `install.sh`.

# Things to install

In `.bashrc`, set `export GEMINI_API_KEY=` to my Gemini API key (for use in neovim).

## Base tools (for all Ubuntu installs: headless & desktop)

```bash
sudo apt install git ripgrep fzf zoxide
sudo snap install nvim astral-uv vale
```

* `vale`: The `.config/vale` config is used for the Vale formatter, which is used in my `nvim` config as a linter for English text.
* `fzf` and `zoxide`: see below for more installation instructions.

## Install on desktop

```bash
sudo apt install easyeffects 
sudo snap install ghostty slack spotify
```

* `easyeffects` is useful to filter audio during video calls, to reduce "boomy" noises and high-pitched hisses.
* Maybe also [install OBS Studio](https://github.com/obsproject/obs-studio/wiki/install-instructions#linux) to zoom my webcam during video calls.

## `fzf`

1. `sudo apt install fzf`
2. [Set up shell integration](https://github.com/junegunn/fzf?tab=readme-ov-file#setting-up-shell-integration). (This is still necessary even after installing `fzf` is via APT.)

## `zoxide`

Install: `sudo apt install zoxide`

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
export GOOGLE_GENERATIVE_AI_API_KEY="$GEMINI_API_KEY"

# Enphase token for accessing Envoy over LAN.
# If you need an API key then go to https://entrez.enphaseenergy.com/entrez_tokens and start
# typing "Kelly" in the "Select System". And then select the gateway.
export ENPHASE_TOKEN=
```

# Neovim

You can find my nvim config [here](https://github.com/JackKelly/kickstart-modular.nvim).
