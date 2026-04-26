#!/usr/bin/env bash
# Ensures .env exists before `flutter run`, `flutter test`, or `flutter build`
# so the dotenv asset bundler has a file to include. Safe to call multiple
# times; only creates .env from the committed template when missing.

set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  cp .env.example .env
  echo "scripts/prepare_env.sh: created .env from .env.example (empty placeholders)."
  echo "scripts/prepare_env.sh: edit .env locally to add real API keys, or pass them via --dart-define."
fi
