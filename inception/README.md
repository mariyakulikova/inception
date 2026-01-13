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

### Virtual Machines vs Docker

**Virtual Machines**
- Include a full guest operating system
- Require more system resources
- Have slower startup times

**Docker**
- Shares the host OS kernel
- Is lightweight and fast
- Allows services to be isolated at the process level

Docker was chosen because it provides efficient resource usage, fast startup,
and better suitability for a multi-service architecture.

### Secrets vs Environment Variables

**Environment Variables**
- Are visible through container inspection
- Can be accidentally exposed in logs or debug output

**Docker Secrets**
- Are stored securely by Docker
- Are mounted as read-only files
- Are not exposed through container metadata

For this project, Docker secrets are used to store all sensitive data such as
database and WordPress passwords.

### Docker Network vs Host Network

**Host Network**
- Containers share the host network stack
- Reduces isolation
- Increases security risks

**Docker Network**
- Provides an isolated internal network
- Allows containers to communicate using service names
- Improves security and separation of concerns

A dedicated Docker bridge network is used to isolate the services from the host
network and from external access.

### Docker Volumes vs Bind Mounts

**Bind Mounts**
- Depend on specific host filesystem paths
- Are less portable
- Can cause permission issues

**Docker Volumes**
- Are managed by Docker
- Are portable and persistent
- Are safer for storing application data

Docker volumes are used to persist MariaDB and WordPress data while keeping the
infrastructure portable and reproducible.

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

- Installation and setup: [DEV_DOC.md](DEV_DOC.md)
- Execution and usage: [USER_DOC.md](USER_DOC.md)

## Resources

- [Docker documentation](https://docs.docker.com)
- [Docker Compose documentation](https://docs.docker.com/compose)
- [Nginx documentation](https://nginx.org/en/docs)
- [WordPress documentation](https://wordpress.org/support/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)

## AI usage

- explaining unfamiliar technologies, tools, and terminology
- providing high-level guidance on architecture
- comparing alternative technical solutions and their trade-offs
- suggesting best practices for security, networking, and data persistence
- assisting with troubleshooting and debugging by helping analyze error messages
- rephrasing technical content to improve readability
