ARG DOCKER_BASE=${IMAGE:-jruby:9.1.12-alpine}
FROM ${DOCKER_BASE} AS build-env

# cf. https://github.com/docker-library/rails/blob/master/onbuild/Dockerfile
COPY Gemfile Gemfile.lock logstash-input-rss2.gemspec /usr/src/app/
WORKDIR /usr/src/app

COPY vendor/cache ./vendor/cache/
RUN bundle install --local --deployment
#RUN bundle install
#RUN bundle package

COPY . ./

RUN rake spec
RUN gem build logstash-input-rss2.gemspec

FROM docker.elastic.co/logstash/logstash-oss:6.2.3

ARG VERSION=0.1.0
ENV VERSION ${VERSION}

COPY --from=build-env /usr/src/app/logstash-input-rss2-${VERSION}.gem /plugins
COPY --from=build-env /usr/src/app/vendor/cache/* /plugins/vendor/cache/
RUN bin/logstash-plugin install /plugins/logstash-input-rss2-${VERSION}.gem

COPY pipeline/ /usr/share/logstash/pipeline/
