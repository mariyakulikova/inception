#!/bin/bash
set -euo pipefail

read_secret() {
  local var="$1"
  local file="$2"
  if [[ -f "$file" ]]; then
    local val
    val="$(tr -d '\r\n' < "$file")"
    export "$var=$val"
  fi
}

: "${DB_NAME:?DB_NAME is not set}"
: "${DB_USER:?DB_USER is not set}"

DB_HOST="${DB_HOST:-localhost}"

read_secret DB_ROOT_PASS "/run/secrets/db_root_pass"
read_secret DB_PASS      "/run/secrets/db_user_pass"

: "${DB_ROOT_PASS:?DB_ROOT_PASS is not set (secret /run/secrets/db_root_pass)}"
: "${DB_PASS:?DB_PASS is not set (secret /run/secrets/db_user_pass)}"

DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [[ ! -d "${DATADIR}/mysql" ]]; then
  echo "[mariadb] Initializing data directory..."
  chown -R mysql:mysql "$DATADIR"
  mariadb-install-db --user=mysql --datadir="$DATADIR" >/dev/null

  echo "[mariadb] Starting temporary server for init..."
  mariadbd --user=mysql --datadir="$DATADIR" \
    --skip-networking --socket="$SOCKET" &
  pid="$!"

  for i in {1..60}; do
    if mariadb-admin --socket="$SOCKET" ping >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done

  if ! mariadb-admin --socket="$SOCKET" ping >/dev/null 2>&1; then
    echo "[mariadb] ERROR: temp server didn't start"
    kill "$pid" 2>/dev/null || true
    exit 1
  fi

  echo "[mariadb] Running init SQL..."
  mariadb --protocol=socket --socket="$SOCKET" -u root <<SQL
-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';

-- Basic hardening
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;

-- Create app database and user
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SQL

  echo "[mariadb] Shutting down temporary server..."
  mariadb-admin --protocol=socket --socket="$SOCKET" -u root -p"${DB_ROOT_PASS}" shutdown

  wait "$pid" 2>/dev/null || true
  echo "[mariadb] Init done."
fi

echo "[mariadb] Starting MariaDB (foreground, PID 1)..."
exec mariadbd --user=mysql --datadir="$DATADIR" --bind-address=0.0.0.0
