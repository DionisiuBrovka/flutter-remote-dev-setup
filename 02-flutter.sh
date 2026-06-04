#!/usr/bin/env bash
# 02-flutter.sh — Flutter SDK installation.
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
ensure_not_root

if [[ -d "${FLUTTER_DIR}/bin" ]]; then
  c_warn "Flutter already found at ${FLUTTER_DIR} — skipping clone."
else
  c_info "Cloning Flutter (${FLUTTER_CHANNEL})..."
  git clone --branch "${FLUTTER_CHANNEL}" https://github.com/flutter/flutter.git "${FLUTTER_DIR}"
  c_ok "Flutter cloned to ${FLUTTER_DIR}."
fi

bashrc_set_block "flutter-path" "export PATH=\"\$HOME/flutter/bin:\$PATH\""

export PATH="${FLUTTER_DIR}/bin:${PATH}"
c_info "Warming up Flutter tools (first run may take a minute)..."
flutter --version

c_ok "Step 2 done. Next: ./03-android.sh"
