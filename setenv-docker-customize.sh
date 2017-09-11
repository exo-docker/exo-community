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

# -----------------------------------------------------------------------------
# Check configuration variables and add default values when needed
# -----------------------------------------------------------------------------
set +u		# DEACTIVATE unbound variable check
[ -z "${EXO_DATA_DIR}" ] && EXO_DATA_DIR="/srv/exo"
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
    ;;
  *)
    echo "ERROR: you must provide a supported database type with EXO_DB_TYPE environment variable (current value is '${EXO_DB_TYPE}')"
    echo "ERROR: supported database types are :"
    echo "ERROR: HSQLDB     (EXO_DB_TYPE = hsqldb) (default)"
    echo "ERROR: MySQL      (EXO_DB_TYPE = mysql)"
    exit 1;;
esac
set -u		# REACTIVATE unbound variable check

# -----------------------------------------------------------------------------
# Update some configuration files when the container is created for the first time
# -----------------------------------------------------------------------------
if [ -f /opt/exo/_done.configuration ]; then
  echo "INFO: Configuration already done! skipping this step."
else
  # Database configuration
  case "${EXO_DB_TYPE}" in
    hsqldb)
      cat /opt/exo/conf/server-hsqldb.xml > /opt/exo/conf/server.xml
      ;;
    mysql)
      cat /opt/exo/conf/server-mysql.xml > /opt/exo/conf/server.xml
      replace_in_file /opt/exo/conf/server.xml "jdbc:mysql://localhost:3306/plf" "jdbc:mysql://${EXO_DB_HOST}:${EXO_DB_PORT}/${EXO_DB_NAME}"
      # sed -i 's,jdbc:mysql://localhost:3306/plf,jdbc:mysql://'${EXO_DB_HOST}':'${EXO_DB_PORT}'/'${EXO_DB_NAME}',g' /opt/exo/conf/server.xml
      replace_in_file /opt/exo/conf/server.xml 'username="plf" password="plf"' 'username="'${EXO_DB_USER}'" password="'${EXO_DB_PASSWORD}'"'
      # sed -i 's,username="plf" password="plf",username="'${EXO_DB_USER}'" password="'${EXO_DB_PASSWORD}'",g' /opt/exo/conf/server.xml
      ;;
    *) echo "ERROR: you must provide a supported database type with EXO_DB_TYPE environment variable (current value is '${EXO_DB_TYPE}')";
      exit 1;;
  esac

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
    done
  fi
  echo "# ------------------------------------ #"
  if [ -f "/etc/exo/addons-list.conf" ]; then
    echo "# installing add-ons from /etc/exo/addons-list.conf file:"
    _addons_list="/etc/exo/addons-list.conf"
    while read -r _addon; do
      # Don't read empty lines
      [ -z "${_addon}" ] && continue
      # Don't read comments
      [ "$(echo "$_addon" | awk  '{ string=substr($0, 1, 1); print string; }' )" = '#' ] && continue
      # Install addon
      ${EXO_APP_DIR}/addon install ${_ADDON_MGR_OPTIONS:-} ${_addon} --force --batch-mode
    done < "$_addons_list"
  else
    echo "# no add-on to install from addons-list.conf because /etc/exo/addons-list.conf file is absent."
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

# Change the device for antropy generation
CATALINA_OPTS="${CATALINA_OPTS:-} -Djava.security.egd=file:/dev/./urandom"

set +u		# DEACTIVATE unbound variable check
