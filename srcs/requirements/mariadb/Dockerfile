FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	mariadb-server \
	&& rm -rf /var/lib/apt/lists/*

COPY conf/60-inception.cnf /etc/mysql/mariadb.conf.d/60-inception.cnf

COPY tools/init_db.sh /usr/local/bin/init_db.sh

RUN chmod +x /usr/local/bin/init_db.sh

ENTRYPOINT ["/usr/local/bin/init_db.sh"]
