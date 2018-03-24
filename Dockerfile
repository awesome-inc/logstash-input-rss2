ARG DOCKER_BASE=${IMAGE:-jruby:9.1.12-alpine}
FROM ${DOCKER_BASE} AS build-env

# cf. https://github.com/docker-library/rails/blob/master/onbuild/Dockerfile
COPY Gemfile Gemfile.lock logstash-input-rss2.gemspec /usr/src/app/
WORKDIR /usr/src/app

RUN bundle install --without=development

COPY . ./

#RUN rake spec
RUN gem build logstash-input-rss2.gemspec

FROM docker.elastic.co/logstash/logstash-oss:6.2.3

ARG VERSION=0.1.0
ENV VERSION ${VERSION}

COPY --from=build-env /usr/src/app/logstash-input-rss2-${VERSION}.gem /plugins/
#COPY --from=build-env /usr/src/app/vendor/cache/* /plugins/vendor/cache/
RUN bin/logstash-plugin install --no-verify /plugins/logstash-input-rss2-${VERSION}.gem

COPY pipeline/ /usr/share/logstash/pipeline/
