#!/bin/bash
set -e

SUBJ_CN="${DOMAIN_NAME:-localhost}"
SSL_DIR="/etc/nginx/ssl"
CRT="${SSL_DIR}/inception.crt"
KEY="${SSL_DIR}/inception.key"

mkdir -p "$SSL_DIR"

if [ ! -f "$CRT" ] || [ ! -f "$KEY" ]; then
  echo "Generating self-signed certificate..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEY" \
    -out "$CRT" \
    -subj "/CN=${SUBJ_CN}" \
    -addext "subjectAltName=DNS:${SUBJ_CN}"
fi

exec "$@"
