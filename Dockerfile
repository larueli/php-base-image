ARG PHP_BUILD_VERSION=7.4

FROM php:${PHP_BUILD_VERSION}-apache

ENV PHP_BUILD_VERSION=${PHP_BUILD_VERSION}

LABEL maintainer="ivann.laruelle@gmail.com"

COPY site.conf /etc/apache2/sites-available/000-default.conf
COPY ports.conf /etc/apache2/ports.conf
COPY entrypoint.sh /entrypoint.sh

ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/

RUN chmod uga+x /usr/local/bin/install-php-extensions && sync && \
    apt-get update && apt-get install -y vim zip unzip git rsync nano && \
    install-php-extensions gd intl ctype curl phar filter iconv ldap mcrypt bcmath xdebug imap mongodb pgsql oauth pdo_pgsql pdo_firebird pdo_odbc pdo_sqlsrv sqlsrv yaml json pdo simplexml xml tokenizer xmlwriter xmlreader pdo_mysql zip intl && \
    apt-get autoremove -y && a2enmod rewrite && \
    chgrp -R 0 /var/www/html && chmod g+rwx -R /var/www/html && chmod +x /entrypoint.sh && chmod g+rwx -R /etc/apache2 \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php composer-setup.php --install-dir=/usr/bin/ --filename=composer && php -r "unlink('composer-setup.php');"

EXPOSE 8080

WORKDIR /var/www/html

USER 1420:0

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "apache2-foreground" ]
