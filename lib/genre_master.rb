require 'bundler/setup'
require 'musicbrainz'

# Musicbrainz-specific data and actions
class GenreMaster
  attr_reader :client

  def initialize
    configure
    @client = MusicBrainz::Client.new
  end

  def lookup_genres(artist, title)
    recordings = download_data(artist, title)
    return if recordings.nil? || recordings.empty?
    puts '-> song found'
    tag_data = extract_tags(recordings)
    return unless tag_data.first
    puts '-> tags found'
    genres = extract_genres(tag_data)
    return if genres.empty?
    puts "-> genres found: #{genres}"
    genres
  end

  private

  def extract_tags(recordings)
    tag_data = []
    song_data = Hash[recordings.map { |key, value| [key, value] }]
    song_data.each do |song|
      tag_data << nested_hash_value(song, 'tags')
    end
    tag_data
  end

  def extract_genres(tag_data)
    genres = []
    tag_data.each do |tag|
      next if tag.nil?
      tag.each { |genre| genres << genre['name'] }
    end
    genres
  end

  def download_data(artist, title)
    pause
    query = { artist: artist, recording: title }
    client.recordings q: query
  rescue => error
    puts "MusicBrainz error: #{error.message}"
  end

  def nested_hash_value(obj, key)
    if obj.respond_to?(:key?) && obj.key?(key)
      obj[key]
    elsif obj.respond_to?(:each)
      r = nil
      obj.find { |*a| r = nested_hash_value(a.last, key) }
      r
    end
  end

  def pause
    sleep 10
  end

  def configure
    MusicBrainz.configure do |c|
      c.app_name = 'My Music App'
      c.app_version = '0.1'
      c.contact = 'your@email.com'
    end
  end
end
