#!/bin/bash
set -e

source /config-proxy.sh

bin/logstash-plugin install logstash-input-rss2-${VERSION}.gem
