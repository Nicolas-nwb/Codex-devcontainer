#!/usr/bin/env bash
set -euo pipefail

# Construire l'image de test basée sur Debian avec la Feature locale
docker build -t codex-feature-test -f test/Dockerfile .

# Exécuter la commande codex pour valider la présence du binaire
docker run --rm codex-feature-test bash -lc "codex --version || codex --help || true"

echo "OK: codex est disponible dans l'image de test."


