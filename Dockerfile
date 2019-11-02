FROM    adoptopenjdk/openjdk8-openj9

LABEL   maintainer="eXo Platform <docker@exoplatform.com>"

ENV TINI_VERSION v0.18.0
ENV TINI_GPG_KEY 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7
ENV GOSU_VERSION 1.10
ENV GOSU_GPG_KEY B42F6819007F00F88E364FD4036A9C25BF357DD4

# Install the needed packages
RUN apt-get -qq update \
    && apt-get -qq -y upgrade ${_APT_OPTIONS} \
    && apt-get -qq -y install ${_APT_OPTIONS} xmlstarlet \
    && apt-get -qq -y install ${_APT_OPTIONS} libreoffice-calc libreoffice-draw libreoffice-impress libreoffice-math libreoffice-writer \
    && apt-get -qq -y autoremove \
    && apt-get -qq -y clean \
    && rm -rf /var/lib/apt/lists/*

# Build Arguments and environment variables
ARG EXO_VERSION=5.3.0-RC05
ARG CHAT_VERSION=2.3.0-RC05

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
RUN apt-get update
RUN apt-get install wget unzip gnupg2 -y

# Installing Tini
RUN set -ex \
    && ( \
        gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys ${TINI_GPG_KEY} \
        || gpg2 --keyserver keyserver.pgp.com          --recv-keys ${TINI_GPG_KEY} \
    )

RUN set -ex \
    && wget -nv -O /usr/local/bin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini \
    && wget -nv -O /usr/local/bin/tini.asc https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc \
    && gpg --verify /usr/local/bin/tini.asc \
    && chmod +x /usr/local/bin/tini

# Installing Gosu
RUN set -ex \
    && ( \
        gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys ${GOSU_GPG_KEY} \
        || gpg2 --keyserver keyserver.pgp.com          --recv-keys ${GOSU_GPG_KEY} \
    )

# Installing wait-for-it.sh utility
COPY bin/wait-for-it.sh /usr/local/bin/
RUN chown root:root /usr/local/bin/wait-for-it.sh \
    && chmod +x /usr/local/bin/wait-for-it.sh \
    && ln -s /usr/local/bin/wait-for-it.sh /usr/local/bin/wait-for.sh \
    && ln -s /usr/local/bin/wait-for-it.sh /usr/local/bin/wait-for

RUN set -ex \
    && curl -sS -o /usr/local/bin/gosu -L "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && curl -sS -o /usr/local/bin/gosu.asc -L "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

# Install eXo Platform
RUN if [ -n "${DOWNLOAD_USER}" ]; then PARAMS=""; fi && \
  if [ ! -n "${DOWNLOAD_URL}" ]; then \
  echo "Building an image with eXo Platform version : ${EXO_VERSION}"; \
  EXO_VERSION_SHORT=$(echo ${EXO_VERSION} | awk -F "\." '{ print $1"."$2}'); \
  DOWNLOAD_URL="https://downloads.exoplatform.org/public/releases/platform/${EXO_VERSION_SHORT}/${EXO_VERSION}/platform-community-tomcat-${EXO_VERSION}.zip"; \
  fi && \
  curl ${PARAMS} --create-dirs  -sS -L -o /srv/downloads/eXo-Platform-${EXO_VERSION}.zip ${DOWNLOAD_URL} && \
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
