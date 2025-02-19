# Use the latest Ubuntu image
FROM ubuntu:latest

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

RUN useradd -ms /bin/bash icecast
RUN groupadd -f icecast
RUN usermod -a -G icecast icecast

RUN useradd -ms /bin/bash nginxuser
RUN groupadd -f nginxuser
RUN usermod -a -G nginxuser nginxuser

ENV ICECAST_PORT=80
ENV NGINX_PORT=443

# mount some music
COPY example-music/ /music/
RUN chown -R icecast:icecast /music
RUN chmod 600 /music/*

# install necessary packages
RUN apt-get update && apt-get install -y \
    icecast2 \
    nginx \
    supervisor \
    curl \
    liquidsoap \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# prepare certs
COPY ai-radio-chain.crt /usr/local/share/ca-certificates/ai-radio.crt
RUN chmod 644 /usr/local/share/ca-certificates/ai-radio.crt
RUN update-ca-certificates

# icecast
RUN mkdir -p /etc/icecast2
RUN chown -R icecast:icecast /etc/icecast2
RUN mkdir -p /var/log/icecast2
RUN chown -R icecast:icecast /var/log/icecast2
RUN chown -R icecast:icecast /usr/share/icecast2/web
RUN chown -R icecast:icecast /usr/share/icecast2/admin
RUN chown -R icecast:icecast /usr/share/icecast2
COPY icecast.xml.tmpl /etc/icecast2/icecast.xml
RUN sed -i "s/{{ICECAST_PORT}}/$ICECAST_PORT/g" /etc/icecast2/icecast.xml
RUN chown -R icecast:icecast /etc/icecast2/icecast.xml
RUN chmod 600 /etc/icecast2/icecast.xml

# nginx
RUN mkdir -p /etc/nginx
RUN chown -R nginxuser:nginxuser /etc/nginx
RUN mkdir -p /var/log/nginx
RUN chown -R nginxuser:nginxuser /var/log/nginx
RUN mkdir -p /var/lib/nginx
RUN chown -R nginxuser:nginxuser /var/lib/nginx
COPY nginx.conf.tmpl /etc/nginx/nginx.conf
RUN sed -i "s/{{ICECAST_PORT}}/$ICECAST_PORT/g" /etc/nginx/nginx.conf
RUN sed -i "s/{{NGINX_PORT}}/$NGINX_PORT/g" /etc/nginx/nginx.conf
RUN chown -R nginxuser:nginxuser /etc/nginx/nginx.conf
RUN chmod 600 /etc/nginx/nginx.conf
COPY ai-radio-chain.crt /etc/nginx/ai-radio-chain.crt
RUN chown -R nginxuser:nginxuser /etc/nginx/ai-radio-chain.crt
RUN chmod 600 /etc/nginx/ai-radio-chain.crt
COPY ai-radio-chain.key /etc/nginx/ai-radio-chain.key
RUN chown -R nginxuser:nginxuser /etc/nginx/ai-radio-chain.key
RUN chmod 600 /etc/nginx/ai-radio-chain.key

# liquidsoap
RUN mkdir -p /var/log/liquidsoap
RUN chown -R icecast:icecast /var/log/liquidsoap
COPY ai-radio.liq.tmpl /etc/liquidsoap/ai-radio.liq
RUN sed -i "s/{{ICECAST_PORT}}/$ICECAST_PORT/g" /etc/liquidsoap/ai-radio.liq
RUN chmod u+x /etc/liquidsoap/ai-radio.liq
RUN mkdir -p /etc/liquidsoap/
RUN chown -R icecast:icecast /etc/liquidsoap/

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]