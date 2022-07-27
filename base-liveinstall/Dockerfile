# syntax = docker/dockerfile:latest

FROM modem7/borgmatic-docker:latest
COPY --chmod=755 entry.sh /entry.sh
COPY --chmod=755 wtfc.sh /wtfc.sh
CMD ["/entry.sh"]