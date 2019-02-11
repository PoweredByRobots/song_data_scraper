#!/usr/bin/env ruby

require_relative 'lib/mysql'
require_relative 'lib/filehandler'
require 'nokogiri'
require 'open-uri'
require 'pry'

include Mysql

def filename
  'processed.songs'
end

def file
  @file ||= FileHandler.new(filename)
end

def remove_already_processed(songs)
  already_processed = file.processed_ids
  songs.select { |song| !already_processed.include? song.first }
end

def update_song(id, artist, title)
  puts "#{artist} - #{title}"
  update_data(id, artist, title)
  file.add_to_list(id)
end

def xpath(doc, name)
  doc.xpath(paths[name.to_sym]).children.to_s
end

def webdoc(path)
  base_url = 'https://tunebat.com'
  Nokogiri::HTML(open(base_url + path))
rescue => error
  puts error.message
end

def lookup_data(artist, title)
  path = '/Search?q=' + (artist + ' ' + title).tr(' ', '+')
  doc = webdoc(sanitize(path))
  path_to_link = '/html/body/div[1]/div[1]/div/' \
                 'div/div[2]/div[2]/div[1]/div/a'
  link_data = doc.xpath(path_to_link).first
  return unless link_data
  link = link_data.attributes['href'].value
  extract_data_from_paths(webdoc(link))
end

def extract_data_from_paths(doc)
  data = {}
  paths.keys.each { |a| data[a] = xpath(doc, a) }
  data
end

def paths
  { happiness: '/html/body/div[1]/div[2]/div/div/div[1]/div/div/div/div[3]/div/div[1]/table/tbody/tr[2]/td[3]',
    danceability: '/html/body/div[1]/div[2]/div/div/div[1]/div/div/div/div[3]/div/div[1]/table/tbody/tr[2]/td[2]',
    energy: '/html/body/div[1]/div[2]/div/div/div[1]/div/div/div/div[3]/div/div[1]/table/tbody/tr[2]/td[1]',
    accousticness: '/html/body/div[1]/div[2]/div/div/div[1]/div/div/div/div[3]/div/div[1]/table/tbody/tr[2]/td[5]', 
    instrumentalness: '/html/body/div[1]/div[2]/div/div/div[1]/div/div/div/div[3]/div/div[1]/table/tbody/tr[2]/td[6]', 
    liveness: '/html/body/div[1]/div[2]/div/div/div[1]/div/div/div/div[3]/div/div[1]/table/tbody/tr[2]/td[7]',
    speechiness: '/html/body/div[1]/div[2]/div/div/div[1]/div/div/div/div[3]/div/div[1]/table/tbody/tr[2]/td[8]',
    album: '/html/body/div[1]/div[2]/div/div/div[1]/div/div/div/div[2]/table/tbody/tr[2]/td[2]' }
end

def update_data(id, artist, title)
  @backlog -= 1
  pause
  data = lookup_data(artist, title)
  return unless data
  data[:album] = escape_apostrophes(data[:album])
  attributes = ''
  paths.keys.each { |a| attributes += "#{a} = '#{data[a.to_sym]}', " }
  puts data.to_s
  update_db(id, attributes[0..-3])
end

def escape_apostrophes(string)
  string.gsub("'", "\\\\'")
end

def sanitize(string)
  string.gsub(/[\u0080-\u00ff]/, '')
end

def pause
  sleep 10
end

system 'clear'
songs = remove_already_processed(songlist('AND happiness = 0'))
@backlog = songs.count
puts "-==[#{@backlog}]==- songs to go!"
songs.each { |id, artist, title| update_song(id, artist, title) }
