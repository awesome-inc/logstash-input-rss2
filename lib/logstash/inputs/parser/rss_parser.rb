require "feedjira"
require_relative "entry"

class RSSParser

  @@initialized = false
  
  def self.init
    unless @@initialized == true

      # for rss2
      Feedjira::Feed.add_common_feed_entry_element('comments')

      # custom namespaces

      # - Europe Media Monitor
      Feedjira::Feed.add_common_feed_entry_element('iso:language', :as => :language)
      Feedjira::Feed.add_common_feed_entry_element('georss:point', :as => :point)
      Feedjira::Feed.add_common_feed_entry_elements('emm:entity', :as => :entities) #, :class => Entity)


      @@initialized = true
    end 
  end

  def self.parse(xml)
    return Feedjira::Feed.parse(xml).entries.map { |e| Entry.new(e)  }
  end
end
