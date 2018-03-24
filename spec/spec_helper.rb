require 'logstash/inputs/parser/rss_parser'

SAXMachine.handler = ENV['HANDLER'].to_sym if ENV['HANDLER']

# comparing datetimes in RSpec
# cf.: https://gist.github.com/shime/9930893
RSpec::Matchers.define :be_the_same_time_as do |expected|
  match do |actual|
    actual_time = Time.parse(actual.to_s).strftime("%Y-%m-%dT%H:%M:%S%z")
    expected_time = Time.parse(expected.to_s).strftime("%Y-%m-%dT%H:%M:%S%z")
    expect(expected_time).to eq(actual_time), "expected '#{actual_time}' to be '#{expected_time}'"
  end
end

require 'test_data'
