#!/bin/bash
wait-hosts
if [ -n "${APACHE_DOCUMENT_ROOT}" ] && [ ! -f "/etc/apache2/modified" ]
then
	echo "Rewriting Apache Document Root"
	sed -ri -e "s|/var/www/html|${APACHE_DOCUMENT_ROOT}|g" /etc/apache2/sites-available/*.conf
	sed -ri -e "s|/var/www/|${APACHE_DOCUMENT_ROOT}|g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
	touch /etc/apache2/modified
else
	echo "Rewriting Apache Document Root skipped"
fi

if [ -d /docker-entrypoint-init.d ]
then
	if [ "$(ls -A /docker-entrypoint-init.d/)" ]
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
