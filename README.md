[![Build Status](https://travis-ci.com/larueli/php-base-image.svg?branch=master)](https://travis-ci.com/larueli/php-base-image)

# Base image for PHP Apps

I wanted to have a base image for all my php web projects, suitable with openshift (**random uid inside container**).

Easily deploy your php apps to containers, no difficult php extensions to install or anything.
Just do

```Dockerfile
#Your own dockerfile for your project just needs something like this

FROM larueli/php-base-image:7.3

COPY . /var/www/html/

VOLUME /var/www/html/uploads

USER 0

RUN apt-get update && apt-get install -y optipng jpegoptim && apt-get autoremove -y && \
    echo "/usr/local/bin/php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration" > /docker-entrypoint-init.d/migrations.sh && \
    composer install --no-interaction --no-dev --no-ansi && composer dump-autoload --no-dev --classmap-authoritative && \
    chmod g=rwx -R /var/www/html
# last line very important : you have to allow full access the group root for openshift

USER 1420:0
```

You can put your scripts inside `/docker-entrypoint-init.d/`. They will be run at each container start.

Don't forget to add a `.dockerignore` in your project, for two reasons :

* size of your docker image
* docker cache validating
* **security secrets could be exposed via your files**

```
#.dockerignore
.git
/var
.env.*
.aws
```

## Fonctionnalities

* Based on php:apache
* Runs as non-root user.
  * Capable to run with a random user in the root group (compatible with OpenShift)
  * Port 8080 inside the container
* Composer installed
* PHP extensions from the base image and I added some

```
# docker run larueli/php-base-image:7.4 php -m
[PHP Modules]
apcu
bcmath
bz2
Core
ctype
curl
date
dom
exif
fileinfo
filter
ftp
gd
gmp
hash
iconv
imagick
imap
intl
json
ldap
libxml
mbstring
mcrypt
memcached
mongodb
mysqlnd
OAuth
openssl
pcntl
pcre
PDO
PDO_Firebird
pdo_mysql
PDO_ODBC
pdo_pgsql
pdo_sqlite
pdo_sqlsrv
pgsql
Phar
posix
readline
redis
Reflection
session
SimpleXML
sodium
SPL
sqlite3
sqlsrv
standard
tokenizer
xdebug
xml
xmlreader
xmlwriter
yaml
Zend OPcache
zip
zlib

[Zend Modules]
Xdebug
Zend OPcache
```

## Author

I am [Ivann LARUELLE](https://www.linkedin.com/in/ilaruelle/), engineering student in Networks & Telecommunications at the [Université de Technologie de Troyes](https://www.utt.fr/) in France, which is a public engineering university.

Contact me for any issue : ivann[at]laruelle.me
