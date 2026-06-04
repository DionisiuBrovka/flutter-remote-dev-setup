#!/usr/bin/env bash
#
# 00-env.sh — shared settings and helpers. NOT an entrypoint — sourced by all
# other scripts. Edit the config block below once before running anything.
#
# ┌─────────────────────────────────────────────────────────────┐
# │  EDIT THIS BLOCK FOR YOUR SETUP                               │
# └─────────────────────────────────────────────────────────────┘

# Proxy (step 05). Leave empty if no proxy is needed.
# Examples: "http://127.0.0.1:8080"  or  "http://user:pass@proxy.local:3128"
PROXY_URL=""
# Hosts that should bypass the proxy:
NO_PROXY_HOSTS="localhost,127.0.0.1,::1"

# Versions and paths (usually no need to change)
FLUTTER_CHANNEL="stable"
FLUTTER_DIR="$HOME/flutter"
ANDROID_SDK_ROOT="$HOME/android-sdk"
ANDROID_PLATFORM="android-36"
ANDROID_BUILD_TOOLS="28.0.3"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"

# ──────────────────────────────────────────────────────────────────
# No need to edit below this line
# ──────────────────────────────────────────────────────────────────

# Coloured output helpers
c_info()  { printf '\033[1;34m[*]\033[0m %s\n' "$*"; }
c_ok()    { printf '\033[1;32m[OK]\033[0m %s\n' "$*"; }
c_warn()  { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
c_err()   { printf '\033[1;31m[ERR]\033[0m %s\n' "$*" >&2; }

# Guard against accidental root execution
ensure_not_root() {
  if [[ "${EUID}" -eq 0 ]]; then
    c_err "Do not run as root. Run as a regular user — sudo is called internally."
    exit 1
  fi
}

# Idempotent tagged block in ~/.bashrc — replaces the existing block with the same tag
bashrc_set_block() {
  local tag="$1" content="$2" file="$HOME/.bashrc"
  local start="# >>> ${tag} >>>" end="# <<< ${tag} <<<"
  touch "$file"
  if grep -qF "$start" "$file"; then
    sed -i "\|${start}|,\|${end}|d" "$file"
  fi
  printf '\n%s\n%s\n%s\n' "$start" "$content" "$end" >> "$file"
}

# Remove a tagged block from ~/.bashrc
bashrc_del_block() {
  local tag="$1" file="$HOME/.bashrc"
  local start="# >>> ${tag} >>>" end="# <<< ${tag} <<<"
  [[ -f "$file" ]] && grep -qF "$start" "$file" && sed -i "\|${start}|,\|${end}|d" "$file"
}

# Locate JDK 17 (may be empty before step 01 — that's fine)
JAVA_HOME_17="$(ls -d /usr/lib/jvm/java-17-openjdk-* 2>/dev/null | head -n1 || true)"

# Export paths into the current process so each script is self-contained
[[ -n "${JAVA_HOME_17}" ]] && export JAVA_HOME="${JAVA_HOME_17}" && export PATH="${JAVA_HOME}/bin:${PATH}"
export ANDROID_SDK_ROOT
export ANDROID_HOME="${ANDROID_SDK_ROOT}"
export PATH="${FLUTTER_DIR}/bin:${PATH}"
export PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"
export PATH="${HOME}/.local/bin:${PATH}"
