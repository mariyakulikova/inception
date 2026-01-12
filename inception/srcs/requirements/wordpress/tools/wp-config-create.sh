#!/bin/bash
set -e

WEBROOT="/var/www/html"
MARKER="$WEBROOT/.inception_wp_initialized"

: "${DOMAIN_NAME:?DOMAIN_NAME is not set (e.g. DOMAIN_NAME=login.42.fr)}"
: "${DB_NAME:?DB_NAME is not set}"
: "${DB_USER:?DB_USER is not set}"
: "${DB_HOST:=mariadb}"

: "${WP_TITLE:=Inception}"
: "${WP_ADMIN_USER:=siteowner}"
: "${WP_ADMIN_EMAIL:=admin@example.com}"
: "${WP_USER:=user}"
: "${WP_USER_EMAIL:=user@example.com}"
: "${WP_USER_ROLE:=subscriber}"

WP_URL="https://${DOMAIN_NAME}"

read_secret() {
  local path="$1"

  if [ ! -f "$path" ]; then
    echo "ERROR: secret file not found: $path" >&2
    exit 1
  fi

  local secret
  secret="$(tr -d '\r\n' < "$path")"

  if [ -z "$secret" ]; then
    echo "ERROR: secret is empty: $path" >&2
    exit 1
  fi

  printf '%s' "$secret"
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERROR: missing command: $1" >&2
    exit 1
  }
}

need_cmd mysqladmin
need_cmd curl
need_cmd tar
need_cmd sed
need_cmd wp

DB_PASS="$(read_secret /run/secrets/db_user_pass)"
WP_ADMIN_PASS="$(read_secret /run/secrets/wp_admin_pass)"
WP_USER_PASS="$(read_secret /run/secrets/wp_user_pass)"

echo "Waiting for MariaDB..."
until mysqladmin ping -h"${DB_HOST}" --silent; do
  sleep 1
done
echo "MariaDB is up."

if [ ! -f "$WEBROOT/wp-settings.php" ]; then
  echo "Downloading WordPress..."
  curl -fsSL https://wordpress.org/latest.tar.gz -o /tmp/wp.tar.gz
  tar -xzf /tmp/wp.tar.gz -C /tmp
  cp -a /tmp/wordpress/. "$WEBROOT/"
  rm -rf /tmp/wp.tar.gz /tmp/wordpress
fi

cd "$WEBROOT"

if [ ! -f "$WEBROOT/wp-config.php" ]; then
  echo "Creating wp-config.php..."
  wp config create \
    --allow-root \
    --dbname="${DB_NAME}" \
    --dbuser="${DB_USER}" \
    --dbpass="${DB_PASS}" \
    --dbhost="${DB_HOST}" \
    --skip-check
fi

if grep -q "define('WP_HOME'" wp-config.php; then
  sed -i "s|define('WP_HOME'.*|define('WP_HOME', '${WP_URL}');|g" wp-config.php
else
  sed -i "/That's all, stop editing!/i define('WP_HOME', '${WP_URL}');" wp-config.php
fi

if grep -q "define('WP_SITEURL'" wp-config.php; then
  sed -i "s|define('WP_SITEURL'.*|define('WP_SITEURL', '${WP_URL}');|g" wp-config.php
else
  sed -i "/That's all, stop editing!/i define('WP_SITEURL', '${WP_URL}');" wp-config.php
fi

if [ ! -f "$MARKER" ]; then
  chown -R www-data:www-data "$WEBROOT"
fi

if [ ! -f "$MARKER" ]; then
  echo "Installing WordPress..."
  wp core install \
    --allow-root \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_EMAIL}"

  touch "$MARKER"
  chown www-data:www-data "$MARKER"
else
  wp option update home "${WP_URL}" --allow-root >/dev/null 2>&1 || true
  wp option update siteurl "${WP_URL}" --allow-root >/dev/null 2>&1 || true
fi

if ! wp user get "${WP_ADMIN_USER}" --allow-root >/dev/null 2>&1; then
  echo "Creating admin user ${WP_ADMIN_USER}..."
  wp user create "${WP_ADMIN_USER}" "${WP_ADMIN_EMAIL}" \
    --allow-root \
    --role=administrator \
    --user_pass="${WP_ADMIN_PASS}"
fi

if ! wp user get "${WP_USER}" --allow-root >/dev/null 2>&1; then
  echo "Creating regular user ${WP_USER}..."
  wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
    --allow-root \
    --role="${WP_USER_ROLE}" \
    --user_pass="${WP_USER_PASS}"
else
  wp user update "${WP_USER}" --role="${WP_USER_ROLE}" --allow-root >/dev/null 2>&1 || true
fi

echo "Starting PHP-FPM..."
exec "$@"
