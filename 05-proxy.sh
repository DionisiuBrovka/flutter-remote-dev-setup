#!/usr/bin/env bash
# 05-proxy.sh — OPTIONAL. Enable or disable HTTP/HTTPS proxy for shell, apt, git, npm.
#
#   ./05-proxy.sh on    # enable (reads PROXY_URL from 00-env.sh)
#   ./05-proxy.sh off   # disable and remove all proxy settings
#
# If the server can only reach the internet through a proxy, run this step
# FIRST — before 01-base.sh — otherwise apt won't be able to reach the network.
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
ensure_not_root

MODE="${1:-}"
APT_CONF="/etc/apt/apt.conf.d/95proxy"

enable_proxy() {
  if [[ -z "${PROXY_URL}" ]]; then
    c_err "PROXY_URL is empty. Set the proxy address in 00-env.sh and re-run."
    exit 1
  fi
  c_info "Enabling proxy: ${PROXY_URL}"

  # 1) shell environment (curl, wget, etc.)
  bashrc_set_block "proxy" "export http_proxy=\"${PROXY_URL}\"
export https_proxy=\"${PROXY_URL}\"
export HTTP_PROXY=\"${PROXY_URL}\"
export HTTPS_PROXY=\"${PROXY_URL}\"
export no_proxy=\"${NO_PROXY_HOSTS}\"
export NO_PROXY=\"${NO_PROXY_HOSTS}\""

  # 2) apt
  sudo tee "${APT_CONF}" >/dev/null <<EOF
Acquire::http::Proxy "${PROXY_URL}";
Acquire::https::Proxy "${PROXY_URL}";
EOF

  # 3) git
  git config --global http.proxy "${PROXY_URL}"
  git config --global https.proxy "${PROXY_URL}"

  # 4) npm (if installed)
  if command -v npm >/dev/null 2>&1; then
    npm config set proxy "${PROXY_URL}"
    npm config set https-proxy "${PROXY_URL}"
  fi

  c_ok "Proxy enabled. Apply to the current session with:  source ~/.bashrc"
}

disable_proxy() {
  c_info "Disabling proxy and removing all proxy settings..."
  bashrc_del_block "proxy"
  sudo rm -f "${APT_CONF}"
  git config --global --unset http.proxy  || true
  git config --global --unset https.proxy || true
  if command -v npm >/dev/null 2>&1; then
    npm config delete proxy       || true
    npm config delete https-proxy || true
  fi
  unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY || true
  c_ok "Proxy disabled. Run  source ~/.bashrc  (or open a new terminal) to apply."
}

case "${MODE}" in
  on)  enable_proxy ;;
  off) disable_proxy ;;
  *)   c_err "Usage: ./05-proxy.sh on | off"; exit 1 ;;
esac
