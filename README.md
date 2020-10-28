# PHP

[![Build Status](https://travis-ci.org/bkuhl/php.svg?branch=master)](https://travis-ci.org/bkuhl/php)
[![Docker Pulls](https://img.shields.io/docker/pulls/bkuhl/php.svg)](https://hub.docker.com/r/bkuhl/php)

This container is intended to run Laravel application's queues, cron, etc. and thus comes with a few items to assist:

 * [Composer](https://getcomposer.org)
 * PHP Extensions
   * [mbstring](http://php.net/manual/en/book.mbstring.php)
   * [pdo_mysql](http://php.net/manual/en/ref.pdo-mysql.php)
   * [gd](http://php.net/manual/en/book.image.php)
   * [pcntl](http://php.net/manual/en/book.pcntl.php) (Required for queue workers as of Laravel 5.3)
   
**[spatie/laravel-backup Dependencies](https://github.com/spatie/laravel-backup)**
 * PHP extension [zip](http://php.net/manual/en/book.zip.php)
 * `mysql-client` for `mysqldump` support
 
For a container to run nginx/fpm for Laravel applications,  check out [bkuhl/fpm-nginx](https://github.com/bkuhl/fpm-nginx).
 
# Crons, Queue Workers and Migrations

Overwrite the container's default command to perform various Laravel tasks.

 * Cron container: use command `crond -f -d 8`
 * Queue worker container: use command `php /var/www/html/artisan queue:listen --sleep=3 --tries=3 --timeout=0`
 * Migrations container: use command `php /var/www/html/artisan migrate --force`
## Example Dockerfile

```
FROM bkuhl/php:7.1

WORKDIR /var/www/html

# Copy the application files to the container
ADD --chown=www-data:www-data  . /var/www/html

USER www-data

    # production-ready dependencies
RUN composer install  --no-interaction --optimize-autoloader --no-dev --prefer-dist \

    # keep the container light weight
    && rm -rf /home/www-data/.composer/cache
```
