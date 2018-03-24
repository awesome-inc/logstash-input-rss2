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

  def initialize(entry)
    @domain = canonical_domain(entry.url)
    digest = Digest::MD5.hexdigest "#{entry.published}_#{entry.title}_#{entry.url}"
    @id = "#{domain}-#{digest}"

    @entry_id = empty?(entry.entry_id) ? @id : entry.entry_id
    @url = entry.url
    @published = entry.published.iso8601.to_s unless entry.published.nil?
    @updated = entry.updated.iso8601.to_s if entry.respond_to?('updated') && !entry.updated.nil?

    @title = entry.title.encode('UTF-8') unless entry.title.nil?
    @author = trim(entry.author) || from(entry, :itunes_author)

    @summary = entry.summary.encode('UTF-8') unless empty? entry.summary
    @summary ||= from(entry, :itunes_summary) || @title

    @content = entry.content.nil? ? @summary : entry.content.encode('UTF-8')

    # attached media elements
    if entry.respond_to?('enclosure_url')
      @enclosure_url = entry.enclosure_url
      @enclosure_type = entry.enclosure_type
      @enclosure_length = entry.enclosure_length
    else
      @enclosure_url = entry.image
    end

    @comments = entry.comments

    has_cat = entry.respond_to?('categories') && !entry.categories.nil?
    @categories = entry.categories.map { |category| trim(category) }.uniq if has_cat

    @language = entry.language

    point = Point.new(entry.point)
    @longitude = point.longitude
    @latitude = point.latitude

    @entities = entry.entities.reject { |e| empty? e } unless empty? entry.entities

    @host = URI(@url).host unless empty? @url
  end

  def to_s
    lines = ''
    each do |key, value|
      lines += "#{key}: #{value.to_s}\n" unless value.nil?
    end
    lines
  end

  private

  def trim(value)
    value.nil? ? value : value.strip.chomp
  end

  def from(entry, field)
    a = field.to_s
    return nil unless entry.respond_to? a
    trim entry.send(a)
  end

  def empty?(value)
    value.nil? || value.empty?
  end

  def canonical_domain(link)
    url = Rippersnapper.parse(link)
    no_subdomain = empty?(url.subdomain) || 'www'.casecmp(url.subdomain).zero?
    return url.domain if no_subdomain
    subdomain = url.subdomain
    subdomain.slice! 'www.'
    "#{url.domain}#{subdomain}"
  end
end
