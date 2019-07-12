FROM php:5.4-apache

# redis xdebug
RUN pecl install redis-4.1.1 \
    && pecl install xdebug-2.4.1 \
    && docker-php-ext-enable redis xdebug

# pdo_mysql
RUN docker-php-ext-install pdo_mysql
# mysqli(向下相容)
RUN docker-php-ext-install mysqli

# mbstring
RUN docker-php-ext-install mbstring

# imagick
RUN apt-get update && apt-get install -y \
    libmagickwand-dev --no-install-recommends \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && apt-get clean

# apache ssl & rewrite
RUN a2enmod rewrite
RUN a2enmod ssl