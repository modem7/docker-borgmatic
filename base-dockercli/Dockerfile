FROM modem7/borgmatic-docker:1.5.18
COPY entry.sh /entry.sh
RUN apk update \
    && apk add --no-cache \
    docker-cli \
    && rm -rf /var/cache/apk/* \
              /.cache \
              && chmod 755 /entry.sh
CMD ["/entry.sh"]
