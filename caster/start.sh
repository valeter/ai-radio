#!/bin/bash

sed -i "s/{{ICECAST_PORT}}/$ICECAST_PORT/g" /etc/icecast2/icecast.xml
sed -i "s/{{ICECAST_PORT}}/$ICECAST_PORT/g" /etc/ezstream/ezstream.xml

sed -i "s/{{ICECAST_PORT}}/$ICECAST_PORT/g" /etc/nginx/nginx.conf
sed -i "s/{{NGINX_PORT}}/$NGINX_PORT/g" /etc/nginx/nginx.conf

chown -R icecast:icecast /etc/icecast2/icecast.xml
chown -R icecast:icecast /etc/ezstream/ezstream.xml
chmod 600 /etc/icecast2/icecast.xml
chmod 600 /etc/ezstream/ezstream.xml

chown -R icecast:icecast /var/log/icecast2
chown -R icecast:icecast /usr/share/icecast2/web
chown -R icecast:icecast /usr/share/icecast2/admin
chown -R icecast:icecast /usr/share/icecast2

chown -R nginxuser:nginxuser /var/log/nginx
chown -R nginxuser:nginxuser /var/lib/nginx
chown -R nginxuser:nginxuser /etc/nginx/ai-radio-chain.crt
chmod 600 /etc/nginx/ai-radio-chain.crt
chown -R nginxuser:nginxuser /etc/nginx/ai-radio-chain.key
chmod 600 /etc/nginx/ai-radio-chain.key

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf