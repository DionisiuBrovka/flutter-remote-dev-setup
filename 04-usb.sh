#!/usr/bin/env bash
# 04-usb.sh — доступ к телефону по USB без root (группа plugdev + udev).
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
ensure_not_root

# Группа plugdev (на свежих релизах может отсутствовать) — создаём, если нет
sudo groupadd -f plugdev

# Android udev-правила: пробуем штатный пакет, иначе кладём универсальное правило.
# Правило ловит любой телефон в режиме adb по классу USB-интерфейса (ff4201),
# поэтому не зависит от производителя.
if [[ -e /lib/udev/rules.d/51-android.rules || -e /etc/udev/rules.d/51-android.rules ]]; then
  c_ok "Android udev-правила уже есть."
elif sudo apt-get install -y android-udev-rules 2>/dev/null; then
  c_ok "android-udev-rules установлены из пакета."
else
  c_warn "Пакет android-udev-rules недоступен — ставлю универсальное правило вручную."
  echo 'SUBSYSTEM=="usb", ENV{ID_USB_INTERFACES}=="*:ff4201:*", GROUP="plugdev", MODE="0660", TAG+="uaccess"' \
    | sudo tee /etc/udev/rules.d/51-android.rules >/dev/null
  c_ok "Создано /etc/udev/rules.d/51-android.rules"
fi

if id -nG "$USER" | grep -qw plugdev; then
  c_ok "Пользователь уже в группе plugdev."
else
  c_info "Добавляю $USER в группу plugdev..."
  sudo usermod -aG plugdev "$USER"
  c_warn "Группа применится только после ПЕРЕЛОГИНА (или перезагрузки)."
fi

c_info "Перезагружаю udev-правила..."
sudo udevadm control --reload-rules
sudo udevadm trigger
c_ok "udev-правила перезагружены."

echo
c_warn "ВАЖНО: выйди из ssh и зайди заново (или перезагрузи сервер),"
c_warn "иначе adb будет видеть телефон только из-под root."
echo
echo "После перелогина воткни телефон по USB, включи 'Отладку по USB' и проверь:"
echo "    adb devices      # подтверди запрос НА ЭКРАНЕ ТЕЛЕФОНА"
echo "    flutter devices  # телефон должен появиться"
echo
c_ok "Шаг 4 готов. Дальше: ./05-proxy.sh (опционально) или ./06-github.sh"
