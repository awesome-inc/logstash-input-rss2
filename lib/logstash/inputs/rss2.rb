require 'logstash/inputs/base'
require 'logstash/namespace'
require 'stud/interval'
require_relative 'parser/rss_parser'

module LogStash
  module Inputs
    # Ingest events from RSS feeds using feedjira.
    class Rss2 < Base
      config_name 'rss2'
      default :codec, 'plain'
      config :url, validate: :string, required: true
      config :interval, validate: :number, default: 600
      config :type, validate: :string, default: 'rss'

      def register
        RSSParser.init
        @logger.info('Registering RSS2 Input', url: @url, interval: @interval)
      end

      def run(queue)
        @run_thread = Thread.current
        until stop?
          @logger.info? && @logger.info('Polling RSS', url: @url)
          start = Time.now
          response = RSSParser.fetch @url
          handle_response response, queue
          duration = Time.now - start
          @logger.info? && @logger.info('Command completed', command: @command, duration: duration)

          sleep_time = [0, @interval - duration].max
          if sleep_time.zero?
            @logger.warn('Execution ran longer than the interval. Skipping sleep.',
                         command: @command, duration: duration, interval: @interval)
          else
            Stud.stoppable_sleep(sleep_time) { stop? }
          end
        end
      end

      def stop
        Stud.stop!(@run_thread) if @run_thread
      end

      #private

      def handle_response(response, queue)
        unless response.success?
          @logger.warn('Could not fetch RSS feed', response: response)
          return
        end

        items = RSSParser.parse response.body
        items.each do |item|
          @codec.decode(item.content) do |event|
            item.each do |key, value|
              event.set(key, value) unless value.nil?
            end
            decorate(event)
            queue << event
          end
        end
      end
    end
  end
end
