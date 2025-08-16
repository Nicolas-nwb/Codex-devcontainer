#!/bin/sh
set -eu

# Installer Node.js si nécessaire (logique basée sur le script existant)
detect_package_manager() {
    for pm in apt-get apk dnf yum; do
        if command -v $pm >/dev/null; then
            case $pm in
                apt-get) echo "apt" ;;
                *) echo "$pm" ;;
            esac
            return 0
        fi
    done
    echo "unknown"
    return 1
}

install_packages() {
    pkg_manager="$1"; shift
    case "$pkg_manager" in
        apt)
            apt-get update
            apt-get install -y "$@"
            ;;
        apk)
            apk add --no-cache "$@"
            ;;
        dnf|yum)
            $pkg_manager install -y "$@"
            ;;
        *)
            echo "WARNING: Unsupported package manager. Cannot install packages: $*"
            return 1
            ;;
    esac
}

install_nodejs() {
    pkg_manager="$1"
    case "$pkg_manager" in
        apt)
            install_packages apt ca-certificates curl gnupg
            mkdir -p /etc/apt/keyrings
            curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
            echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" > /etc/apt/sources.list.d/nodesource.list
            apt-get update && apt-get install -y nodejs
            ;;
        apk)
            install_packages apk nodejs npm
            ;;
        dnf)
            install_packages dnf nodejs npm
            ;;
        yum)
            curl -sL https://rpm.nodesource.com/setup_18.x | bash - && yum install -y nodejs
            ;;
        *)
            echo "ERROR: Unsupported package manager for Node.js installation"
            return 1
            ;;
    esac
    command -v node >/dev/null && command -v npm >/dev/null
}

install_codex_cli() {
    echo "Installing Codex CLI..."
    # Hypothèse: package NPM codex CLI disponible globalement
    npm install -g @openai/codex
    if command -v codex >/dev/null; then
        echo "Codex CLI installed successfully!"
        codex --version || true
        return 0
    fi
    echo "ERROR: Codex CLI installation failed!" >&2
    return 1
}

install_shell_completion_prereqs() {
    pkg_manager="$1"
    case "$pkg_manager" in
        apt)
            install_packages apt bash-completion
            # Activer bash-completion via profile global si disponible
            if [ -f "/usr/share/bash-completion/bash_completion" ]; then
                cat >/etc/profile.d/10-bash-completion.sh <<'EOF'
# Activé globalement pour Bash
if [ -n "$BASH_VERSION" ] && [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi
EOF
                chmod 644 /etc/profile.d/10-bash-completion.sh || true
            fi
            ;;
        apk)
            install_packages apk bash-completion
            ;;
        dnf|yum)
            install_packages "$pkg_manager" bash-completion
            ;;
        *) ;;
    esac

    # Préparer dossiers Zsh site-functions si présent
    mkdir -p /usr/share/zsh/site-functions || true
}

generate_shell_completions() {
    # Génère les auto-complétions si le CLI les expose
    set +e
    # Bash
    if command -v codex >/dev/null 2>&1; then
        if codex autocomplete bash >/dev/null 2>&1; then
            codex autocomplete bash > /etc/bash_completion.d/codex 2>/dev/null
        elif codex completion --shell bash >/dev/null 2>&1; then
            codex completion --shell bash > /etc/bash_completion.d/codex 2>/dev/null
        elif codex completion >/dev/null 2>&1; then
            codex completion > /etc/bash_completion.d/codex 2>/dev/null
        fi
        if [ -s "/etc/bash_completion.d/codex" ]; then
            chmod 644 /etc/bash_completion.d/codex || true
            echo "Installed Bash completion for codex"
        else
            echo "NOTE: Unable to auto-generate Bash completion for codex (command not supported)." >&2
        fi

        # Zsh
        if codex autocomplete zsh >/dev/null 2>&1; then
            codex autocomplete zsh > /usr/share/zsh/site-functions/_codex 2>/dev/null
        elif codex completion --shell zsh >/dev/null 2>&1; then
            codex completion --shell zsh > /usr/share/zsh/site-functions/_codex 2>/dev/null
        fi
        if [ -s "/usr/share/zsh/site-functions/_codex" ]; then
            chmod 644 /usr/share/zsh/site-functions/_codex || true
            echo "Installed Zsh completion for codex"
        else
            echo "NOTE: Unable to auto-generate Zsh completion for codex (command not supported)." >&2
        fi
    fi
    set -e
}

main() {
    echo "Activating feature 'codex-cli'"
    PKG_MANAGER=$(detect_package_manager)
    if ! command -v node >/dev/null || ! command -v npm >/dev/null; then
        install_nodejs "$PKG_MANAGER" || exit 1
    fi
    install_codex_cli || exit 1
    install_shell_completion_prereqs "$PKG_MANAGER" || true
    generate_shell_completions || true
}

main "$@"



