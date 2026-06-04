# 🐦 Remote Flutter/Android Dev Server

> Turn a headless **Ubuntu Server 24.04** into a remote Flutter/Android development machine.
> Connect from your laptop via VS Code Remote-SSH and deploy directly to a USB-connected Android device — no GUI on the server required.

---

## 📦 What it sets up

| Step | Script | Description |
|------|--------|-------------|
| 1 | `01-base.sh` | System packages + OpenJDK 17 (headless) |
| 2 | `02-flutter.sh` | Flutter SDK — stable channel |
| 3 | `03-android.sh` | Android SDK — cmdline-tools, platform-tools, licenses |
| 4 | `04-usb.sh` | Rootless ADB — `plugdev` group + udev rules |
| 5 | `05-proxy.sh` | *(Optional)* HTTP/HTTPS proxy for shell, apt, git, npm |
| 6 | `06-finish.sh` | Verify with `flutter doctor` + print cheat sheet |

`scrcpy-tunnel.sh` — laptop-side helper to mirror the phone screen over SSH.

---

## ✅ Requirements

- Ubuntu Server 24.04 (bare metal, VM, or VPS)
- Regular (non-root) user with `sudo` access
- Outbound internet access — or [configure proxy first](#-proxy)
- Android device connected via USB

---

## 🚀 Quick start

```bash
git clone https://github.com/your-username/remote-flutter-setup.git
cd remote-flutter-setup
chmod +x *.sh
```

Optionally edit `00-env.sh` to change SDK versions or set a proxy URL, then run the steps in order:

```bash
./01-base.sh       # packages + JDK
./02-flutter.sh    # Flutter SDK
./03-android.sh    # Android SDK
./04-usb.sh        # USB / ADB access
```

> ⚠️ **Re-login via SSH** after step 04 — the `plugdev` group won't apply until you do.

```bash
./06-finish.sh     # flutter doctor + cheat sheet
```

> ♻️ All scripts are **idempotent** — re-running skips already-completed steps.

---

## 🔒 Proxy

If the server can only reach the internet through a proxy, run this **before** `01-base.sh`:

```bash
# Set PROXY_URL in 00-env.sh first, then:
./05-proxy.sh on     # enable  (shell, apt, git, npm)
./05-proxy.sh off    # disable
```

> **Note:** `sdkmanager` ignores standard `http_proxy` env vars (Java quirk). The script passes `--proxy_host`/`--proxy_port` flags to `sdkmanager` directly to work around this.

---

## 📱 Phone screen on your laptop (scrcpy)

Copy `scrcpy-tunnel.sh` to your **laptop**. Requires [scrcpy](https://github.com/Genymobile/scrcpy) installed locally.

```bash
./scrcpy-tunnel.sh user@<server-ip>
```

One command does everything:
- 🔗 Opens an SSH tunnel to forward ADB ports in the background
- 📺 Launches scrcpy pointed at the remote ADB server
- 🧹 Kills the tunnel automatically when you close scrcpy

---

## 💻 VS Code workflow

1. Install the [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension on your laptop
2. `Ctrl+Shift+P` → **Remote-SSH: Connect to Host** → select your server
3. Install **Flutter** and **Dart** extensions *in SSH* when prompted
4. Open your project and press `F5` to run/debug on the connected device

---

## 📝 Notes

- **Headless JDK** — `openjdk-17-jdk-headless` is intentional. The full JDK pulls in AWT/Swing → X11 libs that cannot resolve on a display-less server.
- **USB re-login** — after `04-usb.sh`, re-login is mandatory for `plugdev` group membership to take effect. Until then `adb` requires root.
- **~/.bashrc blocks** — each script writes a tagged, idempotent block. Re-running replaces the existing block instead of duplicating it.

---

## 📄 License

[MIT](LICENSE)
