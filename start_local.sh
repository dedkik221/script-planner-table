#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
PORT="${1:-4173}"
LOG_FILE="${ROOT_DIR}/.local-server.log"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 не найден. Установите Python 3 и повторите."
  exit 1
fi

if lsof -nP -iTCP:"${PORT}" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Сервер уже запущен на http://127.0.0.1:${PORT}"
else
  (
    cd "${ROOT_DIR}"
    nohup python3 -m http.server "${PORT}" --bind 127.0.0.1 >"${LOG_FILE}" 2>&1 &
  )

  # Ждём, пока сервер поднимется
  for _ in {1..20}; do
    if lsof -nP -iTCP:"${PORT}" -sTCP:LISTEN >/dev/null 2>&1; then
      break
    fi
    sleep 0.1
  done

  if ! lsof -nP -iTCP:"${PORT}" -sTCP:LISTEN >/dev/null 2>&1; then
    echo "Не удалось запустить сервер. Лог: ${LOG_FILE}"
    exit 1
  fi

  echo "Сервер запущен на http://127.0.0.1:${PORT}"
fi

URL="http://127.0.0.1:${PORT}/index.html"
echo "Открываю ${URL}"
open "${URL}" >/dev/null 2>&1 || true
