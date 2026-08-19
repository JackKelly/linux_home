# Installation

Clone this repo to `~/linux_home` and then edit `install.sh` and run `install.sh`.

# Things to install

In `.bashrc`, set `export GEMINI_API_KEY=` to my Gemini API key (for use in neovim).

## Base tools (for all Ubuntu installs: headless & desktop)

```bash
sudo apt install git ripgrep fzf zoxide python3-pip python3-venv make unzip gcc clang nodejs
sudo snap install nvim astral-uv --classic
sudo snap install vale
# Next, install rust. See: https://rust-lang.org/learn/get-started/
cargo install --locked tree-sitter-cli
```

* `vale`: The `.config/vale` config is used for the Vale formatter, which is used in my `nvim` config as a linter for English text.
* `fzf` and `zoxide`: see below for more installation instructions.
* `python3-pip`, `python3-venv`, `make`, `unzip`, `gcc`, `tree-sitter-cli`: All required for `nvim`.
* `clang` and `nodejs` are required to install `tree-sitter-cli`

## Install on desktop

```bash
sudo apt install easyeffects 
sudo snap install ghostty slack spotify
```

Install the [TopHat Gnome extension](https://extensions.gnome.org/extension/5219/tophat/) to show CPU usage etc. in the top bar.

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

## Fix: `ncurses: cannot initialize terminal type ($TERM="xterm-ghostty")`

**Cause:** Ghostty ships its own `xterm-ghostty` terminfo entry, installed only into `~/.terminfo/` (user-local). `sudo` resets `HOME` to root's, so root can't see it and ncurses-based tools (`sudo -e`, `systemctl edit`, etc.) fail.


```bash
infocmp -x xterm-ghostty > /tmp/xterm-ghostty.ti
sudo tic -x -o /usr/share/terminfo /tmp/xterm-ghostty.ti
rm /tmp/xterm-ghostty.ti
```

**Verify:**

```bash
sudo infocmp xterm-ghostty   # should print the full entry, not an error
sudo systemctl edit nvidia-persistenced.service  # Test this works
```

**Notes:**

- Run this from a normal (non-sudo) shell where `xterm-ghostty` already resolves — Ghostty installs the user-local copy automatically the first time it runs.
- If `tic` warns `alias ghostty multiply defined`, that's harmless — it just means a separate `ghostty` terminfo entry already existed alongside `xterm-ghostty`; the install still succeeds.
- This needs redoing on every fresh Ubuntu install (or any time `/usr/share/terminfo` is reset), since it writes to a system path outside your home directory.

## GPU idle power fix — NVIDIA persistence mode

**The problem:** An idle NVIDIA GPU (RTX A6000, headless workstation) draws 70-90W instead of its true idle floor of ~6-20W. The cause is that persistence mode is disabled — the `nvidia-persistenced` systemd unit shipped with Ubuntu's driver package starts with a `--no-persistence-mode` flag, so the NVIDIA kernel driver doesn't keep the GPU context initialized between clients. Every time something connects to the GPU — a one-off `nvidia-smi` query, or a library like XGBoost/PyTorch briefly probing CUDA availability at import — the driver has to spin the GPU up to full P0 clocks to service that connection. With connections happening often enough (monitoring loops, repeated queries, parallel test runs), the GPU never gets the chance to settle back down to its low-power P8 idle state. Enabling persistence mode keeps the driver permanently initialized, so new connections no longer trigger a wake-to-full-power cycle — the GPU idles at its true low-power floor and only draws real power when something actually asks it to compute.

**The fix (persists across reboots):**

1. Create a systemd drop-in override rather than editing the packaged unit file directly (so a driver package update won't silently revert it):

   ```bash
   sudo systemctl edit nvidia-persistenced.service
   ```

2. In the editor that opens, add:

   ```ini
   [Service]
   ExecStart=
   ExecStart=/usr/bin/nvidia-persistenced --user nvidia-persistenced --verbose
   ```

   The blank `ExecStart=` first is required — systemd only lets you *replace* `ExecStart` if you clear it first, otherwise your line just appends to the original (which still has `--no-persistence-mode` in it). The second line matches the packaged command with `--no-persistence-mode` dropped; `nvidia-persistenced` enables persistence mode by default when that flag is absent. Save and exit.

3. Reload systemd and restart the service:

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart nvidia-persistenced
   ```

4. Verify:

   ```bash
   systemctl cat nvidia-persistenced.service               # confirm the override merged in
   nvidia-smi --query-gpu=persistence_mode --format=csv,noheader   # should say "Enabled"
   ps aux | grep nvidia-persistenced                        # cmdline should not show --no-persistence-mode
   ```

   A reboot is the real test — confirm `persistence_mode` still reports `Enabled` afterward without re-running anything manually.

**Diagnostic notes for next time:** `nvidia-smi -q -d POWER` shows a rolling Min/Max/Avg power window, useful for catching intermittent spikes. `nvidia-smi --query-gpu=power.draw,pstate,utilization.gpu --format=csv -l 1` (one persistent connection, not a shell loop of one-off calls) is the right way to watch live power without the polling itself causing the same wake-up churn you're trying to diagnose. Genuine brief spikes (P2, tens of watts, seconds-long, 0% utilization) can still happen when something on the machine imports a CUDA-aware library (PyTorch, XGBoost) even for CPU-only work — that's expected NVML/driver activity, not a misconfiguration.

# Neovim

You can find my nvim config [here](https://github.com/JackKelly/kickstart-modular.nvim).

# OpenCode custom config

(Update: I've switched from OpenCode to Claude Code!)

You can find my custom opencode agents and commands and other config
[here](https://github.com/JackKelly/opencode_config).
