#!/bin/bash
export ICECAST_UID=$(cat /etc/passwd | grep icecast | grep -v icecast2 |  awk '{split($0,a,":"); print a[3]}')
export ICECAST_GID=$(cat /etc/passwd | grep icecast | grep -v icecast2 |  awk '{split($0,a,":"); print a[4]}')
echo 'Mounting /music dir for user icecast:'$ICECAST_UID':'$ICECAST_GID
s3fs ai-radio-music /music -o passwd_file=/root/.passwd-s3fs -o url=https://storage.yandexcloud.net/ -o allow_other -o umask=0007,uid=$ICECAST_UID,gid=$ICECAST_GID
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf