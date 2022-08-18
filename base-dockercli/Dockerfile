# syntax = docker/dockerfile:latest

FROM modem7/borgmatic-docker:latest

COPY --chmod=755 --link entry.sh /
RUN apk add --update --no-cache \
    docker-cli

CMD ["/entry.sh"]
