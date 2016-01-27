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

if [ -f "/etc/exo/addons-list.conf" ]; then
  # Let's install addons from /etc/exo/addons-list.conf file
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
  echo "# no add-on to install because /etc/exo/addons-list.conf file is absent."
fi
echo "# ------------------------------------ #"
echo "# eXo add-ons installation done."
echo "# ------------------------------------ #"
