#!/usr/bin/env bash
# 06-finish.sh — final verification and usage cheat sheet.
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
ensure_not_root

c_info "Running flutter doctor..."
flutter doctor || true
echo

c_info "Tool versions:"
command -v adb >/dev/null 2>&1 && adb --version | head -n1
echo

c_ok "Setup complete."
echo
echo "───────────────────── CHEAT SHEET ─────────────────────"
echo "VS Code (on laptop): Remote-SSH -> this server -> install Flutter+Dart"
echo "  extensions 'in SSH' -> open project -> F5 to run/debug."
echo
echo "Phone screen mirror (scrcpy on LAPTOP):"
echo "  Copy scrcpy-tunnel.sh to your laptop, then run:"
echo "  ./scrcpy-tunnel.sh $USER@<server-ip>"
echo
echo "If the phone is not detected: make sure you re-logged in after step 04,"
echo "and confirmed the USB debugging prompt on the phone screen (adb devices)."
echo "────────────────────────────────────────────────────────"
