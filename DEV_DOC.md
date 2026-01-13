## Installation

### Requirements
- Docker
- Docker Compose
- Linux environment (Debian-based VM recommended, as required by the subject)
- GNU Make
- sudo privileges

### Setup

This project requires a specific environment setup before running the containers.
All sensitive data must be stored outside of the Git repository.

#### Secrets directory
A directory named `secrets` must exist in the user's `$HOME` directory.
Each secret must be stored in a **separate file**, containing **only the password** (no extra spaces or newlines).

| **File name**    | **Description** |
| :--------------- |:----------------|
| `db_root_pass.txt` | MariaDB root password |
| `db_user_pass.txt` | MariaDB user password |
| `wp_admin_pass.txt` | WordPress admin password |
| `wp_user_pass.txt` | WordPress regular user password |

Example:
```bash
mkdir -p $HOME/secrets
echo "strong_root_password" > $HOME/secrets/db_root_pass.txt
echo "strong_db_password"   > $HOME/secrets/db_user_pass.txt
echo "strong_admin_pass"    > $HOME/secrets/wp_admin_pass.txt
echo "strong_user_pass"     > $HOME/secrets/wp_user_pass.txt
```

#### Environment variables

A .env file must be created in the user's $HOME directory.

Example .env file:
```text
INTRANAME=mkulikov
DOMAIN_NAME=mkulikov.42.fr

DB_NAME=wordpress
DB_USER=wpuser
DB_HOST=mariadb

WP_ADMIN_USER=mkulikov
WP_ADMIN_EMAIL=mkulikov@student.42berlin.de

WP_USER=regular
WP_USER_EMAIL=regular@example.com
WP_USER_ROLE=subscriber

WP_TITLE=Inception
```

This file defines:
  - service configuration
  - database connection settings
  - WordPress users and metadata

#### Host configuration

The domain name resolution is handled **automatically by the Makefile**.

When running:

```bash
make
```

the Makefile adds the required entry to /etc/hosts: `127.0.0.1 <intraname>.42.fr`

## Build and run project

The project is managed using a `Makefile`, which provides convenient shortcuts
for building, running, and cleaning the Docker infrastructure.

### Makefile commands

| Command        | Description |
|----------------|-------------|
| `make` | Copy environment files, prepare secrets, build and start all containers |
| `make down`    | Stop containers and remove Docker network |
| `make clean`   | Stop containers and remove copied `.env` and secrets |
| `make fclean`  | Full cleanup: remove containers, images, volumes, and data directories |
| `make prune`   | Remove all unused Docker data (containers, images, volumes) |
| `make re`      | Fully rebuild the project from scratch |

### Docker Compose (manual commands)

All services are defined in `srcs/docker-compose.yml`.

Build and start containers:

```bash
docker compose -f srcs/docker-compose.yml up --build
```

Stop containers:

```bash
docker compose -f srcs/docker-compose.yml down
```

Stop containers and remove volumes:

```bash
docker compose -f srcs/docker-compose.yml down -v
```

### Useful Docker commands

Check running containers:

```bash
docker ps
```

List Docker volumes:

```bash
docker volume ls
```

Inspect a volume:

```bash
docker volume inspect <volume_name>
```

Access a container shell:

```bash
docker exec -it <container_name> bash
```

Check container logs:

```bash
docker logs <container_name>
```

## Verification

Once the containers are running, the website should be accessible at:

```text
https://mkulikov.42.fr
```

Test HTTPS connection:
```bash
curl -k https://mkulikov.42.fr
```

Verify database connection:

```bash
docker exec -it mariadb mariadb -u root -p
```
