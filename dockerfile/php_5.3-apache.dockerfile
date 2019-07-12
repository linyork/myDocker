FROM ubuntu:12.04

#set up php5 and apache
RUN apt-get update && \
    apt-get install -y \
      apache2 \
      php5 \
      php5-cli \
      libapache2-mod-php5 \
      php5-gd \
      php5-ldap \
      php5-mysql \
      php5-pgsql \
      php5-curl

#enable modrewrite
RUN a2enmod rewrite

##setup apache virtualhost
#RUN rm -r /etc/apache2/sites-available/*
#COPY apache_default /etc/apache2/sites-available/default

#setup file rights
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

#setup container
WORKDIR /var/www/html
EXPOSE 80
EXPOSE 443

#run the app
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]