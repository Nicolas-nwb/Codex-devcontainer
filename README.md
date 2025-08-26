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
  "ghcr.io/nicolas-nwb/codex-devcontainer/codex-cli:latest": {}
}
```

Optionnel: exportez vos variables d'environnement côté hôte avant d'ouvrir le conteneur:

```bash
export OPENAI_API_KEY="..."
export OPENAI_ORG_ID="..."
export OPENAI_ENGINE_ID="..."
```

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

## Installation via Codex (commande à copier-coller)

Collez cette commande dans votre terminal. Elle envoie un prompt au CLI Codex pour générer un script d’installation, puis l’exécute.

```bash
codex --prompt "$(cat <<'EOF'
Ajoute la feature codex-cli à mon Dev Container. Crée ou modifie .devcontainer/devcontainer.json pour inclure:
\"features\": {
  \"ghcr.io/nicolas-nwb/codex-devcontainer/codex-cli:1\": {}
}
EOF
)"
```