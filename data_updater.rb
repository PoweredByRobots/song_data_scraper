#!/usr/bin/env ruby

require_relative 'lib/mysql'
require_relative 'lib/filehandler'
require_relative 'lib/song'
require 'pry'

def filename
  'processed.songs'
end

def file
  @file ||= FileHandler.new(filename)
end

def database
  @database ||= Mysql.new
end

def remove_already_processed(songs)
  already_processed = file.processed_ids
  songs.select { |song| !already_processed.include? song.first }
end

def update_song(song)
  puts "#{song.artist} - #{song.title}"
  data = song.attributes
  return unless data
  database.update(song.id, data)
  file.add_to_list(song.id)
end

system 'clear'

songs = remove_already_processed(database.songs('AND happiness = 0'))
backlog = songs.count
puts "-==[#{backlog}]==- songs to go!"

songs.each do |id, artist, title|
  song = Song.new(id, artist, title)
  update_song(song)
  backlog -= 1
end
