#!/usr/bin/env bash
# 08-finish.sh — финальная проверка и памятка.
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
ensure_not_root

c_info "flutter doctor:"
flutter doctor || true
echo

c_info "Версии инструментов:"
command -v gh     >/dev/null 2>&1 && gh --version | head -n1
command -v claude >/dev/null 2>&1 && echo "claude $(claude --version 2>/dev/null || echo '?')"
command -v adb    >/dev/null 2>&1 && adb --version | head -n1
echo

c_ok "Всё настроено."
echo
echo "─────────────────── ШПАРГАЛКА ───────────────────"
echo "VS Code (на ноуте): Remote-SSH -> этот сервер -> расширения Flutter+Dart"
echo "  ставишь 'в SSH' -> открываешь проект -> F5."
echo
echo "Экран телефона (scrcpy на НОУТЕ):"
echo "  Скопируй scrcpy-tunnel.sh на ноут, затем одной командой:"
echo "  ./scrcpy-tunnel.sh $USER@<ip_сервера>"
echo
echo "Если телефон не виден: убедись, что после шага 04 ты ПЕРЕЛОГИНИЛСЯ,"
echo "и что подтвердил запрос отладки на экране телефона (adb devices)."
echo "──────────────────────────────────────────────────"
