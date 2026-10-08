# Inception - User Documentation

## Overview

This project runs a WordPress website using three Docker containers:

- NGINX
- WordPress with PHP-FPM
- MariaDB

NGINX is the only public entry point and exposes HTTPS on port `443`.

Website:

```text
https://vmateos.42.fr
```

WordPress administration:

```text
https://vmateos.42.fr/wp-admin
```

Because the project uses a self-signed TLS certificate, the browser may display a security warning the first time the website is opened.

## Requirements

The project must be executed inside a virtual machine with:

- Docker
- Docker Compose
- Make

The domain must resolve locally to the machine running the project.

Example `/etc/hosts` entry:

```text
127.0.0.1 vmateos.42.fr
```

## Secrets

Before starting the infrastructure, create:

```text
secrets/db_password.txt
secrets/db_root_password.txt
secrets/wp_admin_password.txt
secrets/wp_user_password.txt
```

Each file must contain only the corresponding password.

Recommended permissions:

```bash
chmod 600 secrets/*.txt
```

The `secrets/` directory should not be committed to Git.

## Starting the project

From the repository root:

```bash
make
```

Check the running services:

```bash
docker compose -f srcs/docker-compose.yml ps
```

Expected services:

```text
mariadb
wordpress
nginx
```

## Stopping and restarting

Stop:

```bash
make down
```

Start again:

```bash
make up
```

Rebuild and restart:

```bash
make re
```

Remove containers, images and volumes:

```bash
make fclean
```

Warning: removing volumes deletes persistent WordPress and MariaDB data.

## Accessing WordPress

Open:

```text
https://vmateos.42.fr
```

If the browser shows a security warning, choose the advanced option and continue.

## WordPress administration

Open:

```text
https://vmateos.42.fr/wp-admin
```

The administrator username is configured with `WP_ADMIN_USER` in `srcs/.env`.

The administrator password is stored in:

```text
secrets/wp_admin_password.txt
```

The second WordPress user is configured with `WP_USER`, and its password is stored in:

```text
secrets/wp_user_password.txt
```

## Checking WordPress users

```bash
docker exec wordpress wp user list --allow-root
```

The expected result contains:

- one administrator
- one additional non-administrator user

## Checking services

MariaDB logs:

```bash
docker compose -f srcs/docker-compose.yml logs mariadb
```

WordPress logs:

```bash
docker compose -f srcs/docker-compose.yml logs wordpress
```

NGINX logs:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
```

## Persistent data

The project uses two named Docker volumes:

- MariaDB data
- WordPress files

Docker is configured to store its data under:

```text
/home/inception/data/docker
```

Stopping containers with `make down` does not delete persistent data.

## Troubleshooting

### Website does not open

Check:

```bash
docker compose -f srcs/docker-compose.yml ps
```

and verify that `vmateos.42.fr` exists in `/etc/hosts`.

### 502 Bad Gateway

Check the WordPress/PHP-FPM container:

```bash
docker compose -f srcs/docker-compose.yml logs wordpress
```

### WordPress cannot connect to the database

Check MariaDB:

```bash
docker compose -f srcs/docker-compose.yml logs mariadb
```

and verify the database values in `srcs/.env`.

### Docker daemon permission denied

Check whether your user belongs to the `docker` group:

```bash
groups
```

### Browser certificate warning

This is expected because the TLS certificate is self-signed.
