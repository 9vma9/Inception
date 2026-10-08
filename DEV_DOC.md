# Inception - Developer Documentation

## Architecture

The infrastructure contains three services:

```text
Browser
   |
 HTTPS :443
   |
 NGINX
   |
 FastCGI :9000
   |
 WordPress + PHP-FPM
   |
 MariaDB :3306
```

Each service runs in its own Docker container and communicates through a dedicated Docker bridge network.

## Project structure

```text
Inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── .gitignore
├── secrets/
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── 60-inception.cnf
        │   └── tools/
        │       └── init_db.sh
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── nginx.conf
        └── wordpress/
            ├── Dockerfile
            └── tools/
                └── setup_wordpress.sh
```

## Docker Compose

The infrastructure is defined in:

```text
srcs/docker-compose.yml
```

It defines:

- `mariadb`
- `wordpress`
- `nginx`
- the `inception` network
- the MariaDB named volume
- the WordPress named volume
- Docker secrets

Only NGINX exposes a host port:

```text
443:443
```

MariaDB and WordPress are only reachable through the internal Docker network.

## MariaDB

The MariaDB image is built from:

```text
srcs/requirements/mariadb/Dockerfile
```

The container installs `mariadb-server`.

Configuration:

```text
srcs/requirements/mariadb/conf/60-inception.cnf
```

MariaDB listens on:

```text
0.0.0.0:3306
```

Startup script:

```text
srcs/requirements/mariadb/tools/init_db.sh
```

The script:

1. reads passwords from Docker secrets
2. prepares MariaDB directories and permissions
3. initializes MariaDB if required
4. creates the WordPress database
5. creates the WordPress database user
6. grants privileges
7. sets the root password
8. starts `mysqld` as the main process

The WordPress database user is created for host `%` so it can connect from another container.

## WordPress

The WordPress image is built from:

```text
srcs/requirements/wordpress/Dockerfile
```

It installs:

- PHP-FPM
- PHP MySQL support
- MariaDB client
- curl
- CA certificates
- WP-CLI

PHP-FPM listens on:

```text
9000
```

Startup script:

```text
srcs/requirements/wordpress/tools/setup_wordpress.sh
```

The script:

1. reads Docker secrets
2. downloads WordPress if necessary
3. creates `wp-config.php`
4. connects WordPress to `mariadb:3306`
5. installs WordPress automatically if needed
6. creates the administrator user
7. creates the second WordPress user
8. starts PHP-FPM in foreground mode

WP-CLI is installed during the image build so it remains available when an existing WordPress volume is reused.

## NGINX

The NGINX image is built from:

```text
srcs/requirements/nginx/Dockerfile
```

It installs:

- NGINX
- OpenSSL

A self-signed TLS certificate is generated during the image build.

Configuration:

```text
srcs/requirements/nginx/conf/nginx.conf
```

NGINX:

- listens on port `443`
- uses TLS
- serves WordPress files from `/var/www/html`
- forwards PHP requests to `wordpress:9000`

The default Debian NGINX site is removed.

## Docker network

The project defines a dedicated bridge network named:

```text
inception
```

All three containers are connected to it.

Docker DNS lets services communicate using service names:

```text
wordpress -> mariadb:3306
nginx -> wordpress:9000
```

No host networking is used.

## Volumes and persistence

The project uses two named volumes:

```text
mariadb_data
wordpress_data
```

Mount points:

```text
mariadb_data   -> /var/lib/mysql
wordpress_data -> /var/www/html
```

Docker's data root is configured as:

```text
/home/inception/data/docker
```

This keeps persistent application data outside the lifetime of individual containers.

## Environment variables

Non-sensitive configuration is stored in:

```text
srcs/.env
```

Examples:

```text
DOMAIN_NAME
MYSQL_DATABASE
MYSQL_USER
WP_TITLE
WP_ADMIN_USER
WP_ADMIN_EMAIL
WP_USER
WP_USER_EMAIL
```

Passwords are not stored in `.env`.

## Docker secrets

Sensitive values are stored locally under:

```text
secrets/
```

Current secret files:

```text
db_password.txt
db_root_password.txt
wp_admin_password.txt
wp_user_password.txt
```

Docker Compose exposes them inside containers under:

```text
/run/secrets/
```

The `secrets/` directory is ignored by Git.

## Makefile

Main targets:

```text
make        build and start
make up     start
make down   stop
make re     rebuild and restart
make clean  stop
make fclean remove containers, images and volumes
```

The Makefile uses:

```text
srcs/docker-compose.yml
```

## Building

From the repository root:

```bash
make
```

## Rebuilding one service

WordPress:

```bash
docker compose -f srcs/docker-compose.yml up --build -d wordpress
```

NGINX:

```bash
docker compose -f srcs/docker-compose.yml up --build -d nginx
```

## Logs

All services:

```bash
docker compose -f srcs/docker-compose.yml logs
```

Individual services:

```bash
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
docker compose -f srcs/docker-compose.yml logs nginx
```

## Validation commands

Containers:

```bash
docker compose -f srcs/docker-compose.yml ps
```

Networks:

```bash
docker network ls
```

Volumes:

```bash
docker volume ls
```

WordPress users:

```bash
docker exec wordpress wp user list --allow-root
```

WP-CLI:

```bash
docker exec wordpress wp --info --allow-root
```

NGINX configuration:

```bash
docker exec nginx nginx -t
```

## Recreating the project on a new VM

1. Clone the repository.
2. Install Docker, Docker Compose and Make.
3. Recreate the required files inside `secrets/`.
4. Configure `/etc/hosts` so `vmateos.42.fr` resolves locally.
5. Configure Docker's data root under `/home/inception/data/docker` if needed.
6. Restart Docker.
7. Run:

```bash
make
```

8. Verify:

```bash
docker compose -f srcs/docker-compose.yml ps
```

9. Open:

```text
https://vmateos.42.fr
```
