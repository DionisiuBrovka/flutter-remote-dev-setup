#!/usr/bin/env bash
# 06-github.sh — установка GitHub CLI (gh), настройка git и авторизация (токен).
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
ensure_not_root

# ── Установка gh из официального репозитория GitHub ──
if command -v gh >/dev/null 2>&1; then
  c_warn "gh уже установлен ($(gh --version | head -n1)) — пропускаю установку."
else
  c_info "Добавляю официальный репозиторий GitHub CLI и ставлю gh..."
  sudo mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update -y
  sudo apt-get install -y gh
  c_ok "Установлен $(gh --version | head -n1)"
fi

# ── Настройка имени и почты в git ──
if [[ "${GIT_USER_NAME}" == "Your Name" || "${GIT_USER_EMAIL}" == "you@example.com" ]]; then
  c_warn "В 00-env.sh не заполнены GIT_USER_NAME / GIT_USER_EMAIL — пропускаю git config."
  c_warn "Впиши свои данные и запусти шаг ещё раз, либо задай вручную:"
  c_warn "    git config --global user.name  \"Имя\""
  c_warn "    git config --global user.email \"почта\""
else
  git config --global user.name  "${GIT_USER_NAME}"
  git config --global user.email "${GIT_USER_EMAIL}"
  c_ok "git настроен: ${GIT_USER_NAME} <${GIT_USER_EMAIL}>"
fi

# ── Авторизация / генерация токена ──
if gh auth status >/dev/null 2>&1; then
  c_ok "gh уже авторизован."
else
  echo
  c_info "Запускаю авторизацию GitHub. На headless-сервере выбирай так:"
  echo "    GitHub.com  ->  HTTPS  ->  Authenticate with a web browser"
  echo "gh покажет одноразовый код. Открой ссылку (github.com/login/device)"
  echo "на НОУТЕ, введи код — gh сам сгенерирует и сохранит токен (gho_...)."
  echo
  c_warn "Если хочешь свой Personal Access Token вместо браузера:"
  echo "    github.com -> Settings -> Developer settings -> Personal access tokens"
  echo "    -> создай fine-grained токен -> затем:"
  echo "    echo 'ВСТАВЬ_ТОКЕН' | gh auth login --with-token"
  echo
  gh auth login
fi

# Делаем так, чтобы git push/pull по HTTPS использовали токен gh
gh auth setup-git
c_ok "git будет ходить на GitHub под токеном gh (для https-репозиториев)."

c_ok "Шаг 6 готов. Дальше: ./07-claude-code.sh"
