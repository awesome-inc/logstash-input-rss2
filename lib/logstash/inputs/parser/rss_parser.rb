require 'faraday'
require 'feedjira'
require_relative 'entry'

# Customized RSS parser
class RSSParser

  @@initialized = false

  def self.init
    return if @@initialized

    # for rss2
    Feedjira::Feed.add_common_feed_entry_element('comments')

    # custom namespaces

    # - Europe Media Monitor
    Feedjira::Feed.add_common_feed_entry_element('iso:language', as: :language)
    Feedjira::Feed.add_common_feed_entry_element('georss:point', as: :point)
    Feedjira::Feed.add_common_feed_entry_elements('emm:entity', as: :entities)


    @@initialized = true
  end

  def self.parse(xml)
    Feedjira::Feed.parse(xml).entries.map { |e| Entry.new(e) }
  end

  def self.fetch(url, headers = DEFAULT_HEADERS)
    Faraday.get url, headers
  end

  private

  # fetch like chrome, e.g.
  # curl 'http://emm.newsbrief.eu/rss/rss?type=rtn&language=en&duplicates=false'
  # -H 'Accept-Encoding: gzip, deflate'
  # -H 'Accept-Language: en-US,en;q=0.9,de-DE;q=0.8,de;q=0.7'
  # -H 'Upgrade-Insecure-Requests: 1'
  # -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36'
  # -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8'
  # -H 'Cache-Control: max-age=0'
  # -H 'Cookie: JSESSIONID=9753E53AE860219B506307788A4456B5'
  # -H 'Connection: keep-alive' --compressed

  DEFAULT_HEADERS = {
    'Accept-Encoding' => 'gzip, deflate',
    'Accept-Language' => 'en-US,en;q=0.9,de-DE;q=0.8,de;q=0.7',
    'Upgrade-Insecure-Requests' => '1',
    'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36',
    'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
    'Cache-Control' => 'max-age=0',
    'Connection' => 'keep-alive'
      #--compressed
  }.freeze
end
