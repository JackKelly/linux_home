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


### `fzf`

1. `sudo apt install fzf`
2. [Set up shell integration](https://github.com/junegunn/fzf?tab=readme-ov-file#setting-up-shell-integration). (This is still necessary even after installing `fzf` is via APT.)

### `zoxide`

Install: `sudo apt install zoxide`

And append this to the end of `~/.bashrc`:

```bash
# Set up zoxide
eval "$(zoxide init --cmd cd bash)"
```

### Environment variables to append to `~/.bashrc`

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

# Dagster
export DAGSTER_HOME=/home/jack/dagster_home/

# opencode
export PATH=/home/jack/.opencode/bin:$PATH

# Required by Claude Code
export PATH="$HOME/.local/bin:$PATH"
```

## Install on desktop

```bash
sudo apt install easyeffects 
sudo snap install ghostty slack spotify
```

Install the [TopHat Gnome extension](https://extensions.gnome.org/extension/5219/tophat/) to show CPU usage etc. in the top bar.

* `easyeffects` is useful to filter audio during video calls, to reduce "boomy" noises and high-pitched hisses.
* Maybe also [install OBS Studio](https://github.com/obsproject/obs-studio/wiki/install-instructions#linux) to zoom my webcam during video calls.

## Install on headless servers

### Set `amd_pstate=active`

On a desktop machine, Ubuntu already defaults to using `amd_pstate=active`. But not so on servers.
Change it:

- `sudo nvim /etc/default/grub`
- append `amd_pstate=active` to the line `GRUB_CMDLINE_LINUX_DEFAULT="..."`
- `sudo update-grub`
- reboot

### CPU power-saving: governor, EPP, min frequency, and btop power readout

**Applies to:** AMD systems using the `amd-pstate-epp` driver (`amd_pstate=active`
— see above; already the default on desktop, but not on Ubuntu Server). Check
with `cpupower frequency-info` — the `driver:` line should say `amd-pstate-epp`.

1. **Set the governor to `powersave`:**

   ```bash
   sudo cpupower frequency-set -g powersave
   ```

   On `amd-pstate-epp` this is a genuine dynamic-range governor — it can still
   reach full boost under load — unlike the old `acpi-cpufreq` driver, where
   `powersave` clamps to the minimum frequency.

2. **Set Energy Performance Preference (EPP) to `power`.** This is a separate
   knob from the governor and defaults to `performance`, which biases the CPU
   to clock up eagerly even while the governor is `powersave`:

   ```bash
   sudo sh -c 'for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do echo power > "$f"; done'
   ```

3. **Lower the minimum frequency to the hardware floor.** `amd-pstate-epp`
   defaults `scaling_min_freq` to the "Lowest Non-linear Frequency" (2.2 GHz on
   this workstation), not the true hardware minimum (~400 MHz) — the two steps
   above don't touch this, so without it the CPU never idles below ~2.2 GHz.
   Check the real floor first:

   ```bash
   cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq
   ```

   then set it (in kHz — adjust to match your hardware floor):

   ```bash
   sudo cpupower frequency-set -d 400000
   ```

4. **Persist all three across reboot** with a oneshot systemd unit:

   ```bash
   sudo tee /etc/systemd/system/cpu-powersave.service << 'EOF'
   [Unit]
   Description=Set CPU governor to powersave, EPP to power, and allow full frequency range
   After=multi-user.target

   [Service]
   Type=oneshot
   ExecStart=/usr/bin/cpupower frequency-set -g powersave
   ExecStart=/usr/bin/cpupower frequency-set -d 400000
   ExecStart=/bin/sh -c 'for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do echo power > "$f"; done'
   RemainAfterExit=yes

   [Install]
   WantedBy=multi-user.target
   EOF
   sudo systemctl daemon-reload
   sudo systemctl enable --now cpu-powersave.service
   ```

   (Drop the third `ExecStart` line on `acpi-cpufreq` systems — no EPP knob
   there.)

5. **Install `btop` and give it permission to read CPU power draw.** `btop`
   reads the RAPL energy counter at `/sys/class/powercap/intel-rapl:0/energy_uj`
   (named `intel-rapl` even on AMD — the powercap framework was extended to
   cover AMD rather than renamed). It's root-only by default:

   ```bash
   sudo apt install btop
   sudo tee /etc/udev/rules.d/90-rapl-power.rules << 'EOF'
   SUBSYSTEM=="powercap", ACTION=="add", RUN+="/bin/sh -c 'chmod -R a+r /sys/class/powercap/intel-rapl*'"
   EOF
   sudo udevadm control --reload-rules
   sudo udevadm trigger --action=add --subsystem-match=powercap
   ```

   `udevadm trigger` defaults to the `change` action, which silently does not
   match this rule's `ACTION=="add"` — the explicit `--action=add` above is
   required to apply the rule immediately without a reboot. On a genuine
   reboot the rule fires on its own.

   Security note: this makes the CPU package power counter readable by any
   local user, which is what the kernel's default root-only lockdown (the
   "Platypus" side-channel mitigation) is meant to prevent. Fine for a
   single-user workstation; skip this step and use `sudo btop` instead on a
   shared machine.

**Verify:**

```bash
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor | sort -u                    # powersave
cat /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference | sort -u       # power
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq | sort -u                    # near cpuinfo_min_freq
watch -n 0.5 'grep MHz /proc/cpuinfo'   # idle sags low, load snaps to boost within ~1s
btop                                     # power draw shown in the CPU panel, no sudo needed
```

**What the power reading covers:** the RAPL `package-0` domain is the whole CPU
package (cores, L3, memory controller, I/O die) as measured by the CPU's own
firmware — it does not include RAM, a discrete GPU, storage, or PSU losses, so
it reads lower than a wall-power meter on the whole machine.

### GPU idle power fix — NVIDIA persistence mode

**The problem:** An idle NVIDIA GPU (RTX A6000, headless workstation) draws 70-90W instead of its true idle floor of ~6-20W. The cause is that persistence mode is disabled — the `nvidia-persistenced` systemd unit shipped with Ubuntu's driver package starts with a `--no-persistence-mode` flag, so the NVIDIA kernel driver doesn't keep the GPU context initialized between clients. Every time something connects to the GPU — a one-off `nvidia-smi` query, or a library like XGBoost/PyTorch briefly probing CUDA availability at import — the driver has to spin the GPU up to full P0 clocks to service that connection. With connections happening often enough (monitoring loops, repeated queries, parallel test runs), the GPU never gets the chance to settle back down to its low-power P8 idle state. Enabling persistence mode keeps the driver permanently initialized, so new connections no longer trigger a wake-to-full-power cycle — the GPU idles at its true low-power floor and only draws real power when something actually asks it to compute.

This fix reduces the GPU's temperature at idle from 60 °C to 32 °C!

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

### Fix: `ncurses: cannot initialize terminal type ($TERM="xterm-ghostty")`

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

# Neovim

You can find my nvim config [here](https://github.com/JackKelly/kickstart-modular.nvim).

# OpenCode custom config

(Update: I've switched from OpenCode to Claude Code!)

You can find my custom opencode agents and commands and other config
[here](https://github.com/JackKelly/opencode_config).
