FROM php:8.5-fpm AS skeleton_php_base

WORKDIR /srv

VOLUME /srv/var

# Update package list and install system dependencies
# libcap2-bin remove it if you do not want rootless
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
	acl \
	git \
	file \
	gettext \
	libcap2-bin \
    && rm -rf /var/lib/apt/lists/* \
	;

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN set -eux; \
    install-php-extensions @composer zip intl pdo_pgsql apcu opcache \
    ;

COPY --link .docker/php/conf.d/10-app.ini $PHP_INI_DIR/conf.d/

COPY --link --chmod=755 .docker/php/docker-healthcheck.sh /usr/local/bin/docker-healthcheck
HEALTHCHECK --start-period=1m CMD docker-healthcheck

COPY --link --chmod=755 .docker/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]

FROM skeleton_php_base AS skeleton_php_dev

COPY --link .docker/php/conf.d/20-app.dev.ini $PHP_INI_DIR/conf.d/

RUN set -eux; \
	install-php-extensions xdebug \
    ;

# Comment if you do not want rootless container
## CAP_FOWNER+ep /usr/bin/setfacl instruction authorize appuser to use setfacl
RUN adduser --disabled-password --gecos "" appuser \
    && chown -R appuser /srv \
    && setcap CAP_FOWNER+ep /usr/bin/setfacl \
    ;

# Comment if you do not want rootless container
USER appuser

FROM skeleton_php_dev AS skeleton_php_prod

ENV APP_ENV=prod

# Comment if you do not want rootless container
## CAP_FOWNER+ep /usr/bin/setfacl instruction authorize appuser to use setfacl
RUN adduser --disabled-password --gecos "" appuser \
    && chown -R appuser /srv \
    && setcap CAP_FOWNER+ep /usr/bin/setfacl \
    ;

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY --link .docker/php/conf.d/20-app.prod.ini $PHP_INI_DIR/conf.d/

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
#RUN set -eux; \
#    bin/console importmap:install; \
#    bin/console asset-map:compile;
###< Build assets ###

# Comment if you do not want rootless container
USER appuser

FROM nginx:1.29-alpine AS skeleton_nginx

COPY --link .docker/nginx/nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=skeleton_php_prod --link /srv/public /srv/public

CMD ["/bin/sh" , "-c" , "exec nginx -g 'daemon off;'"]
