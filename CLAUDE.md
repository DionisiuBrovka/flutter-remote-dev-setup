# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A set of numbered shell scripts that configure a headless Ubuntu Server 24.04 for remote Flutter/Android development. The scripts set up Flutter SDK, Android SDK, USB phone access, and an optional proxy.

## Running the scripts

All scripts must be run **as a regular user** (not root). `sudo` is invoked internally where needed.

```bash
./01-base.sh         # apt packages + OpenJDK 17 headless
./02-flutter.sh      # Flutter SDK (clones from GitHub, stable channel)
./03-android.sh      # Android SDK cmdline-tools + platform-tools + licenses
./04-usb.sh          # plugdev group + udev rules for adb without root
# Re-login via SSH here (plugdev group won't apply until re-login)
./05-proxy.sh on     # optional: set proxy for shell/apt/git/npm
./05-proxy.sh off    # disable proxy
./06-finish.sh       # flutter doctor + cheat sheet
```

After the full run, verify everything with `flutter doctor`.

## Architecture

`00-env.sh` is a **library, not an entrypoint** — it is `source`d by every other script and never run directly. It defines:
- Configurable variables: `PROXY_URL`, SDK versions and paths
- Logging helpers: `c_info`, `c_ok`, `c_warn`, `c_err`
- `ensure_not_root` — exits if running as root
- `bashrc_set_block` / `bashrc_del_block` — idempotent tagged blocks in `~/.bashrc`

All scripts are idempotent: they detect whether their target is already installed and skip re-installation.

## Key design notes

- **Headless JDK**: `openjdk-17-jdk-headless` is intentional. The full JDK pulls in X11/AWT, which fails to resolve on a graphical-less server.
- **sdkmanager proxy**: Java ignores `http_proxy` env vars, so `03-android.sh` parses `PROXY_URL` and passes `--proxy_host`/`--proxy_port` flags to `sdkmanager` explicitly.
- **Proxy-first**: if the server has no direct internet, run `./05-proxy.sh on` before `./01-base.sh`.
- **USB group**: after `04-usb.sh`, a re-login (or reboot) is mandatory for the `plugdev` group to take effect.
- **scrcpy tunnel** (for viewing phone screen from laptop): copy `scrcpy-tunnel.sh` to the laptop and run:
  ```bash
  ./scrcpy-tunnel.sh user@<server-ip>
  ```
  The script starts the SSH tunnel in the background, launches scrcpy, and kills the tunnel on exit.
