#!/bin/bash
set -euo pipefail

read_secret() {
  local var="$1"
  local file="$2"
  if [[ -f "$file" ]]; then
    export "$var=$(tr -d '\r\n' < "$file")"
  fi
}

wait_for_socket() {
  local socket="$1"
  for i in {1..60}; do
    if mariadb-admin --protocol=socket --socket="$socket" ping >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

: "${DB_NAME:?DB_NAME is not set}"
: "${DB_USER:?DB_USER is not set}"

read_secret DB_ROOT_PASS "/run/secrets/db_root_pass"
read_secret DB_PASS      "/run/secrets/db_user_pass"

: "${DB_ROOT_PASS:?Missing /run/secrets/db_root_pass}"
: "${DB_PASS:?Missing /run/secrets/db_user_pass}"

DATADIR="/var/lib/mysql"
MARKER="${DATADIR}/.inception_initialized"
SOCKET="/run/mysqld/mysqld.sock"
DEFAULTS_FILE="${MARIADB_DEFAULTS_FILE:-/etc/mysql/mariadb.cnf}"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql "$DATADIR"

if [[ ! -d "${DATADIR}/mysql" ]]; then
  echo "[mariadb] Installing system tables..."
  mariadb-install-db --user=mysql --datadir="$DATADIR" >/dev/null
fi

if [[ ! -f "$MARKER" ]]; then
  echo "[mariadb] First-time init..."

  mariadbd \
    --defaults-file="$DEFAULTS_FILE" \
    --user=mysql \
    --datadir="$DATADIR" \
    --skip-networking \
    --socket="$SOCKET" &
  pid="$!"

  if ! wait_for_socket "$SOCKET"; then
    echo "[mariadb] ERROR: temp server didn't start"
    kill "$pid" 2>/dev/null || true
    exit 1
  fi

  cat > /tmp/init.sql <<EOF
-- Root password (local root user)
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';

-- Create database
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create app user (allow from other containers)
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

FLUSH PRIVILEGES;
EOF

  echo "[mariadb] Applying init.sql..."
  mariadb --protocol=socket --socket="$SOCKET" -u root < /tmp/init.sql

  rm -f /tmp/init.sql
  touch "$MARKER"

  echo "[mariadb] Shutting down temp server..."
  mariadb-admin --protocol=socket --socket="$SOCKET" -u root -p"${DB_ROOT_PASS}" shutdown || true
  wait "$pid" 2>/dev/null || true

  echo "[mariadb] Init done."
fi

echo "[mariadb] Starting MariaDB..."
exec "$@"
