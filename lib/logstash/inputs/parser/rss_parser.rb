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
end
