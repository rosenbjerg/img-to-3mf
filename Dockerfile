FROM bitnami/minideb:latest

RUN install_packages imagemagick potrace openscad

COPY ["convert.sh", "/"]

ENTRYPOINT ["/convert.sh"]