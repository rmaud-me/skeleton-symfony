FROM dunglas/frankenphp:1-php8.5 AS frankenphp_upstream

FROM frankenphp_upstream AS bebou_php_base

WORKDIR /srv

# Update package list and install system dependencies
# libcap2-bin Needed for rootless
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
	acl \
	git \
	file \
	gettext \
	libcap2-bin \
    && rm -rf /var/lib/apt/lists/* \
	;

RUN set -eux; \
    install-php-extensions @composer zip intl apcu opcache gd redis \
    ;

COPY --link .docker/frankenphp/conf.d/10-app.ini $PHP_INI_DIR/conf.d/
COPY --link --chmod=755 .docker/frankenphp/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
COPY --link .docker/frankenphp/Caddyfile /etc/frankenphp/Caddyfile

ENTRYPOINT ["docker-entrypoint"]

HEALTHCHECK --start-period=90s --interval=10s --timeout=5s --retries=5 CMD curl -f http://localhost:2019/metrics || exit 1

CMD [ "frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile" ]

FROM bebou_php_base AS bebou_php_dev

ENV FRANKENPHP_WORKER_CONFIG=watch

VOLUME /srv/var

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN set -eux; \
	install-php-extensions xdebug \
    ;

COPY --link .docker/frankenphp/conf.d/20-app.dev.ini $PHP_INI_DIR/conf.d/

# Uncomment if you want rootless container
# CAP_FOWNER+ep /usr/bin/setfacl instruction authorize appuser to use setfacl
RUN adduser --disabled-password --gecos "" appuser \
    && chown -R appuser /srv /config/caddy /data/caddy \
    && setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp \
    && setcap CAP_FOWNER+ep /usr/bin/setfacl \
    ;

CMD [ "frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile", "--watch" ]

USER appuser

FROM bebou_php_base AS bebou_php_prod

ENV APP_ENV=prod

# Uncomment if you want rootless container
# CAP_FOWNER+ep /usr/bin/setfacl instruction authorize appuser to use setfacl
RUN adduser --disabled-password --gecos "" appuser \
    && chown -R appuser /srv /config/caddy /data/caddy \
    && setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp \
    && setcap CAP_FOWNER+ep /usr/bin/setfacl \
    ;

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY --link .docker/frankenphp/conf.d/20-app.prod.ini $PHP_INI_DIR/conf.d/

# prevent the reinstallation of vendors at every changes in the source code
COPY --link ./composer.* ./symfony.* ./

RUN set -eux; \
    composer install --no-cache --prefer-dist --no-dev --no-autoloader --no-scripts --no-progress

# copy sources
COPY --link . ./

RUN set -eux; \
	mkdir -p var/cache var/log; \
	composer dump-autoload --classmap-authoritative --no-dev; \
	composer dump-env prod; \
	composer run-script --no-dev post-install-cmd; \
	chmod +x bin/console; sync;

###> Build assets ###
RUN set -eux; \
    bin/console importmap:install; \
    bin/console asset-map:compile;
###< Build assets ###

USER appuser
