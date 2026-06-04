#!/usr/bin/env bash
# 03-android.sh — Android SDK (cmdline-tools + platform-tools), components, licenses.
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
ensure_not_root

# cmdline-tools
if [[ -d "${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin" ]]; then
  c_warn "cmdline-tools already installed — skipping download."
else
  c_info "Downloading Android command-line tools..."
  mkdir -p "${ANDROID_SDK_ROOT}"
  tmp_zip="$(mktemp --suffix=.zip)"
  wget -O "${tmp_zip}" "${CMDLINE_TOOLS_URL}"
  rm -rf "${ANDROID_SDK_ROOT}/cmdline-tools"
  unzip -q "${tmp_zip}" -d "${ANDROID_SDK_ROOT}/cmdline-tools"
  mv "${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools" "${ANDROID_SDK_ROOT}/cmdline-tools/latest"
  rm -f "${tmp_zip}"
  c_ok "cmdline-tools installed."
fi

bashrc_set_block "android-sdk" "export ANDROID_SDK_ROOT=\"${ANDROID_SDK_ROOT}\"
export ANDROID_HOME=\"${ANDROID_SDK_ROOT}\"
export PATH=\"\$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin\"
export PATH=\"\$PATH:${ANDROID_SDK_ROOT}/platform-tools\""

export PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"

# Build sdkmanager proxy args — Java does NOT read http_proxy env vars on its own.
# We parse PROXY_URL (from 00-env.sh) or fall back to https_proxy / http_proxy.
SDK_PROXY_ARGS=()
PROXY_RAW="${PROXY_URL:-${https_proxy:-${http_proxy:-}}}"
if [[ -n "${PROXY_RAW}" ]]; then
  p="${PROXY_RAW#*://}"   # strip scheme
  p="${p##*@}"            # strip user:pass@
  p="${p%/}"              # strip trailing slash
  PHOST="${p%%:*}"
  PPORT="${p##*:}"
  if [[ -n "${PHOST}" && "${PPORT}" =~ ^[0-9]+$ ]]; then
    SDK_PROXY_ARGS=(--proxy=http --proxy_host="${PHOST}" --proxy_port="${PPORT}")
    c_info "sdkmanager will use proxy ${PHOST}:${PPORT}"
  fi
fi

c_info "Installing platform-tools, ${ANDROID_PLATFORM}, build-tools ${ANDROID_BUILD_TOOLS}..."
# Output is NOT suppressed — errors need to be visible.
# 'yes' answers license prompts; its SIGPIPE exit is ignored via PIPESTATUS.
set +o pipefail
yes | sdkmanager "${SDK_PROXY_ARGS[@]}" --sdk_root="${ANDROID_SDK_ROOT}" \
  "platform-tools" \
  "platforms;${ANDROID_PLATFORM}" \
  "build-tools;${ANDROID_BUILD_TOOLS}"
sdk_rc=${PIPESTATUS[1]}
set -o pipefail
if [[ "${sdk_rc}" -ne 0 ]]; then
  c_err "sdkmanager exited with error (code ${sdk_rc}). See output above."
  c_err "If this is a network error, check that the proxy is configured correctly."
  exit 1
fi
c_ok "Android SDK components installed."

c_info "Linking SDK to Flutter and accepting licenses..."
flutter config --android-sdk "${ANDROID_SDK_ROOT}" >/dev/null
set +o pipefail
yes | flutter doctor --android-licenses >/dev/null
set -o pipefail

c_ok "Step 3 done. Next: ./04-usb.sh"
