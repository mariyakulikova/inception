FROM debian:12-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends mariadb-server mariadb-client \
  && rm -rf /var/lib/apt/lists/*

COPY conf/50-inception.cnf /etc/mysql/mariadb.conf.d/99-inception.cnf

COPY tools/create_db.sh /usr/local/bin/create_db.sh
RUN chmod +x /usr/local/bin/create_db.sh

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/create_db.sh"]
CMD ["mariadbd", "--user=mysql", "--datadir=/var/lib/mysql"]
