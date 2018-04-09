# This container should be used for any/all CLI processes
# including cron, queues, etc.
FROM php:7.2.4-alpine3.7

WORKDIR /var/www/html

ADD install_composer.php /var/www/html/install_composer.php

RUN apk add --update --no-cache \

        # needed for composer
        git zip unzip \

        # needed for spatie/laravel-backup
        mysql-client \

        # needed for gd
        libpng-dev libjpeg-turbo-dev \

    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \

    # Installing composer
    && php /var/www/html/install_composer.php \

    # Installing common Laravel dependencies
    && docker-php-ext-install mbstring pdo_mysql gd \

        # needed for forking processes in laravel queues as of Laravel 5.3
        pcntl \

        # needed for https://github.com/spatie/laravel-backup
        zip \

    # For parallel composer dependency installs
    && composer global require hirak/prestissimo \

    && mkdir -p /home/www-data/.composer/cache \

    && chown -R www-data:www-data /home/www-data/ /var/www/html \

    # Setup the crontab, only activated if the container's command is configured for cron
    && echo "*       *       *       *       *       php /var/www/html/artisan schedule:run" > /etc/crontabs/www-data
