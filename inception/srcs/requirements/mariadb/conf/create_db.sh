#!/bin/bash
set -e

DATADIR="/var/lib/mysql"
MARKER="$DATADIR/.inception_initialized"

chown -R mysql:mysql "$DATADIR"

if [ -f "$MARKER" ]; then
  echo "MariaDB already initialized (marker found)."
  exec "$@"
fi

echo "Starting temp MariaDB server..."
mysqld_safe --datadir="$DATADIR" --skip-networking &
pid="$!"

until mysqladmin ping --silent; do
  sleep 1
done

echo "Creating DB/user if needed..."
mysql -uroot <<-SQL
  FLUSH PRIVILEGES;

  ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT}';

  CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

  CREATE USER IF NOT EXISTS '${DB_USER}'@'%'
    IDENTIFIED BY '${DB_PASS}';

  GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
  FLUSH PRIVILEGES;
SQL


touch "$MARKER"
chown mysql:mysql "$MARKER"

echo "Stopping temp MariaDB server..."
mysqladmin -uroot -p"${DB_ROOT}" shutdown
wait "$pid"

echo "MariaDB init done. Starting server..."
exec "$@"

