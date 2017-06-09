#!/bin/bash -eu
# -----------------------------------------------------------------------------
#
# Settings customization
#
# Refer to eXo Platform Administrators Guide for more details.
# http://docs.exoplatform.com
#
# -----------------------------------------------------------------------------
# This file contains customizations related to Docker environment.
# -----------------------------------------------------------------------------

replace_in_file() {
  local _tmpFile=$(mktemp /tmp/replace.XXXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }
  mv $1 ${_tmpFile}
  sed "s|$2|$3|g" ${_tmpFile} > $1
  rm ${_tmpFile}
}

# $1 : the full line content to insert at the end of eXo configuration file
add_in_exo_configuration() {
  local EXO_CONFIG_FILE="/etc/exo/exo.properties"
  local P1="$1"
  if [ ! -f ${EXO_CONFIG_FILE} ]; then
    echo "Creating eXo configuration file [${EXO_CONFIG_FILE}]"
    touch ${EXO_CONFIG_FILE}
    if [ $? != 0 ]; then
      echo "Problem during eXo configuration file creation, startup aborted !"
      exit 1
    fi
  fi
  echo "${P1}" >> ${EXO_CONFIG_FILE}
}

# $1 : the full line content to insert at the end of Chat configuration file
add_in_chat_configuration() {
  local _CONFIG_FILE="/etc/exo/chat.properties"
  local P1="$1"
  if [ ! -f ${_CONFIG_FILE} ]; then
    echo "Creating Chat configuration file [${_CONFIG_FILE}]"
    touch ${_CONFIG_FILE}
    if [ $? != 0 ]; then
      echo "Problem during Chat configuration file creation, startup aborted !"
      exit 1
    fi
  fi
  echo "${P1}" >> ${_CONFIG_FILE}
}

# -----------------------------------------------------------------------------
# Check configuration variables and add default values when needed
# -----------------------------------------------------------------------------
set +u		# DEACTIVATE unbound variable check
[ -z "${EXO_PROXY_VHOST}" ] && EXO_PROXY_VHOST="localhost"
[ -z "${EXO_PROXY_SSL}" ] && EXO_PROXY_SSL="false"
[ -z "${EXO_PROXY_PORT}" ] && {
  case "${EXO_PROXY_SSL}" in 
    true) EXO_PROXY_PORT="443";;
    false) EXO_PROXY_PORT="8080";;
    *) EXO_PROXY_PORT="8080";;
  esac
}
[ -z "${EXO_DATA_DIR}" ] && EXO_DATA_DIR="/srv/exo"
[ -z "${EXO_FILE_STORAGE_DIR}" ] && EXO_FILE_STORAGE_DIR="${EXO_DATA_DIR}/files"
[ -z "${EXO_FILE_STORAGE_RETENTION}" ] && EXO_FILE_STORAGE_RETENTION="30"

[ -z "${EXO_DB_TYPE}" ] && EXO_DB_TYPE="hsqldb"
case "${EXO_DB_TYPE}" in
  hsqldb)
    echo "################################################################################"
    echo "# WARNING: you are using HSQLDB which is not recommanded for production purpose."
    echo "################################################################################"
    sleep 2
    ;;
  mysql)
    [ -z "${EXO_DB_NAME}" ] && EXO_DB_NAME="exo"
    [ -z "${EXO_DB_USER}" ] && EXO_DB_USER="exo"
    [ -z "${EXO_DB_PASSWORD}" ] && { echo "ERROR: you must provide a database password with EXO_DB_PASSWORD environment variable"; exit 1;}
    [ -z "${EXO_DB_HOST}" ] && EXO_DB_HOST="mysql"
    [ -z "${EXO_DB_PORT}" ] && EXO_DB_PORT="3306"
    [ -z "${EXO_DB_INSTALL_DRIVER}" ] && EXO_DB_INSTALL_DRIVER="true"
    ;;
  *)
    echo "ERROR: you must provide a supported database type with EXO_DB_TYPE environment variable (current value is '${EXO_DB_TYPE}')"
    echo "ERROR: supported database types are :"
    echo "ERROR: HSQLDB     (EXO_DB_TYPE = hsqldb) (default)"
    echo "ERROR: MySQL      (EXO_DB_TYPE = mysql)"
    exit 1;;
