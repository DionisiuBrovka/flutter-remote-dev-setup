#!/usr/bin/env bash
# 03-android.sh — Android SDK (cmdline-tools + platform-tools), компоненты, лицензии.
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
ensure_not_root

# cmdline-tools
if [[ -d "${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin" ]]; then
  c_warn "cmdline-tools уже установлены — пропускаю скачивание."
else
  c_info "Скачиваю Android command line tools..."
  mkdir -p "${ANDROID_SDK_ROOT}"
  tmp_zip="$(mktemp --suffix=.zip)"
  wget -O "${tmp_zip}" "${CMDLINE_TOOLS_URL}"
  rm -rf "${ANDROID_SDK_ROOT}/cmdline-tools"
  unzip -q "${tmp_zip}" -d "${ANDROID_SDK_ROOT}/cmdline-tools"
  mv "${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools" "${ANDROID_SDK_ROOT}/cmdline-tools/latest"
  rm -f "${tmp_zip}"
  c_ok "cmdline-tools установлены."
fi

bashrc_set_block "android-sdk" "export ANDROID_SDK_ROOT=\"${ANDROID_SDK_ROOT}\"
export ANDROID_HOME=\"${ANDROID_SDK_ROOT}\"
export PATH=\"\$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin\"
export PATH=\"\$PATH:${ANDROID_SDK_ROOT}/platform-tools\""

export PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"

# Определяем прокси для sdkmanager (Java НЕ читает http_proxy сама).
# Берём из PROXY_URL (00-env.sh) или из переменных окружения https_proxy/http_proxy.
SDK_PROXY_ARGS=()
PROXY_RAW="${PROXY_URL:-${https_proxy:-${http_proxy:-}}}"
if [[ -n "${PROXY_RAW}" ]]; then
  p="${PROXY_RAW#*://}"   # убираем схему http://
  p="${p##*@}"            # убираем user:pass@
  p="${p%/}"              # убираем хвостовой /
  PHOST="${p%%:*}"
  PPORT="${p##*:}"
  if [[ -n "${PHOST}" && "${PPORT}" =~ ^[0-9]+$ ]]; then
    SDK_PROXY_ARGS=(--proxy=http --proxy_host="${PHOST}" --proxy_port="${PPORT}")
    c_info "sdkmanager пойдёт через прокси ${PHOST}:${PPORT}"
  fi
fi

c_info "Ставлю platform-tools, ${ANDROID_PLATFORM}, build-tools ${ANDROID_BUILD_TOOLS}..."
# Вывод НЕ прячем в /dev/null — чтобы видеть ошибки.
# 'yes' отвечает 'y' на лицензии; его SIGPIPE-падение игнорируем через PIPESTATUS.
set +o pipefail
yes | sdkmanager "${SDK_PROXY_ARGS[@]}" --sdk_root="${ANDROID_SDK_ROOT}" \
  "platform-tools" \
  "platforms;${ANDROID_PLATFORM}" \
  "build-tools;${ANDROID_BUILD_TOOLS}"
sdk_rc=${PIPESTATUS[1]}   # реальный код возврата самого sdkmanager
set -o pipefail
if [[ "${sdk_rc}" -ne 0 ]]; then
  c_err "sdkmanager завершился с ошибкой (код ${sdk_rc}). Смотри сообщение выше."
  c_err "Если это сетевая ошибка — проверь, что прокси указан верно (см. выше)."
  exit 1
fi
c_ok "Компоненты Android SDK установлены."

c_info "Привязываю SDK к Flutter и принимаю лицензии..."
flutter config --android-sdk "${ANDROID_SDK_ROOT}" >/dev/null
set +o pipefail
yes | flutter doctor --android-licenses >/dev/null
set -o pipefail

c_ok "Шаг 3 готов. Дальше: ./04-usb.sh"
