# syntax = docker/dockerfile:latest

FROM python:3.11.1-alpine3.17
LABEL mainainer='modem7'
VOLUME /mnt/source
VOLUME /mnt/borg-repository
VOLUME /root/.borgmatic
VOLUME /etc/borgmatic.d
VOLUME /root/.config/borg
VOLUME /root/.ssh
VOLUME /root/.cache/borg
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 CMD borgmatic --version || exit 1
RUN <<EOF
    set -x
    apk add --no-cache -U \
        tzdata \
        sshfs \
        openssl \
        fuse \
        ca-certificates \
        logrotate \
        lz4-libs \
        libacl \
        libssl1.1 \
        postgresql-client \
        mariadb-client \
        mongodb-tools \
        curl \
        findmnt \
        bash \
        bash-completion \
        bash-doc
EOF

COPY --link requirements.txt /
COPY --chmod=755 --link entry.sh /

RUN --mount=type=cache,id=pip,target=/root/.cache,sharing=locked python3 -m pip install -Ur requirements.txt
RUN <<EOF
    set -x
    borgmatic --bash-completion > /usr/share/bash-completion/completions/borgmatic
    echo "source /etc/profile.d/bash_completion.sh" > /root/.bashrc
EOF

CMD ["/entry.sh"]
