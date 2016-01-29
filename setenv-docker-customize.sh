#!/bin/sh
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

# Change the device for antropy generation
CATALINA_OPTS="${CATALINA_OPTS} -Djava.security.egd=file:/dev/./urandom"

# -----------------------------------------------------------------------------
# Install add-ons if needed
# -----------------------------------------------------------------------------
echo "# ------------------------------------ #"
echo "# eXo add-ons installation start ..."
echo "# ------------------------------------ #"

if [ -z "${EXO_ADDONS_LIST}" ]; then
  echo "# no add-on to install from EXO_ADDONS_LIST environment variable."
else
  echo "# installing add-ons from EXO_ADDONS_LIST environment variable:"
  echo ${EXO_ADDONS_LIST} | tr ',' '\n' | while read _addon ; do
      # Install addon
      ${EXO_APP_DIR}/current/addon install ${_addon} --force --batch-mode
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
#    _addon_char=$(echo "$_addon" | awk  '{ string=substr($0, 1, 1); print string; }' )
#    [ "$_addon_char" = '#' ] && continue
    # Install addon
    ${EXO_APP_DIR}/current/addon install ${_addon} --force --batch-mode
  done < "$_addons_list"
else
  echo "# no add-on to install from addons-list.conf because /etc/exo/addons-list.conf file is absent."
fi
echo "# ------------------------------------ #"
echo "# eXo add-ons installation done."
echo "# ------------------------------------ #"
