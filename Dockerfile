# Dockerizing base image for eXo Platform with:
#
# - Libre Office
# - eXo Platform Community

# Build:    docker build -t exoplatform/exo-community:4.3 .
#
# Run:      docker run -t -i --name=exo exoplatform/exo-community:4.3
#           docker run -d --name=exo exoplatform/exo-community:4.3
#           docker run -d --name=exo -p 8080:8080 exoplatform/exo-community:4.3

FROM       exoplatform/base-jdk:1.8
MAINTAINER DROUET Frederic <fdrouet+docker@exoplatform.com>

# Environment variables
ENV EXO_VERSION 4.3.0
ENV EXO_EDITION community
ENV EXO_DOWNLOAD http://sourceforge.net/projects/exo/files/Platform4.3/eXo-Platform-${EXO_EDITION}-${EXO_VERSION}.zip/download

ENV EXO_APP_DIR   /opt/exo
ENV EXO_DATA_DIR  /srv/exo
ENV EXO_LOG_DIR   /var/log/exo
ENV EXO_TMP_DIR   /tmp/exo-tmp

ENV EXO_USER exo
ENV EXO_GROUP ${EXO_USER}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN useradd --create-home --user-group --shell /bin/bash ${EXO_USER}
# giving all rights to eXo user
RUN echo "exo   ALL = NOPASSWD: ALL" > /etc/sudoers.d/exo && chmod 440 /etc/sudoers.d/exo

# Install some useful or needed tools
RUN apt-get -qq update && \
  apt-get -qq -y upgrade && \
  apt-get -qq -y install libreoffice-calc libreoffice-draw libreoffice-impress libreoffice-math libreoffice-writer && \
  apt-get -qq -y autoremove && \
  apt-get -qq -y autoclean && \
  rm -rf /var/lib/apt/lists/*

# Create needed directories
RUN mkdir -p ${EXO_APP_DIR}
RUN mkdir -p ${EXO_DATA_DIR}  && chown ${EXO_USER}:${EXO_GROUP} ${EXO_DATA_DIR}
RUN mkdir -p ${EXO_TMP_DIR}   && chown ${EXO_USER}:${EXO_GROUP} ${EXO_TMP_DIR}
RUN mkdir -p ${EXO_LOG_DIR}   && chown ${EXO_USER}:${EXO_GROUP} ${EXO_LOG_DIR}

# Install eXo Platform
RUN curl -L -o /srv/downloads/eXo-Platform-${EXO_EDITION}-${EXO_VERSION}.zip ${EXO_DOWNLOAD} && \
    unzip -q /srv/downloads/eXo-Platform-${EXO_EDITION}-${EXO_VERSION}.zip -d ${EXO_APP_DIR} && \
    rm -f /srv/downloads/eXo-Platform-${EXO_EDITION}-${EXO_VERSION}.zip && \
    ln -s ${EXO_APP_DIR}/platform-${EXO_EDITION}-${EXO_VERSION} ${EXO_APP_DIR}/current && \
    chown -R ${EXO_USER}:${EXO_GROUP} ${EXO_APP_DIR}/current/

# Install Docker customization file
ADD setenv-docker-customize.sh ${EXO_APP_DIR}/current/bin/setenv-docker-customize.sh
RUN chmod 755 ${EXO_APP_DIR}/current/bin/setenv-docker-customize.sh & chown exo:exo ${EXO_APP_DIR}/current/bin/setenv-docker-customize.sh
RUN sed -i '/# Load custom settings/i \
\# Load custom settings for docker environment\n\
[ -r "$CATALINA_BASE/bin/setenv-docker-customize.sh" ] \
&& . "$CATALINA_BASE/bin/setenv-docker-customize.sh" \
|| echo "No Docker eXo Platform customization file : $CATALINA_BASE/bin/setenv-docker-customize.sh"\n\
' ${EXO_APP_DIR}/current/bin/setenv.sh && \
  grep 'setenv-docker-customize.sh' ${EXO_APP_DIR}/current/bin/setenv.sh


RUN rm -rf ${EXO_APP_DIR}/current/logs && ln -s ${EXO_LOG_DIR} ${EXO_APP_DIR}/current/logs

EXPOSE 8080
USER ${EXO_USER}
CMD ${EXO_APP_DIR}/current/start_eXo.sh --data ${EXO_DATA_DIR}
