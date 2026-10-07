#!/bin/bash

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

if [ ! -f "/var/lib/mysql/.inception_initialized" ]; then

	if [ ! -d "/var/lib/mysql/mysql" ]; then
		mariadb-install-db --user=mysql --datadir=/var/lib/mysql

	fi

	mysqld --user=mysql --skip-networking &

	until mysqladmin ping --silent; do
		sleep 1
	done

	mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
	mysql -u root -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
	mysql -u root -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
	mysql -u root -e "FLUSH PRIVILEGES;"
	mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
	mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

	touch /var/lib/mysql/.inception_initialized
fi


exec mysqld --user=mysql
