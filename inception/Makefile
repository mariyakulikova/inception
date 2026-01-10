NAME      = inception
DOMAIN    = mkulikov.42.fr
HOSTS     = /etc/hosts
DC_YML    = ./srcs/docker-compose.yml

INTRANAME = mkulikov
DATA_DIR  = /home/$(INTRANAME)/data
MDB_DIR   = $(DATA_DIR)/mariadb
WP_DIR    = $(DATA_DIR)/wordpress

COMPOSE   = docker compose -p $(NAME) -f $(DC_YML)

SECRETS_SRC = $(HOME)/secrets

ENV_SRC = $(HOME)/.env
ENV_DST = srcs/.env

SECRETS_DST = srcs/secrets
SECRET_FILES = \
	db_root_pass.txt \
	db_user_pass.txt \
	wp_admin_pass.txt \
	wp_user_pass.txt

define add_host
	sudo sed -i "\|^127\.0\.0\.1[[:space:]]\+$(1)$$|d" $(HOSTS)
	echo "127.0.0.1 $(1)" | sudo tee -a $(HOSTS) >/dev/null
endef

define del_host
	sudo sed -i "\|^127\.0\.0\.1[[:space:]]\+$(1)$$|d" $(HOSTS)
endef

.PHONY: all up down clean fclean prune re copy_env copy_secrets check_local

all: up

check_local:
	@if [ ! -d "$(SECRETS_SRC)" ]; then \
		echo "❌ Missing directory: $(SECRETS_SRC)"; \
		exit 1; \
	fi

copy_env: check_local
	@if [ ! -f "$(ENV_SRC)" ]; then \
		echo "❌ Missing: $(ENV_SRC)"; \
		exit 1; \
	fi
	cp "$(ENV_SRC)" "$(ENV_DST)"

copy_secrets: check_local
	@mkdir -p "$(SECRETS_DST)"
	@set -e; \
	for f in $(SECRET_FILES); do \
		if [ ! -f "$(SECRETS_SRC)/$$f" ]; then \
			echo "❌ Missing: $(SECRETS_SRC)/$$f"; \
			exit 1; \
		fi; \
		cp "$(SECRETS_SRC)/$$f" "$(SECRETS_DST)/$$f"; \
	done
	@chmod 600 "$(SECRETS_DST)"/*

up: copy_env copy_secrets
	sudo mkdir -p $(MDB_DIR) $(WP_DIR)
	$(call add_host,$(DOMAIN))
	$(COMPOSE) up -d --build

down:
	$(call del_host,$(DOMAIN))
	$(COMPOSE) down

clean: down
	rm -f "$(ENV_DST)"
	rm -rf "$(SECRETS_DST)"

fclean: down
	$(COMPOSE) down --rmi all -v
	sudo rm -rf $(MDB_DIR) $(WP_DIR)
	rm -f "$(ENV_DST)"
	rm -rf "$(SECRETS_DST)"

prune: clean
	docker system prune -a --volumes -f

re: fclean up
