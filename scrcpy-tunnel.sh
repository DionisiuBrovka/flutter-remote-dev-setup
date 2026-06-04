#!/usr/bin/env bash
# scrcpy-tunnel.sh — экран телефона через удалённый сервер.
# Кладётся на НОУТ. Использование: ./scrcpy-tunnel.sh user@<ip_сервера>
set -euo pipefail

TARGET="${1:?Укажи адрес сервера: $0 user@<ip>}"

if lsof -ti:5038 >/dev/null 2>&1; then
    echo "Туннель уже запущен (порт 5038 занят), подключаемся..."
else
    ssh -fCN \
        -o ExitOnForwardFailure=yes \
        -o ControlMaster=no \
        -L5038:localhost:5037 \
        -L27183:localhost:27183 \
        "$TARGET"
    echo "Туннель запущен."
fi

cleanup() {
    pkill -f "ssh -fCN.*${TARGET}" 2>/dev/null || true
}
trap cleanup EXIT

ADB_SERVER_SOCKET=tcp:localhost:5038 \
    scrcpy --force-adb-forward --max-size 800 --video-bit-rate 2M --max-fps 15
