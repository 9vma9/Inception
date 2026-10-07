FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	nginx \
	openssl \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes \
	-out /etc/nginx/ssl/inception.crt \
	-keyout /etc/nginx/ssl/inception.key \
	-subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=42/CN=inception.42.fr"

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

RUN rm -f /etc/nginx/sites-enabled/default

CMD ["nginx", "-g", "daemon off;"]
