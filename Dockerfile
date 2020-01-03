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

FROM    exoplatform/jdk:8-ubuntu-1804
LABEL   maintainer="eXo Platform <docker@exoplatform.com>"

# Install the needed packages
RUN apt-get -qq update \
    && apt-get -qq -y upgrade ${_APT_OPTIONS} \
    && apt-get -qq -y install ${_APT_OPTIONS} xmlstarlet \
    && apt-get -qq -y install ${_APT_OPTIONS} libreoffice-calc libreoffice-draw libreoffice-impress libreoffice-math libreoffice-writer \
    && apt-get -qq -y autoremove \
    && apt-get -qq -y clean \
    && rm -rf /var/lib/apt/lists/*

# Build Arguments and environment variables
ARG EXO_VERSION=6.0.0-M13
ARG CHAT_VERSION=3.0.0-M13

# this allow to specify an eXo Platform download url
ARG DOWNLOAD_URL
# this allow to specifiy a user to download a protected binary
ARG DOWNLOAD_USER
# allow to override the list of addons to package by default
ARG ADDONS="exo-jdbc-driver-mysql:1.4.1"
# Default base directory on the plf archive
ARG ARCHIVE_BASE_DIR=platform-community-${EXO_VERSION}

ENV EXO_APP_DIR   /opt/exo
ENV EXO_CONF_DIR  /etc/exo
ENV EXO_DATA_DIR  /srv/exo
ENV EXO_LOG_DIR   /var/log/exo
ENV EXO_TMP_DIR   /tmp/exo-tmp

ENV EXO_USER exo
ENV EXO_GROUP ${EXO_USER}

ENV CHAT_VERSION=$CHAT_VERSION
# Customise system

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
# giving all rights to eXo user
RUN useradd --create-home --user-group --shell /bin/bash ${EXO_USER}

# Create needed directories
RUN mkdir -p ${EXO_DATA_DIR}   && chown ${EXO_USER}:${EXO_GROUP} ${EXO_DATA_DIR} \
    && mkdir -p ${EXO_TMP_DIR} && chown ${EXO_USER}:${EXO_GROUP} ${EXO_TMP_DIR} \
    && mkdir -p ${EXO_LOG_DIR} && chown ${EXO_USER}:${EXO_GROUP} ${EXO_LOG_DIR}

# Install eXo Platform
RUN if [ -n "${DOWNLOAD_USER}" ]; then PARAMS="-u ${DOWNLOAD_USER}"; fi && \
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
  rm -rf ${EXO_APP_DIR}/logs && ln -s ${EXO_LOG_DIR} ${EXO_APP_DIR}/logs

# Install Docker customization file
ADD scripts/setenv-docker-customize.sh ${EXO_APP_DIR}/bin/setenv-docker-customize.sh
RUN chmod 755 ${EXO_APP_DIR}/bin/setenv-docker-customize.sh && \
  chown ${EXO_USER}:${EXO_GROUP} ${EXO_APP_DIR}/bin/setenv-docker-customize.sh && \
  sed -i '/# Load custom settings/i \
  \# Load custom settings for docker environment\n\
  [ -r "$CATALINA_BASE/bin/setenv-docker-customize.sh" ] \
  && . "$CATALINA_BASE/bin/setenv-docker-customize.sh" \
  || echo "No Docker eXo Platform customization file : $CATALINA_BASE/bin/setenv-docker-customize.sh"\n\
  ' ${EXO_APP_DIR}/bin/setenv.sh && \
  grep 'setenv-docker-customize.sh' ${EXO_APP_DIR}/bin/setenv.sh

USER ${EXO_USER}
EXPOSE 8080
VOLUME ["/srv/exo"]

RUN for a in ${ADDONS}; do echo "Installing addon $a"; /opt/exo/addon install $a; done

WORKDIR ${EXO_LOG_DIR}
ENTRYPOINT ["/usr/local/bin/tini", "--"]
CMD [ "/opt/exo/start_eXo.sh" ]
