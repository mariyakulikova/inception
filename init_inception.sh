#!/bin/bash
set -euo pipefail

# ====== CONFIG ======
PROJECT_DIR="inception"
INTRANAME="<intraname>"     # replace with your intraname
DOMAIN="${INTRANAME}.42.fr"

# ====== CREATE ROOT STRUCTURE ======
mkdir -p "${PROJECT_DIR}"
touch "${PROJECT_DIR}/Makefile"

# secrets/
mkdir -p "${PROJECT_DIR}/secrets"
touch "${PROJECT_DIR}/secrets/credentials.txt"
touch "${PROJECT_DIR}/secrets/db_password.txt"
touch "${PROJECT_DIR}/secrets/db_root_password.txt"

# srcs/
mkdir -p "${PROJECT_DIR}/srcs"
touch "${PROJECT_DIR}/srcs/docker-compose.yml"

# .env (как на скрине: в srcs/.env)
cat > "${PROJECT_DIR}/srcs/.env" <<EOF
DOMAIN_NAME=${DOMAIN}
CERT_=./requirements/tools/${DOMAIN}.crt
KEY_=./requirements/tools/${DOMAIN}.key
DB_NAME=wordpress
DB_ROOT=rootpass
DB_USER=wpuser
DB_PASS=wppass
EOF

# srcs/requirements/ + subfolders
mkdir -p "${PROJECT_DIR}/srcs/requirements"/{bonus,mariadb,nginx,tools,wordpress}

# ====== MariaDB ======
mkdir -p "${PROJECT_DIR}/srcs/requirements/mariadb"/{conf,tools}
touch "${PROJECT_DIR}/srcs/requirements/mariadb/Dockerfile"

cat > "${PROJECT_DIR}/srcs/requirements/mariadb/.dockerignore" <<'EOF'
.git
.env
EOF

touch "${PROJECT_DIR}/srcs/requirements/mariadb/conf/create_db.sh"
# optional: make it executable
chmod +x "${PROJECT_DIR}/srcs/requirements/mariadb/conf/create_db.sh"

# ====== NGINX ======
mkdir -p "${PROJECT_DIR}/srcs/requirements/nginx"/{conf,tools}
touch "${PROJECT_DIR}/srcs/requirements/nginx/Dockerfile"

cat > "${PROJECT_DIR}/srcs/requirements/nginx/.dockerignore" <<'EOF'
.git
.env
EOF

touch "${PROJECT_DIR}/srcs/requirements/nginx/conf/nginx.conf"

# ====== WordPress ======
mkdir -p "${PROJECT_DIR}/srcs/requirements/wordpress"/{conf,tools}
touch "${PROJECT_DIR}/srcs/requirements/wordpress/Dockerfile"

cat > "${PROJECT_DIR}/srcs/requirements/wordpress/.dockerignore" <<'EOF'
.git
.env
EOF

touch "${PROJECT_DIR}/srcs/requirements/wordpress/conf/wp-config-create.sh"
chmod +x "${PROJECT_DIR}/srcs/requirements/wordpress/conf/wp-config-create.sh"

# ====== Done ======
echo "✅ Structure created in: ${PROJECT_DIR}"
echo "Next: ls -alR ${PROJECT_DIR}"
