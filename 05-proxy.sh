#!/usr/bin/env bash
# 05-proxy.sh — ОПЦИОНАЛЬНО. Включает/выключает прокси для shell, apt, git, npm.
#
#   ./05-proxy.sh on    # включить (берёт PROXY_URL из 00-env.sh)
#   ./05-proxy.sh off   # выключить и убрать все настройки
#
# Если интернет на сервере доступен ТОЛЬКО через прокси — запусти этот шаг
# ПЕРВЫМ, до 01-base.sh, иначе apt не достучится до сети.
#
# Предполагается обычный HTTP/HTTPS-прокси. Если у тебя SOCKS или что-то
# другое — напиши, подгоню.
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
ensure_not_root

MODE="${1:-}"
APT_CONF="/etc/apt/apt.conf.d/95proxy"

enable_proxy() {
  if [[ -z "${PROXY_URL}" ]]; then
    c_err "PROXY_URL пустой. Впиши адрес прокси в 00-env.sh и запусти снова."
    exit 1
  fi
  c_info "Включаю прокси: ${PROXY_URL}"

  # 1) shell-окружение (для curl и пр.)
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

  # 4) npm (если установлен)
  if command -v npm >/dev/null 2>&1; then
    npm config set proxy "${PROXY_URL}"
    npm config set https-proxy "${PROXY_URL}"
  fi

  c_ok "Прокси включён. Применишь в текущей сессии так:  source ~/.bashrc"
}

disable_proxy() {
  c_info "Выключаю прокси и убираю настройки..."
  bashrc_del_block "proxy"
  sudo rm -f "${APT_CONF}"
  git config --global --unset http.proxy  || true
  git config --global --unset https.proxy || true
  if command -v npm >/dev/null 2>&1; then
    npm config delete proxy       || true
    npm config delete https-proxy || true
  fi
  # сбрасываем переменные в текущем процессе
  unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY || true
  c_ok "Прокси выключен. В текущей сессии:  source ~/.bashrc  (или открой новый терминал)"
}

case "${MODE}" in
  on)  enable_proxy ;;
  off) disable_proxy ;;
  *)   c_err "Использование: ./05-proxy.sh on | off"; exit 1 ;;
esac
