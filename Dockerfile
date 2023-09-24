# syntax =  docker/dockerfile:experimental
ARG ALPINE_VERSION

FROM --platform=${TARGETPLATFORM} alpine:${ALPINE_VERSION}
LABEL maintainer="Jorn Eilander <jorn.eilander@azorion.com>"
LABEL Description="Sonarr"

# Define version of Sonarr
ARG SONARR_VERSION
ARG UID=8989
ARG GID=8989

# Install required base packages and remove any cache
RUN apk add --no-cache \
      tini \
      bash \
      ca-certificates && \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
      mono \
      gosu \
      curl && \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
      mediainfo \
      tinyxml2 && \
    rm -rf /var/tmp/* /var/cache/apk/* && \
    cert-sync /etc/ssl/certs/ca-certificates.crt && \
    # Create the 'sonarr' user and group; ensure it owns all relevant directories
    addgroup -g ${GID} sonarr && \
    adduser -D -G sonarr -s /bin/sh -u ${UID} sonarr && \
    mkdir /config; chown -R ${UID}:${GID} /config && \
    mkdir /media/downloads; chown -R ${UID}:${GID} /media/downloads && \
    mkdir /media/series; chown -R ${UID}:${GID} /media/series && \
    mkdir -p /tmp/.mono; chown -R ${UID}:${GID} /tmp/.mono

ADD --chown=${UID}:${GID} Sonarr.phantom-develop.${SONARR_VERSION}.linux.tar.gz /opt

# Publish volumes, ports etc
ENV XDG_CONFIG_HOME=/tmp
ENV XDG_CONFIG_DIR=/tmp
VOLUME ["/config", "/media/downloads", "/media/series"]
EXPOSE 8989
USER ${UID}
WORKDIR /config

# Define default start command
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["mono", "/opt/Sonarr/Sonarr.exe", "-data /config", "", "-l", "-nobrowser"]


