FROM debian:12-slim

RUN apt-get update && apt-get install -y \
    php-fpm php-mysql \
    curl ca-certificates \
    mariadb-client \
    unzip \
  && curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
       -o /usr/local/bin/wp \
  && chmod +x /usr/local/bin/wp \
  && rm -rf /var/lib/apt/lists/*

RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/*/fpm/pool.d/www.conf \
 && mkdir -p /run/php

RUN mkdir -p /var/www/html
WORKDIR /var/www/html

COPY conf/wp-config-create.sh /usr/local/bin/wp-config-create.sh
RUN chmod +x /usr/local/bin/wp-config-create.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp-config-create.sh"]
CMD ["php-fpm8.2", "-F"]
