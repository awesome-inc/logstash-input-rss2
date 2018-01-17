
# test data helpers
class TestData
  RSSParser.init
  @@feeds = {}
  @@entries = {}

  def self.feed_xml(key)
    return @@feeds[key] if @@feeds.key?(key)

    filename = "#{File.dirname(__FILE__)}/sample_feeds/#{key}.xml"
    xml = File.read(filename)
    puts "  Read test feed '#{key}'."
    @@feeds[key] = xml
    xml
  end

  def self.feed_items(key)
    return @@entries[key] if @@entries.key?(key)

    xml = feed_xml(key)
    items = RSSParser.parse xml
    puts "  Parsed test feed '#{key}' (#{items.length} items)."
    @@entries[key] = items
    items
  end
end
