# Use the latest Ubuntu image
FROM ubuntu:latest

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV ICECAST_PORT=32744
ENV NGINX_PORT=32745

# input secrets
RUN mkdir -p /etc/secrets
RUN chmod 600 /etc/secrets
RUN --mount=type=secret,id=AWS_ACCESS_KEY_ID \
    --mount=type=secret,id=AWS_SECRET_KEY_ID \
    printf "%s%s%s" "$(cat /run/secrets/AWS_ACCESS_KEY_ID)" ":" "$(cat /run/secrets/AWS_SECRET_KEY_ID)" > /etc/secrets/aws_creds
RUN --mount=type=secret,id=AI_RADIO_CERT_CHAIN \
    cp /run/secrets/AI_RADIO_CERT_CHAIN /etc/secrets/ai_radio_crt_chain
RUN --mount=type=secret,id=AI_RADIO_CERT_KEY \
    cp /run/secrets/AI_RADIO_CERT_KEY /etc/secrets/ai_radio_crt_key
RUN --mount=type=secret,id=ICECAST_PASSWORD \
    cp /run/secrets/ICECAST_PASSWORD /etc/secrets/icecast_password
RUN chmod 600 /etc/secrets/*

# user config
RUN useradd -ms /bin/bash icecast
RUN groupadd -f icecast
RUN usermod -a -G icecast icecast

RUN useradd -ms /bin/bash nginxuser
RUN groupadd -f nginxuser
RUN usermod -a -G nginxuser nginxuser

# install necessary packages
RUN apt-get update && apt-get install -y \
    icecast2 \
    nginx \
    supervisor \
    liquidsoap \
    s3fs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

## s3fs-fuse preprare dir & credential config
RUN echo user_allow_other | tee -a /etc/fuse.conf
RUN mkdir /music
RUN chown -R icecast:icecast /music
RUN chmod -R 600 /music
RUN cp /etc/secrets/aws_creds /root/.passwd-s3fs && \
    chmod 600 /root/.passwd-s3fs

# prepare certs
RUN cp /etc/secrets/ai_radio_crt_chain /usr/local/share/ca-certificates/ai-radio.crt
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
RUN export ICECAST_PASSWORD=$(cat /etc/secrets/icecast_password); sed -i "s/{{ICECAST_PASSWORD}}/$ICECAST_PASSWORD/g" /etc/icecast2/icecast.xml
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
RUN cp /etc/secrets/ai_radio_crt_chain /etc/nginx/ai-radio-chain.crt
RUN chown -R nginxuser:nginxuser /etc/nginx/ai-radio-chain.crt
RUN chmod 600 /etc/nginx/ai-radio-chain.crt
RUN cp /etc/secrets/ai_radio_crt_key /etc/nginx/ai-radio-chain.key
RUN chown -R nginxuser:nginxuser /etc/nginx/ai-radio-chain.key
RUN chmod 600 /etc/nginx/ai-radio-chain.key

# liquidsoap
RUN mkdir -p /var/log/liquidsoap
RUN chown -R icecast:icecast /var/log/liquidsoap
COPY ai-radio.liq.tmpl /etc/liquidsoap/ai-radio.liq
RUN sed -i "s/{{ICECAST_PORT}}/$ICECAST_PORT/g" /etc/liquidsoap/ai-radio.liq
RUN export ICECAST_PASSWORD=$(cat /etc/secrets/icecast_password); sed -i "s/{{ICECAST_PASSWORD}}/$ICECAST_PASSWORD/g" /etc/liquidsoap/ai-radio.liq
RUN chmod u+x /etc/liquidsoap/ai-radio.liq
RUN mkdir -p /etc/liquidsoap/
RUN chown -R icecast:icecast /etc/liquidsoap/

# supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# start
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]