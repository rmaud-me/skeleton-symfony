# Skeleton Symfony

This project allow to have a template with minimal 

## Requirement

- [Make](https://www.gnu.org/software/make/)

## Init

### 1. Search and replace
Search and replace all skeleton, skeleton-* and skeleton_* words by the right value except on this file

### 2. Docker
Change the name of each target on Dockerfile to fit with your project name

### 3. Docker compose

* Change build target in compose files
* Change container name of each service
* In `traefik.http.routers.nginx.rule=Host` label, replace `webapp-skeleton.localhost` by the url you want. The format value need to match with this pattern `your-value.localhost` on nginx service
* In `traefik.http.routers.maildev.rule=Host` label, replace `webapp-skeleton-mail.localhost` by the url you want. The format value need to match with this pattern `your-value.localhost` on maildev service
* Foreach traefik label, change the name of service (e.g. `nginx`) on each service that use traefik.
* You can personalize each service name in the docker compose files.

### 4. Init

Run :
```bash
make init
```
