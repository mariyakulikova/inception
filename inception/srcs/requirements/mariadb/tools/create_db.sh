#!/bin/bash
set -euo pipefail

read_secret() {
  local var="$1"
  local file="$2"
  if [[ -f "$file" ]]; then
    export "$var=$(tr -d '\r\n' < "$file")"
  fi
}

: "${DB_NAME:?DB_NAME is not set}"
: "${DB_USER:?DB_USER is not set}"

read_secret DB_ROOT_PASS "/run/secrets/db_root_pass"
read_secret DB_PASS      "/run/secrets/db_user_pass"

: "${DB_ROOT_PASS:?Missing /run/secrets/db_root_pass}"
: "${DB_PASS:?Missing /run/secrets/db_user_pass}"

DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"
MARKER="${DATADIR}/.setup_done"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql "$DATADIR"

if [[ ! -d "${DATADIR}/mysql" ]]; then
  echo "[mariadb] Initializing system tables..."
  mariadb-install-db --user=mysql --datadir="$DATADIR" >/dev/null
fi

if [[ ! -f "$MARKER" ]]; then
  echo "[mariadb] First-time bootstrap (db/user/root password)..."

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

  cat >/tmp/init.sql <<SQL
-- Create app database and user
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

-- Ensure root password is set (works even if already set, in MariaDB it may error if auth differs; acceptable)
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';

-- Basic hardening (optional but fine)
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
SQL

  echo "[mariadb] Applying init SQL..."
  if mariadb --protocol=socket --socket="$SOCKET" -u root < /tmp/init.sql >/dev/null 2>&1; then
    true
  else
    mariadb --protocol=socket --socket="$SOCKET" -u root -p"${DB_ROOT_PASS}" < /tmp/init.sql
  fi

  rm -f /tmp/init.sql
  touch "$MARKER"

  echo "[mariadb] Shutting down temp server..."
  if ! mariadb-admin --protocol=socket --socket="$SOCKET" -u root shutdown >/dev/null 2>&1; then
    mariadb-admin --protocol=socket --socket="$SOCKET" -u root -p"${DB_ROOT_PASS}" shutdown
  fi
  wait "$pid" 2>/dev/null || true

  echo "[mariadb] Bootstrap done."
fi

echo "[mariadb] Starting MariaDB (PID 1)..."
exec mariadbd --user=mysql --datadir="$DATADIR" --bind-address=0.0.0.0
