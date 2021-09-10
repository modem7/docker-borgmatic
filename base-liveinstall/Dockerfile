FROM modem7/borgmatic-docker
COPY entry.sh /entry.sh
COPY wtfc.sh /wtfc.sh
RUN rm -rf /var/cache/apk/* \
           /.cache \
           && chmod 755 /entry.sh /wtfc.sh
CMD ["/entry.sh"]