# encoding: utf-8
require "spec_helper"
require "socket" # alpha3 spec-helper broken?, cf.: https://github.com/elastic/logstash/issues/3036#issuecomment-93948951
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/rss2"

describe LogStash::Inputs::Rss2 do

  describe "stopping" do
    let(:config) { {"url" => "localhost", "interval" => 10} }
    before do
      allow(Faraday).to receive(:get)
      allow(subject).to receive(:handle_response)
    end
    it_behaves_like "an interruptible input plugin"
  end

  describe "parsing" do
    let(:config) { {"url" => "localhost", "interval" => 10, "type" => "custom_type"} }

    it "should parse feed" do
      response = double("response")
      allow(response).to receive(:body) { TestData.feed_xml("emm_small") }

      queue = []

      rss2 = LogStash::Inputs::Rss2.new(config)
      rss2.handle_response(response, queue)
      
      expect(queue.length).to eq 2

      event = queue[0]

      expect(event.get("id")).to eq "680news-de5f959c0317ba3319b95370b7597e10"
      expect(event.get("entry_id")).to eq "680news-1804d9c60271f4a368eabf45c870aa1c"

      expect(event.get("published")).to be_a(String)
      expect(event.get("published")).to be_the_same_time_as Time.utc(2016,5,12,10,59,0)
      
      expect(event.get("title")).to eq "The Latest: Brazil opposition sees tough road for Rousseff"

      expect(event.get("categories")).to match_array [ "FightagainstFraud" ]
      expect(event.get("language")).to eq "en"

      expect(event.get("longitude")).to eq "-43.4552"
      expect(event.get("latitude")).to eq "-22.7216"

      expect(event.get("entities")).to match_array [ "Dilma Rousseff", "Humberto Costa", "Renan Calheiros", "Michel Temer", "Romero Juca", "Democratic Movement" ]

      expect(event.get("type")).to eq "custom_type"
    end
  end

  describe "default" do
    rss2 = LogStash::Inputs::Rss2.new({"url" => "localhost"})

    it "interval should be 10 minutes" do
      expect(rss2.interval).to eq 600
    end

    it "type should be 'rss'" do
      expect(rss2.type).to eq "rss"
    end

  end  

end