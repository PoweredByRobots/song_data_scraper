#!/usr/bin/env ruby

require_relative 'lib/file_handler'
require_relative 'lib/mysql'
require_relative 'lib/spotify'
require_relative 'lib/song'

def update_song(id, artist, title)
  song = Song.new(id, artist, title)
  update_year(song)
end

def lookup_year(song)
  matches = spotify.track_search(song.with_artist_name)
  if matches.empty?
    whitelist.add_line(song.id)
    puts song.with_artist_name
    sleep 2
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
  sleep 2
end

def sql_additions
  "AND (albumyear = \'\' " \
    "OR albumyear = \'1900\' OR albumyear = \'1700\')"
end

def remove_whitelisted(songs)
  whitelisted = whitelist.line_by_line
  songs.select { |song| !whitelisted.include? song.first }
end

def whitelist
  @whitelist ||= FileHandler.new('year_updater.whitelist')
end

def spotify
  @spotify ||= Spotify.new
end

def db
  @db ||= Mysql.new
end

system 'clear'

spotify.authenticate!
songs = db.songs(sql_additions)
songs = remove_whitelisted(songs)
songs.each { |id, artist, title| update_song(id, artist, title) }
