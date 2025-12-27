#!/bin/bash
set -e

WEBROOT="/var/www/html"
: "${DOMAIN_NAME:?DOMAIN_NAME is not set (e.g. DOMAIN_NAME=login.42.fr)}"

# Use only host part if someone accidentally passed host:port
DOMAIN_NO_PORT="${DOMAIN_NAME%%:*}"
WP_URL="https://${DOMAIN_NO_PORT}"

echo "Waiting for MariaDB..."
until mysqladmin ping -h"${DB_HOST:-mariadb}" -u"${DB_USER}" -p"${DB_PASS}" --silent; do
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

if [ ! -f "$WEBROOT/wp-config.php" ]; then
  echo "Creating wp-config.php..."
  cp "$WEBROOT/wp-config-sample.php" "$WEBROOT/wp-config.php"

  sed -i "s/database_name_here/${DB_NAME}/" "$WEBROOT/wp-config.php"
  sed -i "s/username_here/${DB_USER}/" "$WEBROOT/wp-config.php"
  sed -i "s/password_here/${DB_PASS}/" "$WEBROOT/wp-config.php"
  sed -i "s/localhost/${DB_HOST:-mariadb}/" "$WEBROOT/wp-config.php"
fi

echo "Ensuring WP_HOME/WP_SITEURL are set to ${WP_URL} ..."

# Update or insert WP_HOME
if grep -q "define('WP_HOME'" "$WEBROOT/wp-config.php"; then
  sed -i "s|define('WP_HOME'.*|define('WP_HOME', '${WP_URL}');|g" "$WEBROOT/wp-config.php"
else
  sed -i "/That's all, stop editing!/i define('WP_HOME', '${WP_URL}');" "$WEBROOT/wp-config.php" \
  || echo "Warning: Could not inject WP_HOME (anchor not found)."
fi

# Update or insert WP_SITEURL
if grep -q "define('WP_SITEURL'" "$WEBROOT/wp-config.php"; then
  sed -i "s|define('WP_SITEURL'.*|define('WP_SITEURL', '${WP_URL}');|g" "$WEBROOT/wp-config.php"
else
  sed -i "/That's all, stop editing!/i define('WP_SITEURL', '${WP_URL}');" "$WEBROOT/wp-config.php" \
  || echo "Warning: Could not inject WP_SITEURL (anchor not found)."
fi

chown -R www-data:www-data "$WEBROOT"

echo "Starting PHP-FPM..."
exec "$@"
