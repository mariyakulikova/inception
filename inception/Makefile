NAME      = inception
DOMAIN    = mkulikov.42.fr
HOSTS     = /etc/hosts
DC_YML    = ./srcs/docker-compose.yml

INTRANAME = mkulikov
DATA_DIR  = /home/$(INTRANAME)/data
MDB_DIR   = $(DATA_DIR)/mariadb
WP_DIR    = $(DATA_DIR)/wordpress

COMPOSE   = docker compose -p $(NAME) -f $(DC_YML)

define add_host
	sudo sed -i "\|^127\.0\.0\.1[[:space:]]\+$(1)$$|d" $(HOSTS)
	echo "127.0.0.1 $(1)" | sudo tee -a $(HOSTS) >/dev/null
endef

define del_host
	sudo sed -i "\|^127\.0\.0\.1[[:space:]]\+$(1)$$|d" $(HOSTS)
endef

.PHONY: up down clean prune re

up:
	sudo mkdir -p $(MDB_DIR) $(WP_DIR)
	$(call add_host,$(DOMAIN))
	$(COMPOSE) up -d --build

down:
	$(call del_host,$(DOMAIN))
	$(COMPOSE) down

clean:
	$(call del_host,$(DOMAIN))
	$(COMPOSE) down --rmi all -v
	sudo rm -rf $(MDB_DIR) $(WP_DIR)

prune: clean
	docker system prune -a --volumes -f

re: clean up
