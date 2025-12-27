NAME            := inception
COMPOSE_FILE    := ./srcs/docker-compose.yml
ENV_FILE        := ./srcs/.env

COMPOSE         := docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)

all: up

up:
	$(COMPOSE) up -d

build:
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down --remove-orphans

re: down build

clean:
	$(COMPOSE) down --rmi local --remove-orphans

fclean:
	$(COMPOSE) down --rmi local --volumes --remove-orphans

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

help:
	@echo ""
	@echo "$(NAME) Makefile commands:"
	@echo ""
	@echo "  make up        - Start containers (docker compose up -d)"
	@echo "  make build     - Build images and start containers"
	@echo "  make down      - Stop containers"
	@echo "  make re        - Rebuild containers (down + build)"
	@echo "  make ps        - Show running containers"
	@echo "  make logs      - Show logs (follow mode)"
	@echo "  make clean     - Remove containers and local images"
	@echo "  make fclean    - Full cleanup (containers, images, volumes)"
	@echo "  make help      - Show this help message"
	@echo ""

.PHONY: all up build down re clean fclean ps logs help
