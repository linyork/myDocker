FROM php:7.0-apache

# locale ja_JP.UTF-8
RUN apt-get update \
    && apt-get install -y locales \
    && echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get clean

# composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# git
RUN apt-get update \
  && apt-get install -y git \
  && apt-get clean

### PHP Extension ###
# opcache
RUN docker-php-ext-install opcache
# pdo_mysql
RUN docker-php-ext-install pdo_mysql
# mysqli
RUN docker-php-ext-install mysqli
# exif
RUN docker-php-ext-install exif
# gd
RUN apt-get update \
    && apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && apt-get clean

# bcmath
RUN docker-php-ext-install bcmath

# pdo_pgsql
RUN apt-get update \
    && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo_pgsql

# redis xdebug
RUN pecl install redis-4.1.1 \
    && pecl install xdebug-2.6.0 \
    && docker-php-ext-enable redis xdebug

# apache ssl & rewrite
RUN a2enmod rewrite
RUN a2enmod ssl