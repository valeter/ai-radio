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

COPY example-music/ /music/
RUN chown -R icecast:icecast /music
RUN chmod 600 /music/*

# Install necessary packages
RUN apt-get update && apt-get install -y \
    icecast2 \
    ezstream \
    nginx \
    supervisor \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /etc/ezstream

# Copy custom Icecast and Ezstream configuration files
COPY icecast.xml.tmpl /etc/icecast2/icecast.xml
COPY ezstream.xml.tmpl /etc/ezstream/ezstream.xml
COPY nginx.conf.tmpl /etc/nginx/nginx.conf

COPY ai-radio-chain.crt /etc/nginx/ai-radio-chain.crt
COPY ai-radio-chain.key /etc/nginx/ai-radio-chain.key

COPY ai-radio-chain.crt /usr/local/share/ca-certificates/ai-radio.crt
RUN chmod 644 /usr/local/share/ca-certificates/ai-radio.crt
RUN update-ca-certificates

# Copy supervisord configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]