ARG DOCKER_BASE=${IMAGE:-jruby:9.1.12-alpine}
FROM ${DOCKER_BASE} AS build-env

# cf. https://github.com/docker-library/rails/blob/master/onbuild/Dockerfile
COPY Gemfile Gemfile.lock logstash-input-rss2.gemspec /usr/src/app/
WORKDIR /usr/src/app

RUN bundle install --without=development

COPY . ./

ARG ELK_VERSION
ENV ELK_VERSION $ELK_VERSION
#RUN rake spec
RUN gem build logstash-input-rss2.gemspec

ARG ELK_VERSION
FROM docker.elastic.co/logstash/logstash-oss:${ELK_VERSION}}

ARG ELK_VERSION
COPY --from=build-env /usr/src/app/logstash-input-rss2-${ELK_VERSION}.gem /plugins/
RUN bin/logstash-plugin install --no-verify /plugins/logstash-input-rss2-${ELK_VERSION}.gem

COPY pipeline/ /usr/share/logstash/pipeline/
