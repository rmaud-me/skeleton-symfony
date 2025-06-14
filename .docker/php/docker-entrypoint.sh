#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
    set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ] || [ "$1" = 'php' ] || [ "$1" = 'bin/console' ]; then
    if [ "$APP_ENV" != 'prod' ]; then
        if [ -d .git ]; then
            git config --global --add safe.directory /srv
        fi

        # Composer install needed in dev only because vendor not exist before and needed for the next step.
        composer install --prefer-dist --no-progress --no-interaction --no-scripts
    fi

    setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX var
    setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX var

    if grep -q ^DATABASE_URL= .env; then
        echo "Waiting for database to be ready..."
        ATTEMPTS_LEFT_TO_REACH_DATABASE=60
        until [ $ATTEMPTS_LEFT_TO_REACH_DATABASE -eq 0 ] || DATABASE_ERROR=$(php bin/console dbal:run-sql -q "SELECT 1" 2>&1); do
            if [ $? -eq 255 ]; then
                # If the Doctrine command exits with 255, an unrecoverable error occurred
                ATTEMPTS_LEFT_TO_REACH_DATABASE=0
                break
            fi
            sleep 1
            ATTEMPTS_LEFT_TO_REACH_DATABASE=$((ATTEMPTS_LEFT_TO_REACH_DATABASE - 1))
            echo "Still waiting for database to be ready... Or maybe the database is not reachable. $ATTEMPTS_LEFT_TO_REACH_DATABASE attempts left."
        done

        if [ $ATTEMPTS_LEFT_TO_REACH_DATABASE -eq 0 ]; then
            echo "The database is not up or not reachable:"
            echo "$DATABASE_ERROR"
            exit 1
        else
            echo "The database is now ready and reachable"
        fi

        if [ "$(find ./migrations -iname '*.php' -print -quit)" ]; then
            php bin/console doctrine:migrations:migrate --no-interaction
        fi
    fi
fi

exec docker-php-entrypoint "$@"
