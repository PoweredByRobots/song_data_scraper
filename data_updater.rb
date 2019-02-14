#!/usr/bin/env ruby

require_relative 'lib/mysql'
require_relative 'lib/whitelister'
require_relative 'lib/tunebat_song'
require 'pry'

def whitelist
  @whitelist ||= Whitelister.new('data_updater')
end

def db
  @db ||= Mysql.new
end

def update_song(song)
  puts "#{song.artist} - #{song.title}"
  whitelist.add(song.id)
  data = song.attributes
  return unless data
  db.update(song.id, data)
end

def fields
  %w(ID artist title)
end

def criteria
  'AND happiness = 0'
end

def prepare(songs)
  songs = db.songs(fields, criteria)
  whitelist.check_against(songs)
end

system 'clear'

songs = prepare(songs)
puts "-=[ #{songs.count} ]=- songs to go!"

songs.each do |id, artist, title|
  song = TuneBatSong.new(id, artist, title)
  update_song(song)
end
