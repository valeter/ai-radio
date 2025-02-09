# Use the latest Ubuntu image
FROM ubuntu:latest

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

RUN useradd -ms /bin/bash icecast
RUN groupadd -f icecast
RUN usermod -a -G icecast icecast

# Install necessary packages
RUN apt-get update && apt-get install -y \
    icecast2 \
    ezstream \
    lsof \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy custom Icecast and Ezstream configuration files
COPY icecast.xml /etc/icecast2/icecast.xml
COPY ezstream.xml /etc/ezstream.xml

RUN chown -R icecast:icecast /etc/icecast2/icecast.xml
RUN chown -R icecast:icecast /etc/ezstream.xml

RUN chown -R icecast:icecast /var/log/icecast2
RUN chown -R icecast:icecast /usr/share/icecast2/web
RUN chown -R icecast:icecast /usr/share/icecast2/admin
RUN chown -R icecast:icecast /usr/share/icecast2

RUN chmod 600 /etc/icecast2/icecast.xml
RUN chmod 600 /etc/ezstream.xml

# Copy example music files
COPY example-music/ /music/

RUN chown -R icecast:icecast /music
RUN chmod 600 /music/*


# Create a shell script to run both commands
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'nohup /usr/bin/icecast2 -c /etc/icecast2/icecast.xml &' >> /start.sh && \
    echo 'sleep 1' >> /start.sh && \
    echo 'while ! lsof -i :8000; do' >> /start.sh && \
    echo '    sleep 1' >> /start.sh && \
    echo 'done' >> /start.sh && \
    echo '/usr/bin/ezstream -c /etc/ezstream.xml' >> /start.sh

RUN chown -R icecast:icecast /start.sh
RUN chmod +x /start.sh

USER icecast

# Use the shell script as the CMD
CMD ["/start.sh"]