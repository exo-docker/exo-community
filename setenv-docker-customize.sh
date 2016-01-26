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
