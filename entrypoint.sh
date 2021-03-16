#!/bin/bash
wait-hosts
if [ ! -z ${APACHE_DOCUMENT_ROOT} ]
then
	sed -ri -e "s|/var/www/html|${APACHE_DOCUMENT_ROOT}|g" /etc/apache2/sites-available/*.conf
	sed -ri -e "s|/var/www/|${APACHE_DOCUMENT_ROOT}|g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
fi

if [ -d /docker-entrypoint-init.d ]
then
	if [ ! -z $(ls /docker-entrypoint-init.d/) ]
	then
		for f in /docker-entrypoint-init.d/*; do
  		echo "     - Running $f"
  		bash "$f" -H 
		done
	fi
fi
cd /var/www/html
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- apache2-foreground "$@"
fi

exec "$@"
