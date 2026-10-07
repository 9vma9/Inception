FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	php-fpm \
	php-mysql \
	mariadb-client \
	curl \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

COPY tools/setup_wordpress.sh /usr/local/bin/setup_wordpress.sh

RUN chmod +x /usr/local/bin/setup_wordpress.sh

RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

ENTRYPOINT ["/usr/local/bin/setup_wordpress.sh"]
