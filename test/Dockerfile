FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git bash xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Copie de la Feature locale et exécution de l'installateur (nouvelle feature codex-cli)
COPY src/codex-cli /tmp/feature
RUN bash /tmp/feature/install.sh \
    && rm -rf /tmp/feature

# Vérification rapide
RUN bash -lc "command -v codex >/dev/null 2>&1 || (echo 'codex introuvable' && exit 1)"

CMD ["bash"]


