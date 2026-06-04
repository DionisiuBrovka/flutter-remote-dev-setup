#!/usr/bin/env bash
#
# 00-env.sh — общие настройки и функции. НЕ запускается напрямую,
# его подключают остальные шаги (source). Правишь один раз под себя.
#
# ┌─────────────────────────────────────────────────────────────┐
# │  ОТРЕДАКТИРУЙ ЭТОТ БЛОК ПОД СЕБЯ                              │
# └─────────────────────────────────────────────────────────────┘

# Прокси (шаг 05). Оставь пустым, если прокси не нужен.
# Примеры: "http://127.0.0.1:8080"  или  "http://user:pass@proxy.local:3128"
PROXY_URL=""
# Что НЕ гнать через прокси:
NO_PROXY_HOSTS="localhost,127.0.0.1,::1"

# Версии и пути (можно не трогать)
FLUTTER_CHANNEL="stable"
FLUTTER_DIR="$HOME/flutter"
ANDROID_SDK_ROOT="$HOME/android-sdk"
ANDROID_PLATFORM="android-36"
ANDROID_BUILD_TOOLS="28.0.3"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"

# ──────────────────────────────────────────────────────────────────
# Дальше трогать не нужно
# ──────────────────────────────────────────────────────────────────

# Цветной вывод
c_info()  { printf '\033[1;34m[*]\033[0m %s\n' "$*"; }
c_ok()    { printf '\033[1;32m[OK]\033[0m %s\n' "$*"; }
c_warn()  { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
c_err()   { printf '\033[1;31m[ERR]\033[0m %s\n' "$*" >&2; }

# Защита от запуска от root
ensure_not_root() {
  if [[ "${EUID}" -eq 0 ]]; then
    c_err "Не запускай от root. Запусти от обычного пользователя — sudo вызовется сам."
    exit 1
  fi
}

# Идемпотентная вставка блока в ~/.bashrc (заменяет старый блок с тем же тегом)
bashrc_set_block() {
  local tag="$1" content="$2" file="$HOME/.bashrc"
  local start="# >>> ${tag} >>>" end="# <<< ${tag} <<<"
  touch "$file"
  if grep -qF "$start" "$file"; then
    sed -i "\|${start}|,\|${end}|d" "$file"
  fi
  printf '\n%s\n%s\n%s\n' "$start" "$content" "$end" >> "$file"
}

# Удалить блок из ~/.bashrc по тегу
bashrc_del_block() {
  local tag="$1" file="$HOME/.bashrc"
  local start="# >>> ${tag} >>>" end="# <<< ${tag} <<<"
  [[ -f "$file" ]] && grep -qF "$start" "$file" && sed -i "\|${start}|,\|${end}|d" "$file"
}

# Находим JDK 17 (может быть пусто до установки на шаге 01 — это нормально)
JAVA_HOME_17="$(ls -d /usr/lib/jvm/java-17-openjdk-* 2>/dev/null | head -n1 || true)"

# Экспортируем пути в ТЕКУЩИЙ процесс, чтобы каждый шаг был самодостаточным
[[ -n "${JAVA_HOME_17}" ]] && export JAVA_HOME="${JAVA_HOME_17}" && export PATH="${JAVA_HOME}/bin:${PATH}"
export ANDROID_SDK_ROOT
export ANDROID_HOME="${ANDROID_SDK_ROOT}"
export PATH="${FLUTTER_DIR}/bin:${PATH}"
export PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"
export PATH="${HOME}/.local/bin:${PATH}"
