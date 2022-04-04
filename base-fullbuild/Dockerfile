FROM alpine:3.15.3 as builder
LABEL mainainer='modem7'
COPY requirements.txt /requirements.txt
RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
    alpine-sdk \
    python3-dev \
    py3-pip \
	py3-pkgconfig \
    openssl-dev \
    lz4-dev \
    acl-dev \
    linux-headers \
    fuse-dev \
    attr-dev \
    py3-wheel \
    && pip3 install --no-cache-dir -U -r requirements.txt

FROM alpine:3.15.3
LABEL mainainer='modem7'
ARG PYTHON_VERSION=3.9
VOLUME /mnt/source
VOLUME /mnt/borg-repository
VOLUME /etc/borgmatic.d
VOLUME /root/.config/borg
VOLUME /root/.ssh
VOLUME /root/.cache/borg
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 CMD borgmatic --version || exit 1
COPY entry.sh /entry.sh
RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
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
    && rm -rf /var/cache/apk/* \
              /.cache \
    && chmod 755 /entry.sh
COPY --from=builder /usr/lib/python${PYTHON_VERSION}/site-packages /usr/lib/python${PYTHON_VERSION}/
COPY --from=builder /usr/bin/borg /usr/bin/
COPY --from=builder /usr/bin/borgfs /usr/bin/
COPY --from=builder /usr/bin/borgmatic /usr/bin/
COPY --from=builder /usr/bin/generate-borgmatic-config /usr/bin/
COPY --from=builder /usr/bin/upgrade-borgmatic-config /usr/bin/
COPY --from=builder /usr/bin/validate-borgmatic-config /usr/bin/
CMD ["/entry.sh"]
