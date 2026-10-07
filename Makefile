COMPOSE = docker compose -f srcs/docker-compose.yml

all:
	$(COMPOSE) up --build -d

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

re:
	$(COMPOSE) down
	$(COMPOSE) up --build -d

clean:
	$(COMPOSE) down

fclean:
	$(COMPOSE) down -v --rmi all --remove-orphans

.PHONE: all up down re clean fclean
