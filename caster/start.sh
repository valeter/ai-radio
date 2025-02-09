#!/bin/bash

sed -i "s/{{PORT}}/$PORT/g" /etc/icecast2/icecast.xml
sed -i "s/{{PORT}}/$PORT/g" /etc/ezstream/ezstream.xml

chown -R icecast:icecast /etc/icecast2/icecast.xml
chown -R icecast:icecast /etc/ezstream/ezstream.xml
chmod 600 /etc/icecast2/icecast.xml
chmod 600 /etc/ezstream/ezstream.xml

chown -R icecast:icecast /var/log/icecast2
chown -R icecast:icecast /usr/share/icecast2/web
chown -R icecast:icecast /usr/share/icecast2/admin
chown -R icecast:icecast /usr/share/icecast2
chown -R icecast:icecast /music
chmod 600 /music/*

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf