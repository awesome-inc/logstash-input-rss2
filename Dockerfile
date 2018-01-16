ARG DOCKER_BASE=${IMAGE:-jruby:9.1.12-alpine}
FROM ${DOCKER_BASE} AS build-env

# cf. https://github.com/docker-library/rails/blob/master/onbuild/Dockerfile
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile* *.gemspec ./

RUN bundle install && bundle package

COPY . /usr/src/app

RUN rake spec
RUN gem build logstash-input-rss2.gemspec

FROM docker.elastic.co/logstash/logstash:5.5.0

COPY *.sh /

ARG VERSION=0.1.0
ENV VERSION ${VERSION}

WORKDIR /usr/share/logstash/
RUN mkdir -p ./vendor/cache
COPY --from=build-env /usr/src/app/vendor/cache/* ./vendor/cache/

COPY --from=build-env /usr/src/app/logstash-input-rss2-${VERSION}.gem .
RUN bin/logstash-plugin install logstash-input-rss2-${VERSION}.gem

COPY log4j2.properties /etc/logstash/log4j2.properties
COPY config/ /etc/logstash/conf.d

EXPOSE 5044

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["-f", "/etc/logstash/conf.d"]
