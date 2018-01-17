require 'spec_helper'

describe RSSParser do

  describe '.parse(rss2)' do
    # cf.: RSS2 specification: https://validator.w3.org/feed/docs/rss2.html#ltcategorygtSubelementOfLtitemgt

    items = TestData.feed_items('rss2')
    item = items.first

    it "should parse <item> as 'entry'" do
      expect(items.length).to eq 9
      expect(items).to all satisfy { |item| item.kind_of? Entry }
    end

    it 'should hash a unique id' do
      expect(item.id).to eq 'feedforall-c7e9c5c3947b7b00612fedbd69796b6e'
    end

    it 'should parse <title>' do
      expect(item.title).to eq 'RSS Solutions for Restaurants'
    end

    it 'should parse <summary> (html)' do
      # NOTE: for JRuby set JAVA_OPTS = ... -Dfile.encoding=UTF-8
      # cf.: http://blog.rayapps.com/2013/03/11/7-things-that-can-go-wrong-with-ruby-19-string-encodings/
      #expect(ENV_JAVA['file.encoding']).to eq "UTF-8"
      expect(item.summary).to eq "<b>FeedForAll </b>helps Restaurant's communicate with customers. Let your customers know the latest specials or events.<br>\n<br>\nRSS feed uses include:<br>\n<i><font color=\"#FF0000\">Daily Specials <br>\nEntertainment <br>\nCalendar of Events </i></font>"
    end

    it "should parse <pubDate> as 'published'" do
      expect(item.published).to be_the_same_time_as Time.utc(2004, 10, 19, 15, 9, 11)
    end

    it 'should parse <category> (unique)' do
      expect(item.categories).to match_array [ 'Computers/Software/Internet/Site Management/Content Management' ]
    end

    it "should parse 'domain' from <link>" do
      # TODO: parse directly from <source> if available
      expect(item.url).to eq 'http://www.feedforall.com/restaurant.htm'
      expect(item.domain).to eq 'feedforall'
    end

    it 'should parse <comments>' do
      expect(item.comments).to eq 'http://www.feedforall.com/forum'
    end

    it 'should parse <author>' do
      author =  'Tom, Dick and Harry'
      # rss
      xml = "<rss version=\"2.0\"><channel><item><author>#{author}</author></item></channel></rss>"
      actual = RSSParser.parse(xml).first
      expect(actual.author).to eq author

      # atom
      xml = "<feed xmlns=\"http://www.w3.org/2005/Atom\"><entry><author><name>#{author}</name></author></entry></feed>"
      actual = RSSParser.parse(xml).first
      expect(actual.author).to eq author

    end

    it 'should duplicate <summary> into <content>, if nil' do
      expect(item.content).to eq item.summary
    end

    it 'should parse <content> if not nil' do
      content =  'content'
      xml = "<feed xmlns=\"http://www.w3.org/2005/Atom\"><entry><content>#{content}</content></entry></feed>"
      actual = RSSParser.parse(xml).first
      expect(actual.content).to eq content
    end
  end

  describe '.parse(heise-atom)' do
    items = TestData.feed_items('heise')
    item = items.first

    it 'should parse <updated> (atom)' do

      expect(item.title).to eq 'Trend Micro: Pawn Storm hat nach dem Bundestag nun die CDU im Visier'
      expect(item.entry_id).to eq 'http://heise.de/-3207508'
      expect(item.published).to be_the_same_time_as Time.utc(2016,05,12,16,20,0)
      expect(item.updated).to be_the_same_time_as Time.utc(2016,05,12,16,20,32)
      expect(item.url).to eq 'http://www.heise.de/security/meldung/Trend-Micro-Pawn-Storm-hat-nach-dem-Bundestag-nun-die-CDU-im-Visier-3207508.html?wt_mc=rss.security.beitrag.atom'
      expect(item.summary).to eq "Nachdem vermutlich russische Hacker der IT des deutschen Parlaments schweren Schaden zugefügt hatten, nehmen sie nun offenbar auch andere politische Player ins Fadenkreuz. "
      #expect(item.content).to not_be nil or summary
    end
  end

  describe '.parse(emm_small)' do
    items = TestData.feed_items('emm_small')

    it 'should parse <pubDate>' do
      expect(items[0].published).to be_the_same_time_as Time.utc(2016, 5, 12, 10, 59, 0)
    end

    it 'should parse <category> (unique)' do
      expect(items[0].categories).to match_array ['FightagainstFraud']
      expect(items[1].categories).to match_array ['TaxHaven', 'FightagainstFraud', 'TAXUD', 'FinancialEconomicCrime']
    end

    it "should parse <guid> as 'entry_id'" do
      expect(items[0].entry_id).to eq '680news-1804d9c60271f4a368eabf45c870aa1c'
      expect(items[1].entry_id).to eq 'wafb-0f1d965d94293b2ddc142a162cad055b'
    end

    it "should parse 'domain' from <link>" do
      # TODO: parse directly from <source> if available
      expect(items[0].url).to eq 'http://www.680news.com/2016/05/12/the-latest-brazils-senate-impeaches-president-rousseff/'
      expect(items[0].domain).to eq '680news'
      expect(items[1].url).to eq 'http://www.wafb.com/story/31954738/the-latest-nations-vary-in-commitment-to-fight-corruption'
      expect(items[1].domain).to eq 'wafb'
    end

    it 'should parse <iso:language>' do
      expect(items).to all satisfy { |item| item.language == 'en' }
    end

    it 'should parse <georss:point>' do
      expect(items[0].longitude).to eq '-43.4552'
      expect(items[0].latitude).to eq '-22.7216'
      expect(items[1].longitude).to eq '-1.2833333'
      expect(items[1].latitude).to eq '53.3333333'
    end

    it 'should parse <emm:entity> (unique)' do
      expect(items[0].entities).to match_array ['Dilma Rousseff', 'Humberto Costa', 'Renan Calheiros', 'Michel Temer', 'Romero Juca', 'Democratic Movement']
      expect(items[1].entities).to match_array ['David Cameron', 'John Kerry', 'Allan Bell']
    end
  end

  describe '.parse(presseportal)' do
    items = TestData.feed_items('presseportal')

    it 'should parse entries' do
      expect(items.length).to eq 15
    end

    it 'should parse <author>' do
      expect(items[0].author).to eq 'redaktion@presseportal.de (presseportal.de)'
    end
  end

  describe '.parse(threatpost)' do
    items = TestData.feed_items('threatpost')

    it 'should parse entries' do
      expect(items.length).to eq 10
    end

    it 'should parse <dc:creator> from <![CDATA[]]' do
      expect(items[0].author).to eq 'Tom Spring'
    end

    it 'should parse <category> from <![CDATA[]]' do
      expect(items[0].categories).to match_array ['Cloud Security', 'Vulnerabilities', 'Web Security', 'computer worm', 'Ubiquiti Networks', 'Worm' ]
    end
  end

  describe '.parse(kaspersky)' do
    items = TestData.feed_items('kaspersky')

    it 'should parse entries' do
      expect(items.length).to eq 10
    end

    it 'should parse <dc:creator> from <![CDATA[]]' do
      expect(items[0].author).to eq 'GReAT'
    end

    it 'should parse <category> from <![CDATA[]]' do
      expect(items[0].categories).to match_array ['Blog', 'Research', 'APT', 'ATM attacks', 'Cybercrime' ]
    end
  end

  describe '.parse(fbi)' do
    items = TestData.feed_items('fbi')

    it 'should parse entries' do
      expect(items.length).to eq 15
    end

    it 'should parse <author>' do
      expect(items[0].author).to eq 'fbi'
    end

    it 'should parse <category>' do
      expect(items[0].categories.length).to eq 62
      expect(items[0].categories[0]).to eq 'Newark Top Stories'
    end
  end

  describe '.parse attached media (itunes, etc.)' do
    it 'should parse <enclosure>' do
      items = TestData.feed_items('heise_architektour')
      expect(items.length).to eq 54
      expect(items[0].enclosure_url).to eq 'http://www.heise.de/developer/downloads/06/1/7/9/8/6/9/3/softwarearchitektour_53_iot.mp3'
      expect(items[0].enclosure_length).to eq '54415472'
      expect(items[0].enclosure_type).to eq 'audio/mpeg'
    end

    it 'should parse <itunes:xxx>' do
      items = TestData.feed_items('itunes')
      expect(items.length).to eq 3

      expect(items[0].author).to eq 'John Doe'
      expect(items[0].summary).to eq 'This week we talk about salt and pepper shakers, comparing and contrasting pour rates, construction materials, and overall aesthetics. Come and join the party!'

      expect(items[0].enclosure_url).to eq 'http://example.com/podcasts/everything/AllAboutEverythingEpisode3.m4a'
      expect(items[0].enclosure_length).to eq '8727310'
      expect(items[0].enclosure_type).to eq 'audio/x-m4a'
    end
  end

  describe '.parse(sciencedaily)' do
    items = TestData.feed_items('sciencedaily')

    it 'should parse entries' do
      expect(items.length).to eq 4
      expect(items[0].published).to be_the_same_time_as Time.utc(2016,04,26,20,26,13) # Tue, 26 Apr 2016 16:26:13 EDT
      expect(items[0].updated).to be_nil
      expect(items[0].title).to eq 'Chile quake at epicenter of expanding disaster, failure data repository'
      expect(items[0].url).to eq 'https://www.sciencedaily.com/releases/2016/04/160426162613.htm'
    end
  end

  describe '.parse(nasa360)' do
    items = TestData.feed_items('nasa360')

    it 'should parse entries' do
      expect(items.length).to eq 10
      expect(items[0].published).to be_the_same_time_as Time.utc(2015,04,16,18,41,0)
      expect(items[0].updated).to be_nil
      expect(items[0].title).to eq 'NASA 360 Talks - Exploring Mars'
      expect(items[0].url).to eq 'http://www.nasa.gov/content/nasa-360-talks-exploring-mars'
      expect(items[0].enclosure_url).to eq 'http://www.nasa.gov/sites/default/files/atoms/video/nasa_360_talks_-_jim_green_at_lpsc_cut_4-15-15_youtube_settings_final.mp4'
    end
  end

  describe '.parse(google)' do
    items = TestData.feed_items('google')

    it 'should parse entries' do
      expect(items.length).to eq 5
      expect(items[0].entry_id).to eq 'tag:news.google.com,2005:cluster=52779123879096'
      expect(items[0].categories).to match_array ['Top Stories']
      expect(items[0].published).to be_the_same_time_as Time.utc(2016,6,1,13,44,12) # Wed, 01 Jun 2016 13:44:12 GMT
      expect(items[0].updated).to be_nil
      expect(items[0].title).to eq "EgyptAir Flight 804: 'Black box' signals detected, French investigators say - CNN"
      expect(items[0].url).to eq 'http://news.google.com/news/url?sa=t&fd=R&ct2=us&usg=AFQjCNHH8dlIvy_Y-atjTpg1DIxyHUy5dg&clid=c3a7d30bb8a4878e06b80cf16b898331&cid=52779123879096&ei=pvFOV7DXMZCFyQPX2pKoBg&url=http://www.cnn.com/2016/06/01/africa/egyptair-possible-signal-detected/'
      expect(items[0].summary).to start_with '<table border="0"'
    end
  end

  describe 'timestamps' do
    items = TestData.feed_items('heise')
    item = items.first

    it 'should be parsed as string in ISO-8601' do
      expect(item.published).to be_a(String)
      expect(item.updated).to be_a(String)
      expect(item.published).to eq '2016-05-12T16:20:00Z'
      expect(item.updated).to eq '2016-05-12T16:20:32Z'
    end
  end

  describe 'host' do
    items = TestData.feed_items('heise')
    item = items.first

    it 'should be parsed from url for geoip' do
      expect(item.host).to be_a(String)
      expect(item.host).to eq 'www.heise.de'
    end
  end
end
