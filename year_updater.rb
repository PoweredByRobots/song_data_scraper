#!/usr/bin/env ruby

require_relative 'lib/whitelister'
require_relative 'lib/mysql'
require_relative 'lib/spotify'
require_relative 'lib/song'

def lookup_year(song)
  sleep 2
  matches = spotify.track_search(song.with_artist_name)
  if matches.empty?
    whitelist.add(song.id)
    puts song.with_artist_name
    return
  end
  system 'clear'
  puts "#{matches.count} matches found for #{song.with_artist_name}"
  spotify.year_chooser(matches)
end

def update_year(song)
  year = lookup_year(song)
  return unless year
  system 'clear'
  db.update(song.id, "albumyear = '#{year}'")
  puts "Setting #{song.with_artist_name} to [#{year}]"
end

def fields
  %w[ID artist title]
end

def criteria
  "AND (albumyear = \'\' " \
    "OR albumyear = \'1900\' OR albumyear = \'1700\')"
end

def whitelist
  @whitelist ||= Whitelister.new('year_updater')
end

def spotify
  @spotify ||= Spotify.new
end

def db
  @db ||= Mysql.new
end

def prepare(songs)
  songs = db.songs(fields, criteria)
  whitelist.check_against(songs)
end

system 'clear'

spotify.authenticate!
songs = prepare(songs)
songs.each do |id, artist, title|
  song = Song.new(id, artist, title)
  update_year(song)
end
