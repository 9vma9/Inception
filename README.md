*This project has been created as part of the 42 curriculum by vmateos.*

# Inception

## Description

Inception is a system administration project focused on Docker and containerization.

The goal of the project is to build a small infrastructure composed of several services, each running in its own Docker container.

The mandatory stack includes:

- NGINX with TLSv1.2
- WordPress with PHP-FPM
- MariaDB
- A dedicated Docker network
- A persistent volume for the WordPress files
- A persistent volume for the MariaDB database

NGINX is the only entry point to the infrastructure and exposes port 443.

The architecture is:

```text
Browser
   |
 HTTPS :443
   |
 NGINX
   |
 PHP-FPM :9000
   |
 WordPress
   |
 MariaDB :3306
```

## Project structure

```text
Inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        ├── wordpress/
        └── mariadb/
```

## Instructions

The project must be executed inside a virtual machine with Docker and Docker Compose installed.

Build and start the infrastructure:

```bash
make
```

Stop the containers:

```bash
make down
```

Start existing containers:

```bash
make up
```

Rebuild the project:

```bash
make re
```

Remove containers, images and volumes:

```bash
make fclean
```

The website is available at:

```text
https://vmateos.42.fr
```

The WordPress administration panel is available at:

```text
https://vmateos.42.fr/wp-admin
```

## Docker vs Virtual Machines

A virtual machine emulates a complete computer and runs its own operating system and kernel.

Docker containers share the host kernel and isolate applications and their dependencies.

Virtual machines are generally heavier and require more resources, while containers are lighter and faster to create and start.

In this project, Docker runs inside a virtual machine.

## Secrets vs Environment Variables

Environment variables are useful for storing non-sensitive configuration values such as:

- domain name
- database name
- usernames
- WordPress site configuration

Docker secrets are used for sensitive information such as passwords.

This project stores passwords in files inside the `secrets/` directory, which is ignored by Git.

## Docker Network vs Host Network

A Docker network allows containers to communicate with each other while remaining isolated from the host network.

The containers in this project communicate through the `inception` bridge network.

Examples:

```text
wordpress -> mariadb:3306
nginx -> wordpress:9000
```

Using the host network would reduce isolation and is forbidden by the project requirements.

## Docker Volumes vs Bind Mounts

Docker volumes are managed by Docker and provide persistent storage independently of the lifetime of a container.

Bind mounts directly expose a host directory inside a container.

This project uses named Docker volumes for:

- MariaDB data
- WordPress files

The Docker storage directory is configured under:

```text
/home/inception/data
```

This allows the application data to persist even when containers are stopped or recreated.

## Security

The infrastructure follows several security rules:

- Only port 443 is exposed.
- NGINX uses TLS.
- Passwords are not stored inside Dockerfiles.
- Sensitive credentials are stored using Docker secrets.
- The `secrets/` directory is ignored by Git.
- MariaDB is not exposed directly to the host.
- WordPress communicates with MariaDB through the internal Docker network.

## Resources

Resources used during the project include:

- Docker documentation
- Docker Compose documentation
- NGINX documentation
- MariaDB documentation
- WordPress documentation
- WP-CLI documentation
- Debian documentation

## Use of AI

AI tools were used as a learning and debugging aid during the project.

They were used to:

- explain Docker concepts
- understand Dockerfiles and Docker Compose
- debug configuration and networking errors
- understand NGINX, MariaDB and PHP-FPM configuration

All generated suggestions were reviewed, tested and adapted before being included in the project.
