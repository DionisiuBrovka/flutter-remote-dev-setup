# Remote Flutter/Android Dev Server

Shell scripts to turn a headless **Ubuntu Server 24.04** into a remote Flutter/Android development machine. Connect from your laptop via VS Code Remote-SSH and deploy directly to a USB-connected Android device — no GUI on the server required.

## What it sets up

| Script | Description |
|--------|-------------|
| `01-base.sh` | System packages + OpenJDK 17 (headless) |
| `02-flutter.sh` | Flutter SDK (stable channel, cloned from GitHub) |
| `03-android.sh` | Android SDK command-line tools, platform-tools, licenses |
| `04-usb.sh` | `plugdev` group + udev rules for rootless ADB |
| `05-proxy.sh` | *(Optional)* HTTP/HTTPS proxy for shell, apt, git, npm |
| `06-finish.sh` | Verification via `flutter doctor` + usage cheat sheet |

`scrcpy-tunnel.sh` — helper for your **laptop** to mirror the phone screen over SSH (see below).

## Requirements

- Ubuntu Server 24.04 (bare metal, VM, or VPS)
- A regular (non-root) user account with `sudo` access
- Outbound internet access (or set up proxy first — see [Proxy](#proxy))
- An Android device connected via USB (for ADB and deployment)

## Quick start

```bash
# 1. Get the scripts onto the server
git clone https://github.com/your-username/remote-flutter-setup.git
cd remote-flutter-setup
chmod +x *.sh

# 2. (Optional) edit SDK versions or proxy URL
nano 00-env.sh

# 3. Run in order
./01-base.sh
./02-flutter.sh
./03-android.sh
./04-usb.sh

# !! Re-login via SSH here for USB access to take effect !!

./06-finish.sh     # runs flutter doctor and prints the cheat sheet
```

> All scripts are **idempotent** — re-running skips already-completed steps.

## Proxy

If the server can only reach the internet through a proxy, run this **before** `01-base.sh`:

```bash
# Set PROXY_URL in 00-env.sh first, then:
./05-proxy.sh on     # enable  (shell, apt, git, npm)
./05-proxy.sh off    # disable
```

> **Note:** `sdkmanager` (used in step 03) ignores standard `http_proxy` env vars because Java has its own proxy handling. The script works around this by passing `--proxy_host`/`--proxy_port` flags directly.

## Viewing the phone screen from your laptop

Copy `scrcpy-tunnel.sh` to your **laptop** (not the server). Requires [scrcpy](https://github.com/Genymobile/scrcpy) installed locally.

```bash
./scrcpy-tunnel.sh user@<server-ip>
```

This single command:
- Opens an SSH tunnel to forward ADB ports in the background
- Launches scrcpy pointed at the remote ADB server
- Kills the tunnel automatically when you close scrcpy

## VS Code workflow

1. Install the **Remote - SSH** extension on your laptop
2. Connect to the server: `Ctrl+Shift+P` → *Remote-SSH: Connect to Host*
3. Install **Flutter** and **Dart** extensions *in SSH* (VS Code will prompt)
4. Open your project folder and press `F5` to run/debug on the USB device

## Notes

**Headless JDK** — `openjdk-17-jdk-headless` is used intentionally. The full JDK pulls in AWT/Swing libraries that depend on X11, which cannot resolve on a display-less server.

**USB group** — after `04-usb.sh` you must re-login (or reboot) for the `plugdev` group assignment to take effect. Until then `adb` requires root.

**~/.bashrc blocks** — each script writes a tagged, idempotent block to `~/.bashrc`. Re-running a script replaces the existing block rather than appending a duplicate.

## License

MIT
