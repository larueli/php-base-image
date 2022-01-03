ARG PHP_BUILD_VERSION=8.1

FROM php:${PHP_BUILD_VERSION}-apache

ENV PHP_BUILD_VERSION=${PHP_BUILD_VERSION}

LABEL maintainer="ivann.laruelle@gmail.com"

COPY site.conf /etc/apache2/sites-available/000-default.conf
COPY ports.conf /etc/apache2/ports.conf
COPY entrypoint.sh /entrypoint.sh
COPY modules /tmp/modules

ARG DOCKER_PHP_EXTENSION_INSTALLER=1.4.0
ENV DOCKER_PHP_EXTENSION_INSTALLER=${DOCKER_PHP_EXTENSION_INSTALLER}
ADD https://github.com/mlocati/docker-php-extension-installer/releases/download/${DOCKER_PHP_EXTENSION_INSTALLER}/install-php-extensions /usr/local/bin/

ARG DOCKER_COMPOSE_WAIT_VERSION=2.9.0
ENV DOCKER_COMPOSE_WAIT_VERSION=${DOCKER_COMPOSE_WAIT_VERSION}
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/${DOCKER_COMPOSE_WAIT_VERSION}/wait /usr/local/bin/wait-hosts

RUN chmod uga+x /usr/local/bin/install-php-extensions && chmod uga+x /usr/local/bin/wait-hosts && sync && \
    apt-get update && apt-get install -y vim zip wget iputils-ping netcat dnsutils curl unzip git rsync dos2unix nano && \
    echo "Php modules to be installed : " `cat /tmp/modules/${PHP_BUILD_VERSION}` && \
    install-php-extensions @composer `cat /tmp/modules/${PHP_BUILD_VERSION}` && \
    apt-get autoremove -y && a2enmod rewrite && mkdir /docker-entrypoint-init.d && chgrp 0 /docker-entrypoint-init.d && chmod g=rwx /docker-entrypoint-init.d && \
    sed -i 's/^Timeout [0-9]*/Timeout 3600/g' /etc/apache2/apache2.conf && \
    chgrp -R 0 /var/www/html && chmod g+rwx -R /var/www/html && chmod +x /entrypoint.sh && chmod g+rwx -R /etc/apache2 && mkdir /.composer && chmod g+rwx /.composer && \
    dos2unix /entrypoint.sh

EXPOSE 8080

WORKDIR /var/www/html

USER 1420:0

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "apache2-foreground" ]