esac
[ -z "${EXO_UPLOAD_MAX_FILE_SIZE}" ] && EXO_UPLOAD_MAX_FILE_SIZE="200"

[ -z "${EXO_MAIL_FROM}" ] && EXO_MAIL_FROM="noreply@exoplatform.com"
[ -z "${EXO_MAIL_SMTP_HOST}" ] && EXO_MAIL_SMTP_HOST="localhost"
[ -z "${EXO_MAIL_SMTP_PORT}" ] && EXO_MAIL_SMTP_PORT="25"
[ -z "${EXO_MAIL_SMTP_STARTTLS}" ] && EXO_MAIL_SMTP_STARTTLS="false"
[ -z "${EXO_MAIL_SMTP_USERNAME}" ] && EXO_MAIL_SMTP_USERNAME="-"
[ -z "${EXO_MAIL_SMTP_PASSWORD}" ] && EXO_MAIL_SMTP_PASSWORD="-"

[ -z "${EXO_JMX_ENABLED}" ] && EXO_JMX_ENABLED="true"
[ -z "${EXO_JMX_RMI_REGISTRY_PORT}" ] && EXO_JMX_RMI_REGISTRY_PORT="10001"
[ -z "${EXO_JMX_RMI_SERVER_PORT}" ] && EXO_JMX_RMI_SERVER_PORT="10002"
[ -z "${EXO_JMX_RMI_SERVER_HOSTNAME}" ] && EXO_JMX_RMI_SERVER_HOSTNAME="localhost"
[ -z "${EXO_JMX_USERNAME}" ] && EXO_JMX_USERNAME="-"
[ -z "${EXO_JMX_PASSWORD}" ] && EXO_JMX_PASSWORD="-"

[ -z "${EXO_MONGO_HOST}" ] && EXO_MONGO_HOST="mongo"
[ -z "${EXO_MONGO_PORT}" ] && EXO_MONGO_PORT="27017"
[ -z "${EXO_MONGO_USERNAME}" ] && EXO_MONGO_USERNAME="-"
[ -z "${EXO_MONGO_PASSWORD}" ] && EXO_MONGO_PASSWORD="-"
[ -z "${EXO_MONGO_DB_NAME}" ] && EXO_MONGO_DB_NAME="chat"

[ -z "${EXO_ES_EMBEDDED}" ] && EXO_ES_EMBEDDED="true"
[ -z "${EXO_ES_EMBEDDED_DATA}" ] && EXO_ES_EMBEDDED_DATA="/srv/exo/es"
[ -z "${EXO_ES_SCHEME}" ] && EXO_ES_SCHEME="http"
[ -z "${EXO_ES_HOST}" ] && EXO_ES_HOST="localhost"
[ -z "${EXO_ES_PORT}" ] && EXO_ES_PORT="9200"
EXO_ES_URL="${EXO_ES_SCHEME}://${EXO_ES_HOST}:${EXO_ES_PORT}"
[ -z "${EXO_ES_USERNAME}" ] && EXO_ES_USERNAME="-"
[ -z "${EXO_ES_PASSWORD}" ] && EXO_ES_PASSWORD="-"
[ -z "${EXO_ES_INDEX_REPLICA_NB}" ] && EXO_ES_INDEX_REPLICA_NB="1"
[ -z "${EXO_ES_INDEX_SHARD_NB}" ] && EXO_ES_INDEX_SHARD_NB="5"

set -u		# REACTIVATE unbound variable check

# -----------------------------------------------------------------------------
# Update some configuration files when the container is created for the first time
# -----------------------------------------------------------------------------
if [ -f /opt/exo/_done.configuration ]; then
  echo "INFO: Configuration already done! skipping this step."
