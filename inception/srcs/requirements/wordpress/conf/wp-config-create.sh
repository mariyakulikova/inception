#!/bin/bash
set -e

WEBROOT="/var/www/html"

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

chown -R www-data:www-data "$WEBROOT"

echo "Starting PHP-FPM..."
exec "$@"
