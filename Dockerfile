# Dockerizing base image for eXo Platform with:
#
# - Libre Office
# - eXo Platform Community

# Build:    docker build -t exoplatform/exo-community .
#
# Run:      docker run -p 8080:8080 exoplatform/exo-community
#           docker run -d -p 8080:8080 exoplatform/exo-community
#           docker run -d --rm -p 8080:8080 -v exo_data:/srv/exo exoplatform/exo-community
#           docker run -d -p 8080:8080 -v $(pwd)/setenv-customize.sh:/opt/exo/bin/setenv-customize.sh:ro exoplatform/exo-community

FROM  exoplatform/jdk:openjdk-21-ubuntu-2604

LABEL org.opencontainers.image.authors="eXo Platform <docker@exoplatform.com>" \
      org.opencontainers.image.title="eXo Platform Community" \
      org.opencontainers.image.description="Docker image for eXo Platform Community Edition" \
      org.opencontainers.image.vendor="eXo Platform" \
      org.opencontainers.image.source="https://github.com/exo-docker/exo-community"

ARG YQ_VERSION=v4.53.4

# Build Arguments and environment variables
ARG EXO_VERSION=7.1.0

# this allow to specify an eXo Platform download url
ARG DOWNLOAD_URL
# this allow to specifiy a user to download a protected binary
ARG DOWNLOAD_USER

# Default base directory on the plf archive
ARG ARCHIVE_BASE_DIR=platform-community-${EXO_VERSION}

ENV EXO_APP_DIR=/opt/exo \
    EXO_CONF_DIR=/etc/exo \
    EXO_CODEC_DIR=/etc/exo/codec \
    EXO_DATA_DIR=/srv/exo \
    EXO_SHARED_DATA_DIR=/srv/exo/shared \
    EXO_LOG_DIR=/var/log/exo \
    EXO_TMP_DIR=/tmp/exo-tmp \
    EXO_USER=exo \
    EXO_GROUP=exo \
    DEBIAN_FRONTEND=noninteractive

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN useradd --create-home -u 999 --user-group --shell /bin/bash --no-log-init ${EXO_USER}

# Install the needed packages
RUN apt-get -qq update && \
  apt-get -qq -y upgrade ${_APT_OPTIONS} && \
  apt-get -qq -y install --no-install-recommends ${_APT_OPTIONS} debconf-utils && \
  echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections && \
  echo "ttf-mscorefonts-installer msttcorefonts/present-mscorefonts-eula note" | debconf-set-selections && \
  apt-get -qq -y install ${_APT_OPTIONS} \
    xmlstarlet \
    jq \
    curl \
    unzip \
    ca-certificates \
    fontconfig \
    ttf-mscorefonts-installer \
    libreoffice-calc \
    libreoffice-draw \
    libreoffice-impress \
    libreoffice-math \
    libreoffice-writer && \
  apt-get -qq -y autoremove && \
  apt-get -qq -y clean && \
  rm -rf /var/lib/apt/lists/*

# Download yq with architecture detection and checksum verification
RUN YQ_ARCH=$(dpkg --print-architecture) && \
    if [ "$YQ_ARCH" = "amd64" ]; then \
        YQ_SHA256="f67d8a6a2dc2308c961f83d5ba8707fd4c7c44ad77902fef87eb3a4646cdfa2a"; \
    elif [ "$YQ_ARCH" = "arm64" ]; then \
        YQ_SHA256="8c3cf4cff01536588947b6e0ba1544768039e34054cd9ca8a9e4c5706dfb8631"; \
    else \
        echo "Unsupported architecture: $YQ_ARCH"; exit 1; \
    fi && \
    curl -fsSL -o /usr/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${YQ_ARCH}" && \
    echo "${YQ_SHA256} /usr/bin/yq" | sha256sum -c - \
    || { \
    echo "ERROR: the [/usr/bin/yq] binary downloaded from a github release was modified while it should not !!"; \
    exit 1; \
    } && \
    chmod a+x /usr/bin/yq

# Drop pebble as we use tini
RUN rm -f /usr/bin/pebble \
    && rm -rf /var/lib/pebble \
    && rm -rf /etc/pebble

# Create needed directories
RUN mkdir -p ${EXO_DATA_DIR}          && chown ${EXO_USER}:${EXO_GROUP} ${EXO_DATA_DIR} \
    && mkdir -p ${EXO_SHARED_DATA_DIR} && chown ${EXO_USER}:${EXO_GROUP} ${EXO_SHARED_DATA_DIR} \
    && mkdir -p ${EXO_TMP_DIR}        && chown ${EXO_USER}:${EXO_GROUP} ${EXO_TMP_DIR} \
    && mkdir -p ${EXO_LOG_DIR}        && chown ${EXO_USER}:${EXO_GROUP} ${EXO_LOG_DIR}

# Install eXo Platform
RUN set -e; \
  if [ -n "${DOWNLOAD_USER}" ]; then PARAMS="-u ${DOWNLOAD_USER}"; fi && \
  if [ ! -n "${DOWNLOAD_URL}" ]; then \
  echo "Building an image with eXo Platform version : ${EXO_VERSION}"; \
  EXO_VERSION_SHORT=$(echo ${EXO_VERSION} | awk -F "\." '{ print $1"."$2}'); \
  DOWNLOAD_URL="https://downloads.exoplatform.org/public/releases/platform/${EXO_VERSION_SHORT}/${EXO_VERSION}/platform-community-tomcat-${EXO_VERSION}.zip"; \
  fi && \
  curl ${PARAMS} -sS -L -o /srv/downloads/eXo-Platform-${EXO_VERSION}.zip ${DOWNLOAD_URL} && \
  unzip -q /srv/downloads/eXo-Platform-${EXO_VERSION}.zip -d /srv/downloads/ && \
  rm -f /srv/downloads/eXo-Platform-${EXO_VERSION}.zip && \
  mv /srv/downloads/${ARCHIVE_BASE_DIR} ${EXO_APP_DIR} && \
  chown -R ${EXO_USER}:${EXO_GROUP} ${EXO_APP_DIR} && \
  ln -s ${EXO_APP_DIR}/gatein/conf /etc/exo && \
  mkdir -p ${EXO_CODEC_DIR} && chown ${EXO_USER}:${EXO_GROUP} ${EXO_CODEC_DIR} && \
  rm -rf ${EXO_APP_DIR}/logs && ln -s ${EXO_LOG_DIR} ${EXO_APP_DIR}/logs

# Install Docker customization file
COPY --chown=${EXO_USER}:${EXO_GROUP} scripts/setenv-docker-customize.sh ${EXO_APP_DIR}/bin/setenv-docker-customize.sh
RUN chmod 755 ${EXO_APP_DIR}/bin/setenv-docker-customize.sh && \
  sed -i '/# Load custom settings/i \
  \# Load custom settings for docker environment\n\
  [ -r "$CATALINA_BASE/bin/setenv-docker-customize.sh" ] \
  && . "$CATALINA_BASE/bin/setenv-docker-customize.sh" \
  || echo "No Docker eXo Platform customization file : $CATALINA_BASE/bin/setenv-docker-customize.sh"\n\
  ' ${EXO_APP_DIR}/bin/setenv.sh && \
  grep 'setenv-docker-customize.sh' ${EXO_APP_DIR}/bin/setenv.sh

USER ${EXO_USER}

WORKDIR ${EXO_LOG_DIR}
ENTRYPOINT ["/usr/local/bin/tini", "--"]
# Health Check
HEALTHCHECK CMD curl --fail http://localhost:8080/ || exit 1
CMD [ "/opt/exo/start_eXo.sh" ]
