# This container should be used for any/all CLI processes
# including cron, queues, etc.
FROM php:8.1.3-fpm-alpine3.15

WORKDIR /var/www/html

ADD install_composer.php /var/www/html/install_composer.php

RUN apk add --update --no-cache \
        # see https://github.com/docker-library/php/issues/880
        oniguruma-dev \
        # needed for composer
        libzip-dev git zip unzip \
        # needed for spatie/laravel-backup
        mysql-client \
        # needed for gd
        libpng-dev libjpeg-turbo-dev \
        # needed for Laravel horizon - https://github.com/laravel/horizon/issues/597#issuecomment-495198884
        procps \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    # Installing composer
    && php /var/www/html/install_composer.php \
    # Installing common Laravel dependencies
    && docker-php-ext-install mbstring pdo_mysql gd \
        # needed for forking processes in laravel queues as of Laravel 5.3
        pcntl \
        # needed for https://github.com/spatie/laravel-backup
        zip \
    && mkdir -p /home/www-data/.composer/cache \
    && chown -R www-data:www-data /home/www-data/ /var/www/html \
    # Setup the crontab, only activated if the container's command is configured for cron
    && echo "*       *       *       *       *       php /var/www/html/artisan schedule:run" > /etc/crontabs/www-data

RUN apk add --update --no-cache make g++ cairo-dev libpng-dev zlib-dev libzip-dev \
    #&& docker-php-ext-configure zip --with-libzip \
    # Using Laravel Horizon requires this extension to be installed
    # We really only need it on the cli container, but composer fails
    # if we don't include it here as well
    # zip is the same way with Laravel Dusk
    && docker-php-ext-install pcntl zip