
COMPOSE = docker-compose

.DEFAULT_GOAL= test
.PHONY: test database apex clean image build 


image: build
	$(COMPOSE) build

database: 
	$(COMPOSE) up -d oradb

apex: 
	$(COMPOSE) run --rm apex /opt/oracle/apex/install_apex.sh
	$(COMPOSE) up 


clean: 
	$(COMPOSE) stop  
	$(COMPOSE) rm


test: 
	$(MAKE) database
	sleep 60
	$(MAKE) apex