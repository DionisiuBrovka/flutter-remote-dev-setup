#!/usr/bin/env bash
# 07-claude-code.sh — установка Claude Code (нативный установщик, без Node.js).
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
ensure_not_root

if command -v claude >/dev/null 2>&1; then
  c_warn "Claude Code уже установлен ($(claude --version 2>/dev/null || echo '?')) — пропускаю установку."
else
  c_info "Ставлю Claude Code нативным установщиком..."
  # Нативный бинарь ставится в ~/.local/bin/claude, Node.js не нужен.
  curl -fsSL https://claude.ai/install.sh | bash
  c_ok "Claude Code установлен."
fi

# Гарантируем, что ~/.local/bin в PATH
bashrc_set_block "local-bin" "export PATH=\"\$HOME/.local/bin:\$PATH\""
export PATH="${HOME}/.local/bin:${PATH}"

c_info "Проверка:"
claude --version || c_warn "claude не найден в PATH — открой новый терминал или: source ~/.bashrc"

echo
c_warn "Claude Code требует аккаунт Pro / Max / Team / Enterprise или Console (API)."
echo "Первый запуск в папке проекта проведёт через вход:"
echo "    cd ~/путь/к/проекту"
echo "    claude            # дальше следуй инструкциям авторизации"
echo "    claude doctor     # диагностика, если что-то не так"
echo
c_ok "Шаг 7 готов. Дальше: ./08-finish.sh"
