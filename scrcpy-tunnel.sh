#!/usr/bin/env bash
# scrcpy-tunnel.sh — mirror phone screen via a remote dev server.
# Place this on your LAPTOP. Usage: ./scrcpy-tunnel.sh user@<server-ip>
set -euo pipefail

TARGET="${1:?Specify the server address: $0 user@<ip>}"

if lsof -ti:5038 >/dev/null 2>&1; then
    echo "Tunnel already running (port 5038 in use), connecting..."
else
    ssh -fCN \
        -o ExitOnForwardFailure=yes \
        -o ControlMaster=no \
        -L5038:localhost:5037 \
        -L27183:localhost:27183 \
        "$TARGET"
    echo "Tunnel established."
fi

cleanup() {
    pkill -f "ssh -fCN.*${TARGET}" 2>/dev/null || true
}
trap cleanup EXIT

ADB_SERVER_SOCKET=tcp:localhost:5038 \
    scrcpy --force-adb-forward --max-size 800 --video-bit-rate 2M --max-fps 15
