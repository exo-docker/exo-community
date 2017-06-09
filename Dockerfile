# Dockerizing base image for eXo Platform with:
#
# - Libre Office
# - eXo Platform Community

# Build:    docker build -t exoplatform/exo-community:4.4 .
#
# Run:      docker run -t -i --name=exo exoplatform/exo-community:4.4
#           docker run -d --name=exo exoplatform/exo-community:4.4
#           docker run -d --name=exo -p 8080:8080 exoplatform/exo-community:4.4
#           docker run -d -v $(pwd)/setenv-customize.sh:/opt/exo/bin/setenv-customize.sh:ro --name=exo exoplatform/exo-community:latest

FROM       exoplatform/base-jdk:jdk8
MAINTAINER eXo Platform <docker@exoplatform.com>

# Environment variables
ENV EXO_VERSION 5.0.0-M08

ENV EXO_APP_DIR   /opt/exo
ENV EXO_CONF_DIR  /etc/exo
ENV EXO_DATA_DIR  /srv/exo
ENV EXO_LOG_DIR   /var/log/exo
ENV EXO_TMP_DIR   /tmp/exo-tmp

ENV EXO_USER exo
ENV EXO_GROUP ${EXO_USER}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN useradd --create-home --user-group --shell /bin/bash ${EXO_USER} && \
    # giving all rights to eXo user
    echo "exo   ALL = NOPASSWD: ALL" > /etc/sudoers.d/exo && chmod 440 /etc/sudoers.d/exo

# Install some useful or needed tools
RUN apt-get -qq update && \
  apt-get -qq -y upgrade ${_APT_OPTIONS} && \
  apt-get -qq -y install ${_APT_OPTIONS} libreoffice-calc libreoffice-draw libreoffice-impress libreoffice-math libreoffice-writer && \
  apt-get -qq -y autoremove && \
  apt-get -qq -y clean && \
  rm -rf /var/lib/apt/lists/*

# Create needed directories
# RUN mkdir -p ${EXO_APP_DIR}   && \
RUN mkdir -p ${EXO_DATA_DIR}  && chown ${EXO_USER}:${EXO_GROUP} ${EXO_DATA_DIR} && \
    mkdir -p ${EXO_TMP_DIR}   && chown ${EXO_USER}:${EXO_GROUP} ${EXO_TMP_DIR}  && \
    mkdir -p ${EXO_LOG_DIR}   && chown ${EXO_USER}:${EXO_GROUP} ${EXO_LOG_DIR}

# Install eXo Platform
RUN curl -L -o /srv/downloads/eXo-Platform-community-${EXO_VERSION}.zip https://downloads.exoplatform.org/public/exo-platform-community-edition-${EXO_VERSION}.zip \
    && unzip -q /srv/downloads/eXo-Platform-community-${EXO_VERSION}.zip -d /srv/downloads/ \
    && rm -f /srv/downloads/eXo-Platform-community-${EXO_VERSION}.zip \
    && mv /srv/downloads/platform-community-${EXO_VERSION} ${EXO_APP_DIR} \
    && chown -R ${EXO_USER}:${EXO_GROUP} ${EXO_APP_DIR} \
    && ln -s ${EXO_APP_DIR}/gatein/conf /etc/exo \
    && rm -rf ${EXO_APP_DIR}/logs && ln -s ${EXO_LOG_DIR} ${EXO_APP_DIR}/logs

# Install Docker customization file
ADD setenv-docker-customize.sh ${EXO_APP_DIR}/bin/setenv-docker-customize.sh
RUN chmod 755 ${EXO_APP_DIR}/bin/setenv-docker-customize.sh && \
    chown exo:exo ${EXO_APP_DIR}/bin/setenv-docker-customize.sh && \
    sed -i '/# Load custom settings/i \
\# Load custom settings for docker environment\n\
[ -r "$CATALINA_BASE/bin/setenv-docker-customize.sh" ] \
&& . "$CATALINA_BASE/bin/setenv-docker-customize.sh" \
|| echo "No Docker eXo Platform customization file : $CATALINA_BASE/bin/setenv-docker-customize.sh"\n\
' ${EXO_APP_DIR}/bin/setenv.sh && \
  grep 'setenv-docker-customize.sh' ${EXO_APP_DIR}/bin/setenv.sh

EXPOSE 8080
USER ${EXO_USER}

WORKDIR "/opt/exo/"
ENTRYPOINT ["/opt/exo/start_eXo.sh", "--data", "/srv/exo"]
