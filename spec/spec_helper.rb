require "logstash/inputs/parser/rss_parser"

SAXMachine.handler = ENV['HANDLER'].to_sym if ENV['HANDLER']

# comparing datetimes in RSpec
# cf.: https://gist.github.com/shime/9930893
RSpec::Matchers.define :be_the_same_time_as do |expected|
  match do |actual|
    actualTime = Time.parse(actual.to_s).strftime("%Y-%m-%dT%H:%M:%S%z")
    expectedTime = Time.parse(expected.to_s).strftime("%Y-%m-%dT%H:%M:%S%z")
    expect(expectedTime).to eq(actualTime), "expected '#{actualTime}' to be '#{expectedTime}'"
  end
end

require 'test_data'