else
  # File storage configuration
  add_in_exo_configuration "# File storage configuration"
  add_in_exo_configuration "exo.files.binaries.storage.type=fs"
  add_in_exo_configuration "exo.files.storage.dir=${EXO_FILE_STORAGE_DIR}"
  add_in_exo_configuration "exo.commons.FileStorageCleanJob.retention-time=${EXO_FILE_STORAGE_RETENTION}"

  # Database configuration
  case "${EXO_DB_TYPE}" in
    hsqldb)
      cat /opt/exo/conf/server-hsqldb.xml > /opt/exo/conf/server.xml
      ;;
    mysql)
      cat /opt/exo/conf/server-mysql.xml > /opt/exo/conf/server.xml
      replace_in_file /opt/exo/conf/server.xml "jdbc:mysql://localhost:3306/plf" "jdbc:mysql://${EXO_DB_HOST}:${EXO_DB_PORT}/${EXO_DB_NAME}"
      replace_in_file /opt/exo/conf/server.xml 'username="plf" password="plf"' 'username="'${EXO_DB_USER}'" password="'${EXO_DB_PASSWORD}'"'
      if [ "${EXO_DB_INSTALL_DRIVER}" = "true" ]; then
        ${EXO_APP_DIR}/addon install ${_ADDON_MGR_OPTIONS:-} exo-jdbc-driver-mysql --batch-mode
      else
        echo "WARNING: no database driver will be automatically installed (EXO_DB_INSTALL_DRIVER=false)."
      fi
      ;;
    *) echo "ERROR: you must provide a supported database type with EXO_DB_TYPE environment variable (current value is '${EXO_DB_TYPE}')";
      exit 1;;
  esac

  ## Remove file comments
  xmlstarlet ed -L -d "//comment()" /opt/exo/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (xml comments removal)"
    exit 1
  }

  ## Remove AJP connector
  xmlstarlet ed -L -d '//Connector[@protocol="AJP/1.3"]' /opt/exo/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (AJP connector removal)"
    exit 1
  }

  # Proxy configuration
  xmlstarlet ed -L -s "/Server/Service/Connector" -t attr -n "proxyName" -v "${EXO_PROXY_VHOST}" /opt/exo/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (adding Connector proxyName)"
    exit 1
  }

  if [ "${EXO_PROXY_SSL}" = "true" ]; then
    xmlstarlet ed -L -s "/Server/Service/Connector" -t attr -n "scheme" -v "https" \
      -s "/Server/Service/Connector" -t attr -n "secure" -v "false" \
      -s "/Server/Service/Connector" -t attr -n "proxyPort" -v "${EXO_PROXY_PORT}" \
      /opt/exo/conf/server.xml || {
      echo "ERROR during xmlstarlet processing (configuring Connector proxy ssl)"
      exit 1
    }
    if [ "${EXO_PROXY_PORT}" = "443" ]; then
      add_in_exo_configuration "exo.base.url=https://${EXO_PROXY_VHOST}"
    else
      add_in_exo_configuration "exo.base.url=https://${EXO_PROXY_VHOST}:${EXO_PROXY_PORT}"
    fi
  else
    xmlstarlet ed -L -s "/Server/Service/Connector" -t attr -n "scheme" -v "http" \
      -s "/Server/Service/Connector" -t attr -n "secure" -v "false" \
      -s "/Server/Service/Connector" -t attr -n "proxyPort" -v "${EXO_PROXY_PORT}" \
      /opt/exo/conf/server.xml || {
      echo "ERROR during xmlstarlet processing (configuring Connector proxy)"
      exit 1
    }
    if [ "${EXO_PROXY_PORT}" = "443" ]; then
      add_in_exo_configuration "exo.base.url=http://${EXO_PROXY_VHOST}"
    else
      add_in_exo_configuration "exo.base.url=http://${EXO_PROXY_VHOST}:${EXO_PROXY_PORT}"
    fi
  fi

  # Upload size
  add_in_exo_configuration "exo.ecms.connector.drives.uploadLimit=${EXO_UPLOAD_MAX_FILE_SIZE}"

  # Mail configuration
  add_in_exo_configuration "# Mail configuration"
  add_in_exo_configuration "exo.email.smtp.from=${EXO_MAIL_FROM}"
  add_in_exo_configuration "exo.email.smtp.host=${EXO_MAIL_SMTP_HOST}"
  add_in_exo_configuration "exo.email.smtp.port=${EXO_MAIL_SMTP_PORT}"
  add_in_exo_configuration "exo.email.smtp.starttls.enable=${EXO_MAIL_SMTP_STARTTLS}"
  if [ "${EXO_MAIL_SMTP_USERNAME:-}" = "-" ]; then
    add_in_exo_configuration "exo.email.smtp.auth=false"
    add_in_exo_configuration "#exo.email.smtp.username="
    add_in_exo_configuration "#exo.email.smtp.password="
  else
    add_in_exo_configuration "exo.email.smtp.auth=true"
    add_in_exo_configuration "exo.email.smtp.username=${EXO_MAIL_SMTP_USERNAME}"
    add_in_exo_configuration "exo.email.smtp.password=${EXO_MAIL_SMTP_PASSWORD}"
  fi
  add_in_exo_configuration "exo.email.smtp.socketFactory.port="
  add_in_exo_configuration "exo.email.smtp.socketFactory.class="

  # JMX configuration
  if [ "${EXO_JMX_ENABLED}" = "true" ]; then
    # insert the listener before the "Global JNDI resources" line
    xmlstarlet ed -L -i "/Server/GlobalNamingResources" -t elem -n ListenerTMP -v "" \
      -i "//ListenerTMP" -t attr -n "className" -v "org.apache.catalina.mbeans.JmxRemoteLifecycleListener" \
      -i "//ListenerTMP" -t attr -n "rmiRegistryPortPlatform" -v "${EXO_JMX_RMI_REGISTRY_PORT}" \
      -i "//ListenerTMP" -t attr -n "rmiServerPortPlatform" -v "${EXO_JMX_RMI_SERVER_PORT}" \
      -i "//ListenerTMP" -t attr -n "useLocalPorts" -v "false" \
      -r "//ListenerTMP" -v "Listener" \
      /opt/exo/conf/server.xml || {
      echo "ERROR during xmlstarlet processing (adding JmxRemoteLifecycleListener)"
      exit 1
    }
    # Create the security files if required
    if [ "${EXO_JMX_USERNAME:-}" != "-" ]; then
      if [ "${EXO_JMX_PASSWORD:-}" = "-" ]; then
        EXO_JMX_PASSWORD="$(tr -dc '[:alnum:]' < /dev/urandom  | dd bs=2 count=6 2>/dev/null)"
      fi
    # /opt/exo/conf/jmxremote.password
    echo "${EXO_JMX_USERNAME} ${EXO_JMX_PASSWORD}" > /opt/exo/conf/jmxremote.password
    # /opt/exo/conf/jmxremote.access
    echo "${EXO_JMX_USERNAME} readwrite" > /opt/exo/conf/jmxremote.access
    fi
  fi

  # Elasticsearch configuration
  add_in_exo_configuration "# Elasticsearch configuration"
  add_in_exo_configuration "exo.es.embedded.enabled=${EXO_ES_EMBEDDED}"
  if [ "${EXO_ES_EMBEDDED}" = "true" ]; then
    add_in_exo_configuration "es.network.host=0.0.0.0" # we listen on all IPs inside the container
    add_in_exo_configuration "es.discovery.zen.ping.multicast.enabled=false"
    add_in_exo_configuration "es.http.port=${EXO_ES_PORT}"
    add_in_exo_configuration "es.path.data=${EXO_ES_EMBEDDED_DATA}"
  fi
  
  add_in_exo_configuration "exo.es.search.server.url=${EXO_ES_URL}"
  add_in_exo_configuration "exo.es.index.server.url=${EXO_ES_URL}"

  if [ "${EXO_ES_USERNAME:-}" != "-" ]; then
    add_in_exo_configuration "exo.es.index.server.username=${EXO_ES_USERNAME}"
    add_in_exo_configuration "exo.es.index.server.password=${EXO_ES_PASSWORD}"
    add_in_exo_configuration "exo.es.search.server.username=${EXO_ES_USERNAME}"
    add_in_exo_configuration "exo.es.search.server.password=${EXO_ES_PASSWORD}"
  else
    add_in_exo_configuration "#exo.es.index.server.username="
    add_in_exo_configuration "#exo.es.index.server.password="
    add_in_exo_configuration "#exo.es.search.server.username="
    add_in_exo_configuration "#exo.es.search.server.password="
  fi

  add_in_exo_configuration "exo.es.indexing.replica.number.default=${EXO_ES_INDEX_REPLICA_NB}"
  add_in_exo_configuration "exo.es.indexing.shard.number.default=${EXO_ES_INDEX_SHARD_NB}"

  # Mongodb configuration (for the Chat)
  add_in_chat_configuration "# eXo Chat mongodb configuration"
  add_in_chat_configuration "dbServerHost=${EXO_MONGO_HOST}"
  add_in_chat_configuration "dbServerPort=${EXO_MONGO_PORT}"
  add_in_chat_configuration "dbName=${EXO_MONGO_DB_NAME}"
  if [ "${EXO_MONGO_USERNAME:-}" = "-" ]; then
    add_in_chat_configuration "dbAuthentication=false"
    add_in_chat_configuration "#dbUser="
    add_in_chat_configuration "#dbPassword="
  else
    add_in_chat_configuration "dbAuthentication=true"
    add_in_chat_configuration "dbUser=${EXO_MONGO_USERNAME}"
    add_in_chat_configuration "dbPassword=${EXO_MONGO_PASSWORD}"
  fi

  # eXo Chat configuration
  add_in_chat_configuration "# eXo Chat server configuration"
  # The password to access REST service on the eXo Chat server.
  add_in_chat_configuration "chatPassPhrase=something2change"
  # The notifications are cleaned up every one hour by default.
  add_in_chat_configuration "chatCronNotifCleanup=0 0/60 * * * ?"
  # The eXo group who can create teams.
  add_in_chat_configuration "teamAdminGroup=/platform/users"
  # When a user reads a chat, the application displays messages of some days in the past.
  add_in_chat_configuration "chatReadDays=30"
  # The number of messages that you can get in the Chat room.
  add_in_chat_configuration "chatReadTotalJson=200"
  # We must override this to remain inside the docker container (works only for embedded chat server)
  add_in_chat_configuration "chatServerBase=http://localhost:8080"

  add_in_chat_configuration "# eXo Chat client configuration"
  # Time interval to refresh messages in a chat.
  add_in_chat_configuration "chatIntervalChat=3000"
  # Time interval to keep a chat session alive in milliseconds.
  add_in_chat_configuration "chatIntervalSession=60000"
  # Time interval to refresh user status in milliseconds.
  add_in_chat_configuration "chatIntervalStatus=20000"
  # Time interval to refresh Notifications in the main menu in milliseconds.
  add_in_chat_configuration "chatIntervalNotif=3000"
  # Time interval to refresh Users list in milliseconds.
  add_in_chat_configuration "chatIntervalUsers=5000"
  # Time after which a token will be invalid. The use will then be considered offline.
  add_in_chat_configuration "chatTokenValidity=30000"

  # put a file to avoid doing the configuration twice
  touch /opt/exo/_done.configuration
