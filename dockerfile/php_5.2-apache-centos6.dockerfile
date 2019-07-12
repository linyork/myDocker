FROM centos:centos6.7

ENV PHP_VERSION 5.2.17

# Initial setup
RUN rpm --rebuilddb \
    && yum update -y \
    && yum groupinstall -y 'Development Tools' \
    && yum install -y epel-release

# OS dependency installation
RUN rpm --rebuilddb && yum install -y \
    wget \
    curl curl-devel \
    git \
    bzip2 \
    tar \
    sendmail \
    vim \
    zip \
    libtidy libtidy-devel \
    autoconf \
    gd gd-devel \
    patch \
    db4* \
    t1lib* t1lib-devel \
    openssl openssl-devel \
    bzip2 bzip2-devel \
    libcurl libcurl-devel \
    libxml2 libxml2-devel \
    libpng libpng-devel \
    libXpm libXpm-devel \
    libjpeg libjpeg-devel \
    iconv libiconv

# Apache installation
RUN rpm --rebuilddb && yum install -y httpd httpd-devel

# PHP 5.2 dependency installation
RUN rpm --rebuilddb && yum install -y \
  mysql-devel \
  openldap-devel \
  freetype-devel \
  gmp-devel \
  libmhash-devel \
  readline-devel \
  net-snmp-devel \
  libxslt-devel \
  libtool-ltdl-devel \
  libc-client-devel \
  ncurses-devel \
  postgresql-devel \
  aspell-devel \
  pcre-devel

# PHP 5.2 installation
WORKDIR /usr/local/src
RUN wget http://museum.php.net/php5/php-${PHP_VERSION}.tar.bz2
RUN tar xf ./php-${PHP_VERSION}.tar.bz2 -C ./
WORKDIR /usr/local/src/php-${PHP_VERSION}
RUN ./configure \
      --prefix=/usr \
      --bindir=/usr/bin \
      --sbindir=/usr/sbin \
      --sysconfdir=/etc \
      --with-libdir=lib64 \
      --with-config-file-path=/etc \
      --with-config-file-scan-dir=/etc/php/conf.d \
      --enable-gd-native-ttf \
      --enable-mbregex \
      --enable-mbstring \
      --enable-zip \
      --enable-bcmath \
      --enable-soap \
      --enable-sockets \
      --enable-ftp \
      --with-apxs2 \
      --with-openssl \
      --with-zlib \
      --with-bz2 \
      --with-gettext \
      --with-iconv \
      --with-curl \
      --with-mysql-sock \
      --with-gd \
      --with-pdo-mysql \
      --with-pdo-pgsql \
      --with-xsl \
      --with-mysql \
      --with-mysqli \
      --with-freetype-dir \
      --with-jpeg-dir \
      --with-png-dir \
      --with-gmp \
      --with-pcre-regex \
      && make && make install \
      && cp -f ./php.ini-recommended /etc/php.ini \
      && sed -i 's/^extension_dir/;extension_dir/g' /etc/php.ini \
      && mkdir -p /etc/php/conf.d \
      && rm -rf /usr/local/src/php*

# ImageMagick
RUN rpm --rebuilddb \
    && yum install -y ImageMagick ImageMagick-devel \
    && yes | pecl install -f imagick-3.1.2 \
    && echo "extension=imagick.so" > /etc/php/conf.d/docker-php-ext-imagick.ini

# xdebug
RUN pecl install xdebug-2.2.7 \
    && echo "zend_extension=/usr/lib/php/extensions/no-debug-non-zts-20060613/xdebug.so" > /etc/php/conf.d/docker-php-ext-xdebug.ini

# clear temp
RUN yum clean all \
    && rm -rf /var/cache/yum \
    && rm -rf /var/tmp/*

#ポート、ローカルは80と443
EXPOSE 80 443

# defaultのlocaleをja_JP.UTF-8にする
ENV LANG=ja_JP.UTF-8
RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8

# timezone
RUN rm -f /etc/localtime \
    && ln -s /usr/share/zoneinfo/Japan /etc/localtime \
    && echo 'ZONE="Asia/Tokyo"' > /etc/sysconfig/clock

# web server start
CMD ["-D", "FOREGROUND"]
ENTRYPOINT ["/usr/sbin/httpd"]

# for testing
#CMD ["/bin/bash"]
#ENTRYPOINT ["/sbin/init"]