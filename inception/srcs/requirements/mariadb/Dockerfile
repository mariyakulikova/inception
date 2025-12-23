FROM debian:12-slim

RUN apt-get update && apt-get install -y mariadb-server \
	&& rm -rf /var/lib/apt/lists/*

RUN sed -i 's/^bind-address[[:space:]]*=.*/bind-address = 0.0.0.0/' \
	/etc/mysql/mariadb.conf.d/50-server.cnf

COPY conf/create_db.sh /usr/local/bin/create_db.sh
RUN chmod +x /usr/local/bin/create_db.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/create_db.sh"]
CMD ["mysqld_safe"]