fi

# -----------------------------------------------------------------------------
# Install add-ons if needed when the container is created for the first time
# -----------------------------------------------------------------------------
if [ -f /opt/exo/_done.addons ]; then
  echo "INFO: add-ons installation already done! skipping this step."
else
  echo "# ------------------------------------ #"
  echo "# eXo add-ons installation start ..."
  echo "# ------------------------------------ #"

  if [ ! -z "${EXO_ADDONS_CATALOG_URL:-}" ]; then
    echo "The add-on manager catalog url was overriden with : ${EXO_ADDONS_CATALOG_URL}"
    _ADDON_MGR_OPTIONS="--catalog=${EXO_ADDONS_CATALOG_URL}"
  fi

  if [ -z "${EXO_ADDONS_LIST:-}" ]; then
    echo "# no add-on to install from EXO_ADDONS_LIST environment variable."
  else
    echo "# installing add-ons from EXO_ADDONS_LIST environment variable:"
    echo ${EXO_ADDONS_LIST} | tr ',' '\n' | while read _addon ; do
      # Install addon
      ${EXO_APP_DIR}/addon install ${_ADDON_MGR_OPTIONS:-} ${_addon} --force --batch-mode
      if [ $? != 0 ]; then
        echo "[ERROR] Problem during add-on [${_addon}] install."
        exit 1
      fi
    done
    if [ $? != 0 ]; then
      echo "[ERROR] An error during add-on installation phase aborted eXo startup !"
      exit 1
    fi
  fi
  echo "# ------------------------------------ #"
  echo "# eXo add-ons installation done."
  echo "# ------------------------------------ #"

  # put a file to avoid doing the configuration twice
  touch /opt/exo/_done.addons
