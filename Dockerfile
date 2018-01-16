FROM docker.elastic.co/logstash/logstash:5.5.0

# Add your logstash plugins setup here
# Copy source files
COPY ./ /usr/share/logstash-input-rss2/

# Install dependencies
COPY *.sh /
RUN /install-plugins.sh

COPY log4j2.properties /etc/logstash/log4j2.properties
COPY config/ /etc/logstash/conf.d

EXPOSE 5044

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["-f", "/etc/logstash/conf.d"]
