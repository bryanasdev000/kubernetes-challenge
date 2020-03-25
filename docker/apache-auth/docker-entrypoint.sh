#!/bin/sh

htpasswd -bc /etc/apache2/htpasswd $HTPASSWD_USER $HTPASSWD_PASS > /dev/null 2>&1

echo 'Sem logs dessa vez...'

httpd -DFOREGROUND
