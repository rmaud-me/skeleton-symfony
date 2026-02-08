##
## Command to init new git project from webapp-skeleton.
##--------
init:
	rm Makefile
	mv Makefile.sample Makefile
	rm README.md
	mv README.md.sample README.md

# This command allow to check if the skeleton build correctly
install:
	cp -n .env .env.local && cp -n docker.env docker.env.local && cp -n .docker/data/history.dist .docker/data/history

	docker compose up -d --build --wait
