FROM php:7.0-fpm

# redis xdebug
RUN pecl install redis-4.1.1 \
    && pecl install xdebug-2.6.0 \
    && docker-php-ext-enable redis xdebug

### PHP Extension ###
# opcache
RUN docker-php-ext-install opcache
# pdo_mysql
RUN docker-php-ext-install pdo_mysql
# mysqli(向下相容)
RUN docker-php-ext-install mysqli
# exif
RUN docker-php-ext-install exif
# gd
RUN apt-get update \
    && apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && apt-get clean

# composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# git
RUN apt-get update \
  && apt-get install -y git \
  && apt-get clean

# pdo_pgsql
RUN apt-get update \
    && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo_pgsql

# phalcon (owlcrm)
RUN git clone --depth=1 git://github.com/phalcon/cphalcon.git \
    && cd cphalcon/build && ./install \
    && docker-php-ext-enable phalcon \
    && cd ../../ && rm -rf ./cphalcon/