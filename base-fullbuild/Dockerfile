FROM alpine:3.16 as builder
LABEL mainainer='modem7'
COPY requirements.txt /requirements.txt
RUN apk add --update --no-cache \
    alpine-sdk \
    python3-dev \
    py3-pip \
	py3-pkgconfig \
    openssl-dev \
    logrotate \
    lz4-dev \
    acl-dev \
    linux-headers \
    fuse-dev \
    attr-dev \
    py3-wheel \
    && pip3 install --no-cache-dir -U -r requirements.txt

FROM alpine:3.16
LABEL mainainer='modem7'
ARG PYTHON_VERSION=3.10
VOLUME /mnt/source
VOLUME /mnt/borg-repository
VOLUME /root/.borgmatic
VOLUME /etc/borgmatic.d
VOLUME /root/.config/borg
VOLUME /root/.ssh
VOLUME /root/.cache/borg
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 CMD borgmatic --version || exit 1
COPY --chmod=755 entry.sh /entry.sh
RUN apk add --update --no-cache \
    tzdata \
    sshfs \
    python3 \
    openssl \
    fuse \
    ca-certificates \
    lz4-libs \
    libacl \
    postgresql-client \
    mariadb-client \
    mongodb-tools \
    curl \
    findmnt \
    bash \
    bash-completion \
    bash-doc \
    && rm -rf \
    /var/cache/apk/* \
    /.cache
COPY --from=builder /usr/lib/python${PYTHON_VERSION}/site-packages /usr/lib/python${PYTHON_VERSION}/
COPY --from=builder /usr/bin/borg /usr/bin/
COPY --from=builder /usr/bin/borgfs /usr/bin/
COPY --from=builder /usr/bin/borgmatic /usr/bin/
COPY --from=builder /usr/bin/generate-borgmatic-config /usr/bin/
COPY --from=builder /usr/bin/upgrade-borgmatic-config /usr/bin/
COPY --from=builder /usr/bin/validate-borgmatic-config /usr/bin/
RUN borgmatic --bash-completion > /usr/share/bash-completion/completions/borgmatic && echo "source /etc/profile.d/bash_completion.sh" > /root/.bashrc
CMD ["/entry.sh"]
