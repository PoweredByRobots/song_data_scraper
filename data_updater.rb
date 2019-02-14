#!/usr/bin/env ruby

require_relative 'lib/mysql'
require_relative 'lib/file_handler'
require_relative 'lib/tunebat_song'
require 'pry'

def whitelist
  @whitelist ||= FileHandler.new('data_updater.whitelist')
end

def db
  @db ||= Mysql.new
end

def remove_whitelisted(songs)
  whitelisted = whitelist.line_by_line
  songs.select { |song| !whitelisted.include? song.first }
end

def update_song(song)
  puts "#{song.artist} - #{song.title}"
  data = song.attributes
  return unless data
  db.update(song.id, data)
  whitelist.add_line(song.id)
end

def sql_additions
  'AND happiness = 0'
end

system 'clear'

songs = db.songs(sql_additions)
songs = remove_whitelisted(songs)
puts "-=[ #{songs.count} ]=- songs to go!"

songs.each do |id, artist, title|
  song = TuneBatSong.new(id, artist, title)
  update_song(song)
end
