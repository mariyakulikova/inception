*This project has been created as part of the 42 curriculum by mkulikov.*

# Inception

## Description

**Inception** is a system administration and DevOps project from the 42 curriculum.
The goal of the project is to design and deploy a small infrastructure composed of multiple services using **Docker** and **Docker Compose**, following strict security and configuration rules.

The infrastructure includes:
- **Nginx** as a reverse proxy with TLS (SSL)
- **WordPress** running with **PHP-FPM**
- **MariaDB** as the database backend

Each service runs in its own Docker container and communicates with others through a dedicated Docker network.
All services are built from custom Dockerfiles (no pre-built images are used).

---

## Project Overview

The project simulates a real-world production-like setup:
- A custom domain name (`mkulikov.42.fr`)
- HTTPS-only access (TLS 1.2+)
- Persistent data storage using Docker volumes
- Secure management of sensitive data using Docker secrets
- Isolated services connected via a private Docker network

The architecture follows best practices for containerized environments and avoids common anti-patterns (such as running multiple services in a single container).

---

## Services

### Nginx
- Acts as the only entry point to the infrastructure
- Listens on port **443**
- Handles TLS termination
- Proxies PHP requests to the WordPress container

### WordPress
- Runs with **PHP-FPM**
- Connects to MariaDB over the Docker network
- Uses persistent storage for WordPress files

### MariaDB
- Stores WordPress data
- Uses a Docker volume for database persistence
- Credentials are managed via Docker secrets

---

## Instructions

[Dev documentation](DEV_DOC.md)



### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/mariyakulikova/inception.git
   cd inception
   ```

2. Project structure
   ```text
   ├── Makefile
   ├── secrets/
   └── srcs/
      ├── docker-compose.yml
      ├── .env
      └── requirements/
         ├── mariadb/
         │   ├── conf/
         │   │   └── 50-inception.cnf
         │   ├── Dockerfile
         │   └── tools/
         │       └── create_db.sh
         ├── nginx/
         │   ├── conf/
         │   │   └── nginx.conf
         │   ├── Dockerfile
         │   └── tools/
         │       └── gen_cert.sh
         ├── tools/
         └── wordpress/
               ├── conf/
               │   └── www.conf
               ├── Dockerfile
               └── tools/
                  └── wp-config-create.sh
   ```



3. Build and start infrestructure:
   ```bash
   make
   ```