fi

# -----------------------------------------------------------------------------
# Change chat add-on security token at each start
# -----------------------------------------------------------------------------
if [ -f /etc/exo/chat.properties ]; then
  sed -i 's/^chatPassPhrase=.*$/chatPassPhrase='"$(tr -dc '[:alnum:]' < /dev/urandom  | dd bs=4 count=6 2>/dev/null)"'/' /etc/exo/chat.properties
fi

# -----------------------------------------------------------------------------
# JMX configuration
# -----------------------------------------------------------------------------
if [ "${EXO_JMX_ENABLED}" = "true" ]; then
  CATALINA_OPTS="${CATALINA_OPTS:-} -Dcom.sun.management.jmxremote=true"
  CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.ssl=false"
  CATALINA_OPTS="${CATALINA_OPTS} -Djava.rmi.server.hostname=${EXO_JMX_RMI_SERVER_HOSTNAME}"
  if [ "${EXO_JMX_USERNAME:-}" = "-" ]; then
    CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.authenticate=false"
  else
    CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.authenticate=true"
    CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.password.file=/opt/exo/conf/jmxremote.password"
    CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.access.file=/opt/exo/conf/jmxremote.access"
  fi
fi

# -----------------------------------------------------------------------------
# Create the DATA directories if needed
# -----------------------------------------------------------------------------
if [ ! -d "${EXO_DATA_DIR}" ]; then
  mkdir -p "${EXO_DATA_DIR}"
