## User Documentation

This document explains how to use the Inception project as an **end user or
administrator**.
It describes the provided services, how to start and stop the project, how to
access the website and administration panel, and how to verify that everything
is running correctly.

---

### 1. Provided services

The project provides a small web infrastructure composed of the following
services:

- **Nginx**
  - Acts as a web server and reverse proxy
  - Handles HTTPS (TLS encryption)
  - Is the only service exposed to the outside

- **WordPress**
  - Content management system (CMS)
  - Serves the website content
  - Provides an administration panel for managing the site

- **MariaDB**
  - Database service
  - Stores WordPress content, users, and configuration
  - Is not directly accessible from outside

All services run in separate Docker containers and communicate through an
internal Docker network.

---

### 2. Starting and stopping the project

The project is controlled using a `Makefile`.

#### Start the project

`make` command:
- prepares configuration files and secrets
- builds the Docker images
- starts all services in the background
From the root of the project, run:

```bash
make
```

#### Stop the project

`make down` stops the containers
From the root of the project, run:

```bash
make down
```

#### Accessing the website

Once the project is running, the website is avaliable at `https://mkulikov.42.fr`

#### Accessing the administration panel
The WordPress administration panel is avaliable at `https://mkulikov.42.fr/wp-admin`

#### MariaDB

Connect to the MariaDB container:
```bash
docker exec -it mariadb mariadb -u root -p
```

Show databases:
```bash
SHOW DATABASES;
```

Select the WordPress database:
```bash
USE wordpress;
```

List tables:
```bash
SHOW TABLES;
```

Display table content:
```bash
SELECT * FROM <table>;
```


