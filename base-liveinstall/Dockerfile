# syntax = docker/dockerfile:latest

FROM modem7/borgmatic-docker:latest

COPY --chmod=755 --link entry.sh /
COPY --chmod=755 --link wtfc.sh /

CMD ["/entry.sh"]