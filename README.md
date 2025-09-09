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

 

## Persistance de la connexion et montage de l'agent (Dev Container)

Pour conserver vos réglages Codex et un éventuel fichier d'« agent » entre l'hôte (macOS) et le conteneur (Linux), ajoutez ou mettez à jour les champs suivants dans votre `.devcontainer/devcontainer.json`.

```jsonc
{
  // Crée le fichier local si absent (sur l'hôte)
  "initializeCommand": "touch ${localEnv:HOME}/.codex-devcontainer.json",

  // Monte les réglages/état hôte ↔ conteneur
  "mounts": [
    // Souvenirs & réglages globaux (partagés macOS ↔ conteneur)
    // ⚠️ Remplacez /vscode/ par /node/ (ou l'utilisateur effectif du conteneur)
    "source=${localEnv:HOME}/.codex,target=/home/vscode/.codex,type=bind,consistency=cached",
    // Fichier d'agent / préférences spécifiques au devcontainer
    "source=${localEnv:HOME}/.codex-devcontainer.json,target=/home/vscode/.codex.json,type=bind,consistency=cached"
  ]
}
```

Notes:
- Si votre image utilise l'utilisateur `node` (ex. images Node officielles), remplacez `/home/vscode/` par `/home/node/` dans les chemins de montage.
- Le répertoire `~/.codex` et le fichier `~/.codex.json` dans le conteneur seront alors synchronisés avec vos équivalents locaux, ce qui facilite la persistance de connexion et de préférences.

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
codex "$(cat <<'EOF'
But: activer codex-cli sans dénaturer le Dev Container. Éditer uniquement .devcontainer/devcontainer.json via un merge non destructif et idempotent.

Périmètre
- Autorisé: features, initializeCommand, mounts.
- Interdit: toute autre clé ou fichier.

Détermination utilisateur
- userInContainer = remoteUser || containerUser || "vscode".
- HOME_IN_CONTAINER = "/home/" + userInContainer.

1) features
- S’assurer que "features" est un objet.
- Ajouter: "ghcr.io/nicolas-nwb/codex-devcontainer/codex-cli:1": {} si absent.
- Ne rien retirer.

2) mounts
- S’assurer que "mounts" est un tableau.
- Candidats à ajouter UNIQUEMENT s’ils n’existent pas à l’identique:
  - 'source=${localEnv:HOME}/.codex,target=HOME_IN_CONTAINER/.codex,type=bind,consistency=cached'
- Si userInContainer != "vscode", n’ajuster que les CIBLES ajoutées. Ne pas réécrire les entrées préexistantes.

Sortie
- Écrire le JSON final sans reformater le reste.
- Afficher un récapitulatif concis des ajouts/append effectués.
EOF
)"
```