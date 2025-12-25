FROM debian:12-slim

RUN apt-get update && apt-get install -y nginx openssl \
  && rm -rf /var/lib/apt/lists/*

RUN rm -f /etc/nginx/sites-enabled/default

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/gen_cert.sh /usr/local/bin/gen_cert.sh
RUN chmod +x /etc/nginx/nginx.conf
RUN chmod +x /usr/local/bin/gen_cert.sh

EXPOSE 80 443

ENTRYPOINT ["/usr/local/bin/gen_cert.sh"]

CMD ["nginx", "-g", "daemon off;"]
