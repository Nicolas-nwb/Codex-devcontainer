# Codex Devcontainer

Ce dépôt contient une Feature Dev Container « codex-cli » et ses tests automatisés.

## Utilisation (Feature Dev Container)

Pour utiliser la feature dans un `devcontainer.json`:

```json
"features": {
  "./src/codex-cli": {}
}
```

Depuis GHCR (publique) après publication:

```json
"features": {
  "ghcr.io/nicolas-nwb/features/codex-cli:1": {}
}
```

Optionnel: exportez vos variables d'environnement côté hôte avant d'ouvrir le conteneur:

```bash
export OPENAI_API_KEY="..."
export OPENAI_ORG_ID="..."
export OPENAI_ENGINE_ID="..."
```

## Installation rapide (copier-coller)

Collez ce script à la racine de votre projet pour ajouter la Feature et reconstruire le Dev Container.

```bash
#!/usr/bin/env bash
set -euo pipefail

# Ajoute la Feature Codex CLI et reconstruit le Dev Container
FEATURE="ghcr.io/nicolas-nwb/features/codex-cli:1"
mkdir -p .devcontainer

# Créer ou mettre à jour .devcontainer/devcontainer.json
if [ ! -f .devcontainer/devcontainer.json ]; then
  cat > .devcontainer/devcontainer.json <<EOF
{
  "features": {
    "$FEATURE": {}
  }
}
EOF
else
  if command -v jq >/dev/null 2>&1; then
    tmp="$(mktemp)"
    jq --arg f "$FEATURE" '.features = (.features // {}) | .features[$f] = {}' \
      .devcontainer/devcontainer.json > "$tmp"
    mv "$tmp" .devcontainer/devcontainer.json
  else
    echo "Installez 'jq' ou ajoutez manuellement la Feature: $FEATURE" >&2
  fi
fi

# Reconstruire le Dev Container (CLI installé ou via npx)
if command -v devcontainer >/dev/null 2>&1; then
  devcontainer up --workspace-folder .
else
  npx --yes @devcontainers/cli up --workspace-folder .
fi
```

Astuce: sous VS Code, vous pouvez aussi utiliser « Dev Containers: Rebuild Container Without Cache ».

## Tests (Docker)

Construire l'image de test et vérifier que `codex` est présent:

```bash
bash scripts/build_and_test.sh
```

## Structure

- `src/codex-cli/`: Feature locale pour Codex CLI
- `test/codex-cli/`: tests de la feature (scénarios + scripts)
- `test/Dockerfile`: exécute l'install de la feature et vérifie la présence de `codex`
- `scripts/build_and_test.sh`: build + run de l'image de test

## Crédits

Ce projet est largement inspiré de Claude Code, un projet sous licence MIT par Anthropic PBC.