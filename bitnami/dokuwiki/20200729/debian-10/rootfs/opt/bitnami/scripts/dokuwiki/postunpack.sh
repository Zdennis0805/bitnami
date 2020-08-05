#!/bin/bash

# shellcheck disable=SC1090,SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purpose

# Load DokuWiki environment
. /opt/bitnami/scripts/dokuwiki-env.sh

# Load PHP environment for 'php_conf_set' (after 'dokuwiki-env.sh' so that MODULE is not set to a wrong value)
. /opt/bitnami/scripts/php-env.sh

# Load libraries
. /opt/bitnami/scripts/libdokuwiki.sh
. /opt/bitnami/scripts/libfile.sh
. /opt/bitnami/scripts/libfs.sh
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/libphp.sh
. /opt/bitnami/scripts/libwebserver.sh

# Load web server environment and functions (after DokuWiki environment file so MODULE is not set to a wrong value)
. "/opt/bitnami/scripts/$(web_server_type)-env.sh"

# Ensure the DokuWiki base directory exists and has proper permissions
info "Configuring file permissions for DokuWiki"
ensure_user_exists "$WEB_SERVER_DAEMON_USER" "$WEB_SERVER_DAEMON_GROUP"
for dir in "$DOKUWIKI_BASE_DIR" "$DOKUWIKI_VOLUME_DIR" "${DOKUWIKI_BASE_DIR}/lib/images/smileys/local" "${DOKUWIKI_BASE_DIR}/uploads"; do
    ensure_dir_exists "$dir"
    # Use daemon:root ownership for compatibility when running as a non-root user
    configure_permissions_ownership "$dir" -d "775" -f "664" -u "$WEB_SERVER_DAEMON_USER" -g "root"
done

# Configure memory limit for PHP
info "Configuring default PHP options for DokuWiki"
php_conf_set memory_limit "$PHP_DEFAULT_MEMORY_LIMIT"

# Enable default web server configuration for DokuWiki
info "Creating default web server configuration for DokuWiki"
web_server_validate
ensure_web_server_app_configuration_exists "dokuwiki" --type php
