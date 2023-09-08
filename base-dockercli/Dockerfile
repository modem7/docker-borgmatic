# syntax = docker/dockerfile:latest

FROM modem7/borgmatic-docker:latest

COPY --link root/ /

RUN apk add --update --no-cache \
    docker-cli

ENTRYPOINT [ "/init" ]
