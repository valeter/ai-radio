# Use the latest Ubuntu image
FROM ubuntu:latest

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

RUN useradd -ms /bin/bash icecast
RUN groupadd -f icecast
RUN usermod -a -G icecast icecast

# for local use only
#ENV PORT=8080
#COPY example-music/ /music/
#RUN chown -R icecast:icecast /music
#RUN chmod 600 /music/*

# Install necessary packages
RUN apt-get update && apt-get install -y \
    icecast2 \
    ezstream \
    lsof \
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /etc/ezstream

# Copy custom Icecast and Ezstream configuration files
COPY icecast.xml.tmpl /etc/icecast2/icecast.xml
COPY ezstream.xml.tmpl /etc/ezstream/ezstream.xml

# Copy supervisord configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]