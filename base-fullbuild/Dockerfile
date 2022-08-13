# syntax = docker/dockerfile:latest

FROM python:3.10.6-alpine3.16
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
    apk add -U --no-cache \
        tzdata \
        sshfs \
        openssl \
        fuse \
        ca-certificates \
        logrotate \
        lz4-libs \
        libacl \
        postgresql-client \
        mariadb-client \
        mongodb-tools \
        curl \
        findmnt \
        bash \
        bash-completion \
        bash-doc
EOF

COPY --chmod=755 --link entry.sh /
COPY --link requirements.txt /
RUN python3 -m pip install --no-cache -Ur requirements.txt
RUN <<EOF
    set -x
    borgmatic --bash-completion > /usr/share/bash-completion/completions/borgmatic
    echo "source /etc/profile.d/bash_completion.sh" > /root/.bashrc
EOF

CMD ["/entry.sh"]
