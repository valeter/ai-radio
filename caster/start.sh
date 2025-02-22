#!/bin/bash
s3fs ai-radio-music /music -o passwd_file=~/.passwd-s3fs -o url=https://storage.yandexcloud.net/
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf