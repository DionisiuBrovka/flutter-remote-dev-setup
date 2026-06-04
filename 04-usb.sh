#!/usr/bin/env bash
# 04-usb.sh — rootless USB access for ADB (plugdev group + udev rules).
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
ensure_not_root

# Create plugdev group if it doesn't exist (absent on some minimal installs)
sudo groupadd -f plugdev

# Android udev rules: try the distro package first, fall back to a universal rule.
# The universal rule matches any phone in ADB mode by USB interface class (ff4201),
# so it works regardless of manufacturer.
if [[ -e /lib/udev/rules.d/51-android.rules || -e /etc/udev/rules.d/51-android.rules ]]; then
  c_ok "Android udev rules already present."
elif sudo apt-get install -y android-udev-rules 2>/dev/null; then
  c_ok "android-udev-rules installed from package."
else
  c_warn "Package android-udev-rules not available — writing a universal rule manually."
  echo 'SUBSYSTEM=="usb", ENV{ID_USB_INTERFACES}=="*:ff4201:*", GROUP="plugdev", MODE="0660", TAG+="uaccess"' \
    | sudo tee /etc/udev/rules.d/51-android.rules >/dev/null
  c_ok "Created /etc/udev/rules.d/51-android.rules"
fi

if id -nG "$USER" | grep -qw plugdev; then
  c_ok "User already in plugdev group."
else
  c_info "Adding $USER to plugdev group..."
  sudo usermod -aG plugdev "$USER"
  c_warn "Group membership takes effect only after re-login (or reboot)."
fi

c_info "Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger
c_ok "udev rules reloaded."

echo
c_warn "IMPORTANT: log out of SSH and back in (or reboot the server)."
c_warn "Until then, adb will only see the phone as root."
echo
echo "After re-login, plug in the phone, enable USB debugging, and verify:"
echo "    adb devices      # confirm the prompt ON THE PHONE SCREEN"
echo "    flutter devices  # the phone should appear"
echo
c_ok "Step 4 done. Next: ./05-proxy.sh (optional) or ./06-finish.sh"
