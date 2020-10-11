# Base image for PHP Apps

I wanted to have a base image for all my php web projects, suitable with openshift (**random uid inside container**).

Easily deploy your php apps to containers, no difficult php extensions to install or anything.
Just do

```
#Your own dockerfile for your project just needs this

FROM larueli/php-base-image:7.4

COPY . /var/www/html/

# USER 0  #Switch back to root user in order to install packages of your own
# RUN apt-get update && apt-get install -y optipng jpegoptim && apt-get autoremove -y # don't forget to update the package list and to autoremove
# USER 1420:0 # VERY IMPORTANT : switch back to the default larueli/php-base-image user 

# The workdir for larueli/php-base-image is /var/www/html so you can just do this :
RUN composer install --no-interaction --no-dev --no-ansi && composer dump-autoload --no-dev --classmap-authoritative
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
bcmath
Core
ctype
curl
date
dom
fileinfo
filter
ftp
gd
hash
iconv
imap
intl
json
ldap
libxml
mbstring
mcrypt
mongodb
mysqlnd
OAuth
openssl
pcre
PDO
pdo_dblib
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
zip
zlib
```

# Author


I am [Ivann LARUELLE](https://www.linkedin.com/in/ilaruelle/), engineering student in Networks & Telecommunications at the [Université de Technologie de Troyes](https://www.utt.fr/) in France, which is a public engineering university.

Contact me for any issue : ivann[at]laruelle.me