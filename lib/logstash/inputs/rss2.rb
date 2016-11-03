# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"

require_relative "parser/rss_parser"

# Ingest events from RSS feeds using feedjira.
class LogStash::Inputs::Rss2 < LogStash::Inputs::Base
  config_name "rss2"

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, "plain"

  # RSS/Atom feed URL
  config :url, :validate => :string, :required => true

  # Interval to run the command. Value is in seconds. default is 10 minutes
  config :interval, :validate => :number, :default => 600

  # event type, defaults to "rss"
  config :type, :validate => :string, :default => "rss"

  public
  def register
    RSSParser.init
    @logger.info("Registering RSS2 Input", :url => @url, :interval => @interval)
  end

  public
  def run(queue)
    @run_thread = Thread.current
    while !stop?
      start = Time.now
      @logger.info? && @logger.info("Polling RSS", :url => @url)

      # Pull down the RSS feed using FTW so we can make use of future cache functions
      response = Faraday.get @url
      handle_response(response, queue)

      duration = Time.now - start
      @logger.info? && @logger.info("Command completed", :command => @command,
                                    :duration => duration)

      # Sleep for the remainder of the interval, or 0 if the duration ran
      # longer than the interval.
      sleeptime = [0, @interval - duration].max
      if sleeptime == 0
        @logger.warn("Execution ran longer than the interval. Skipping sleep.",
                     :command => @command, :duration => duration,
                     :interval => @interval)
      else
        Stud.stoppable_sleep(sleeptime) { stop? }
      end
    end # loop
  end

  def handle_response(response, queue)
    body = response.body
    # @logger.debug("Body", :body => body)
    
    # Parse the RSS feed
    items = RSSParser.parse body
    items.each do |item|
      @codec.decode(item.content) do |event|
        event.set("type", @type)

        item.each do |key,value|
          # skip fields:
          #  - content already goes into message, so could also skip
          #  - nil fields
          event.set(key, value) unless value.nil?
        end

        decorate(event)
        
        queue << event
      end
    end
  end

  def stop
    Stud.stop!(@run_thread) if @run_thread
  end
end
