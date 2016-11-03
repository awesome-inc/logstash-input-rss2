RSSParser.init

module TestData

  FEED_XML = Hash.new()
  FEED_ITEMS = Hash.new()

  def TestData.feed_xml(key)
      return FEED_XML[key] if FEED_XML.key?(key) 

      filename = "#{File.dirname(__FILE__)}/sample_feeds/#{key}.xml"
      xml = File.read(filename)
      #puts "  Read test feed '#{key}'."
      FEED_XML.store(key, xml)

      return xml
  end

  def TestData.feed_items(key)
      return FEED_ITEMS[key] if FEED_ITEMS.key?(key) 

      xml = feed_xml(key)
      items = RSSParser.parse xml
      #puts "  Parsed test feed '#{key}' (#{items.length} items)."
      FEED_ITEMS.store(key, items)

      return items
  end
end
