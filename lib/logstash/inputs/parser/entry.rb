require 'digest/md5'
require 'rippersnapper'

require_relative 'entity'
require_relative 'point'

# An RSS Feed entry
class Entry
  include Feedjira::FeedEntryUtilities

  attr_reader :id
  attr_reader :entry_id
  attr_reader :url
  attr_reader :published
  attr_reader :updated
  attr_reader :title
  attr_reader :author
  attr_reader :summary
  attr_reader :comments

  attr_reader :categories

  # content
  attr_reader :content
  attr_reader :enclosure_url
  attr_reader :enclosure_type
  attr_reader :enclosure_length

  # rss extensions (EMM)
  attr_reader :language
  attr_reader :domain
  attr_reader :longitude
  attr_reader :latitude
  attr_reader :entities

  # host for geoip
  attr_reader :host

  def self.canonical_domain(link)
    url = Rippersnapper.parse(link)
    if (url.subdomain.nil? || url.subdomain.empty? || "www".casecmp(url.subdomain) == 0)
      return url.domain
    else
      subdomain = url.subdomain
      subdomain.slice! 'www.'
      return "#{url.domain}#{subdomain}"
    end
  end

  def self.trim(val)
    val.nil? ? val : val.strip.chomp
  end

  def initialize(e)
    # feedjira uses entry_id ||= url
    # but we don't want to fallback on urls as id
    #@id = e.id
    @domain = self.class.canonical_domain(e.url)
    digest = Digest::MD5.hexdigest("#{e.published}_#{e.title}_#{e.url}")
    @id = "#{domain}-#{digest}"

    @entry_id = e.entry_id.nil? || e.entry_id.empty? ? id : e.entry_id
    @url = e.url
    @published = e.published.iso8601.to_s unless e.published.nil?

    @updated = e.updated.iso8601.to_s if e.respond_to?('updated') && !e.updated.nil?

    @title = e.title.encode('UTF-8') unless e.title.nil?
    @author = self.class.trim(e.author)
    if @author.nil? e.respond_to?('itunes_author')
      @author = self.class.trim(e.itunes_author)
    end

    @summary = e.summary.encode('UTF-8') unless e.summary.nil? || e.summary.empty?
    if @summary.nil? && e.respond_to?('itunes_summary')
      @summary = e.itunes_summary
    end
    @summary = @title if @summary.nil?

    @content = (e.content.nil? ? @summary : e.content.encode('UTF-8'))

    # attached media elements
    if e.respond_to?('enclosure_url')
      @enclosure_url = e.enclosure_url
      @enclosure_type = e.enclosure_type
      @enclosure_length = e.enclosure_length
    else
      @enclosure_url = e.image
    end

    @comments = e.comments

    if e.respond_to?('categories') && !e.categories.nil?
      @categories = e.categories.map { |category| self.class.trim(category) }.uniq
    end

    @language = e.language

    point = Point.new(e.point)
    @longitude = point.longitude
    @latitude = point.latitude

    unless e.entities.nil? || e.entities.empty?
      @entities = e.entities.reject { |e| e.nil? || e.empty? }
    end

    @host = URI(@url).host unless @url.nil? || @url.empty?
  end

  def to_s
    lines = ''
    each do |key, value|
      lines += "#{key}: #{value.to_s}\n" unless value.nil?
    end
    lines
  end
end
