ARG PHP_BUILD_VERSION=8.2

FROM php:${PHP_BUILD_VERSION}-apache AS base

ENV PHP_BUILD_VERSION=${PHP_BUILD_VERSION}

LABEL maintainer="ivann.laruelle@gmail.com"

COPY site.conf /etc/apache2/sites-available/000-default.conf
COPY ports.conf /etc/apache2/ports.conf
COPY entrypoint.sh /entrypoint.sh

# https://github.com/mlocati/docker-php-extension-installer/releases
ARG DOCKER_PHP_EXTENSION_INSTALLER=2.0.2
ENV DOCKER_PHP_EXTENSION_INSTALLER=${DOCKER_PHP_EXTENSION_INSTALLER}
ADD https://github.com/mlocati/docker-php-extension-installer/releases/download/${DOCKER_PHP_EXTENSION_INSTALLER}/install-php-extensions /usr/local/bin/

# https://github.com/ufoscout/docker-compose-wait/releases
ARG DOCKER_COMPOSE_WAIT_VERSION=2.9.0
ENV DOCKER_COMPOSE_WAIT_VERSION=${DOCKER_COMPOSE_WAIT_VERSION}
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/${DOCKER_COMPOSE_WAIT_VERSION}/wait /usr/local/bin/wait-hosts

RUN chmod uga+x /usr/local/bin/install-php-extensions && chmod uga+x /usr/local/bin/wait-hosts && sync && \
    apt-get update && apt-get install -y vim zip wget iputils-ping netcat dnsutils curl unzip git rsync dos2unix nano && \
    install-php-extensions @composer gd calendar soap intl gmp exif opcache apcu memcached redis pcntl imagick ctype curl phar bz2 filter iconv ldap mcrypt bcmath imap mongodb pgsql oauth pdo_pgsql pdo_firebird mysqli yaml json pdo simplexml xml tokenizer xmlwriter xmlreader pdo_mysql zip && \
    apt-get autoremove -y && a2enmod rewrite && mkdir /docker-entrypoint-init.d && chgrp 0 /docker-entrypoint-init.d && chmod g=rwx /docker-entrypoint-init.d && \
    sed -i 's/^Timeout [0-9]*/Timeout 3600/g' /etc/apache2/apache2.conf && \
    chgrp -R 0 /var/www/html && chmod g+rwx -R /var/www/html && chmod +x /entrypoint.sh && chmod g+rwx -R /etc/apache2 && mkdir /.composer && chmod g+rwx /.composer && \
    dos2unix /entrypoint.sh

EXPOSE 8080

WORKDIR /var/www/html

USER 1420:0

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "apache2-foreground" ]

FROM base AS development

USER 0:0

RUN install-php-extensions xdebug
COPY php.ini.dev /usr/local/etc/php/conf.d/debug_docker.ini

USER 1420:0

FROM base AS production
