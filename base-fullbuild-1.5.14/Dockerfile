FROM alpine:3.14.2 as builder
COPY requirements.txt /requirements.txt
RUN apk update --no-cache \
    && apk upgrade --no-cache \
    && apk add --no-cache \
    alpine-sdk \
    python3-dev \
    py3-pip \
    openssl-dev \
    lz4-dev \
    acl-dev \
    linux-headers \
    fuse-dev \
    attr-dev \
    py3-wheel \
    && pip3 install -U -r requirements.txt

FROM alpine:3.14.2
LABEL mainainer='modem7'
ARG PYTHON_VERSION=3.8
COPY entry.sh /entry.sh
RUN apk update --no-cache \
    && apk upgrade --no-cache \
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
    curl \
    && rm -rf /var/cache/apk/* \
    && chmod 755 /entry.sh
VOLUME /mnt/source
VOLUME /mnt/borg-repository
VOLUME /etc/borgmatic.d
VOLUME /root/.config/borg
VOLUME /root/.ssh
VOLUME /root/.cache/borg
COPY --from=builder /usr/lib/python${PYTHON_VERSION}/site-packages /usr/lib/python${PYTHON_VERSION}/
COPY --from=builder /usr/bin/borg /usr/bin/
COPY --from=builder /usr/bin/borgfs /usr/bin/
COPY --from=builder /usr/bin/borgmatic /usr/bin/
COPY --from=builder /usr/bin/generate-borgmatic-config /usr/bin/
COPY --from=builder /usr/bin/upgrade-borgmatic-config /usr/bin/
COPY --from=builder /usr/bin/validate-borgmatic-config /usr/bin/
CMD ["/entry.sh"]
