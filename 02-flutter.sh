#!/usr/bin/env bash
# 02-flutter.sh — установка Flutter SDK.
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
ensure_not_root

if [[ -d "${FLUTTER_DIR}/bin" ]]; then
  c_warn "Flutter уже есть в ${FLUTTER_DIR} — пропускаю клонирование."
else
  c_info "Клонирую Flutter (${FLUTTER_CHANNEL})..."
  git clone --branch "${FLUTTER_CHANNEL}" https://github.com/flutter/flutter.git "${FLUTTER_DIR}"
  c_ok "Flutter склонирован в ${FLUTTER_DIR}."
fi

bashrc_set_block "flutter-path" "export PATH=\"\$HOME/flutter/bin:\$PATH\""

export PATH="${FLUTTER_DIR}/bin:${PATH}"
c_info "Прогреваю инструменты (первый запуск может занять минуту)..."
flutter --version

c_ok "Шаг 2 готов. Дальше: ./03-android.sh"
