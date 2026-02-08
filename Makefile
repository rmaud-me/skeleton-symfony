##
## Command to init new git project from webapp-skeleton.
##--------
init:
	rm Makefile
	mv Makefile.sample Makefile
	rm README.md
	mv README.md.sample README.md

.PHONY : clean

test:
	docker compose down --remove-orphans -v --rmi all
	rm -f ./.env.local -f ./docker.env.local -f .docker/data/history
	sudo rm -rf ./var ./vendor

	cp -n .env .env.local && cp -n docker.env docker.env.local && cp -n .docker/data/history.dist .docker/data/history

	docker compose up -d --build --wait
