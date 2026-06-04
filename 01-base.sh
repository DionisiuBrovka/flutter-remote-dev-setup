#!/usr/bin/env bash
# 01-base.sh — system packages + OpenJDK 17.
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
ensure_not_root

c_info "Installing base packages and OpenJDK 17 (headless)..."
sudo apt-get update -y
# NOTE: openjdk-17-jdk-headless is intentional.
# The full openjdk-17-jdk pulls in AWT/Swing -> libgl1 -> X11, which cannot
# resolve on a display-less server. Flutter/Android builds don't need a GUI.
sudo apt-get install -y \
  git curl wget unzip xz-utils gpg ca-certificates \
  openjdk-17-jdk-headless
c_ok "Packages installed."

# Re-read JDK 17 path (now guaranteed to exist) and write to ~/.bashrc
JAVA_HOME_17="$(ls -d /usr/lib/jvm/java-17-openjdk-* 2>/dev/null | head -n1 || true)"
if [[ -z "${JAVA_HOME_17}" ]]; then
  c_err "OpenJDK 17 not found in /usr/lib/jvm. Check that openjdk-17-jdk-headless installed correctly."
  exit 1
fi

bashrc_set_block "flutter-java" "export JAVA_HOME=\"${JAVA_HOME_17}\"
export PATH=\"\$JAVA_HOME/bin:\$PATH\""

c_ok "JAVA_HOME = ${JAVA_HOME_17} (written to ~/.bashrc)"
c_ok "Step 1 done. Next: ./02-flutter.sh"