fi

if [ ! -d "${EXO_FILE_STORAGE_DIR}" ]; then
  mkdir -p "${EXO_FILE_STORAGE_DIR}"
fi

# Change the device for antropy generation
CATALINA_OPTS="${CATALINA_OPTS:-} -Djava.security.egd=file:/dev/./urandom"

# Wait for database availability
case "${EXO_DB_TYPE}" in
  mysql)
    echo "Waiting for database ${EXO_DB_TYPE} availability at ${EXO_DB_HOST}:${EXO_DB_PORT} ..."
    /opt/wait-for-it.sh ${EXO_DB_HOST}:${EXO_DB_PORT} -s -t 60
    ;;
esac

# Wait for mongodb availability (if chat is installed)
if [ -f /opt/exo/addons/statuses/exo-chat-community.status ]; then
  echo "Waiting for mongodb availability at ${EXO_MONGO_HOST}:${EXO_MONGO_PORT} ..."
  /opt/wait-for-it.sh ${EXO_MONGO_HOST}:${EXO_MONGO_PORT} -s -t 60
fi

# Wait for elasticsearch availability (if external)
if [ "${EXO_ES_EMBEDDED}" != "true" ]; then
  echo "Waiting for external elastic search availability at ${EXO_ES_HOST}:${EXO_ES_PORT} ..."
  /opt/wait-for-it.sh ${EXO_ES_HOST}:${EXO_ES_PORT} -s -t 60
fi

set +u		# DEACTIVATE unbound variable check
