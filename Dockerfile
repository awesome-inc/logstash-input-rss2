FROM jruby:9.1.12-alpine AS builder

# cf. https://github.com/docker-library/rails/blob/master/onbuild/Dockerfile
COPY Gemfile logstash-input-rss2.gemspec /usr/src/app/
WORKDIR /usr/src/app
RUN bundle install --without=development
COPY . ./
#RUN rake spec
RUN gem build logstash-input-rss2.gemspec

FROM docker.elastic.co/logstash/logstash-oss:6.2.3
COPY --from=builder /usr/src/app/logstash-input-rss2-6.2.3.gem /plugins/
RUN bin/logstash-plugin install /plugins/logstash-input-rss2-6.2.3.gem
COPY pipeline/ /usr/share/logstash/pipeline/
