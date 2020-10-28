# This container should be used for any/all CLI processes
# including cron, queues, etc.
FROM php:7.4.11-fpm-alpine3.12

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
