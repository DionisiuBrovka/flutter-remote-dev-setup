#!/usr/bin/env bash
# 01-base.sh — базовые пакеты + OpenJDK 17.
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
ensure_not_root

c_info "Устанавливаю базовые пакеты и OpenJDK 17 (headless)..."
sudo apt-get update -y
# ВАЖНО: на headless-сервере ставим именно headless-JDK.
# Полный openjdk-17-jdk тянет AWT/Swing -> libgl1 -> X11, который на сервере
# без графики не разрешается. Для сборки Flutter/Android графика не нужна.
# Android udev-правила перенесены в шаг 04 (это часть настройки USB).
sudo apt-get install -y \
  git curl wget unzip xz-utils gpg ca-certificates \
  openjdk-17-jdk-headless
c_ok "Пакеты установлены."

# Перечитываем JDK 17 (теперь он точно есть) и фиксируем JAVA_HOME
JAVA_HOME_17="$(ls -d /usr/lib/jvm/java-17-openjdk-* 2>/dev/null | head -n1 || true)"
if [[ -z "${JAVA_HOME_17}" ]]; then
  c_err "OpenJDK 17 не найден в /usr/lib/jvm. Проверь установку openjdk-17-jdk-headless."
  exit 1
fi

bashrc_set_block "flutter-java" "export JAVA_HOME=\"${JAVA_HOME_17}\"
export PATH=\"\$JAVA_HOME/bin:\$PATH\""

c_ok "JAVA_HOME = ${JAVA_HOME_17} (прописан в ~/.bashrc)"
c_ok "Шаг 1 готов. Дальше: ./02-flutter.sh"
