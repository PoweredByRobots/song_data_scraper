#!/usr/bin/env ruby

require_relative 'scrapers/attributes'
require_relative 'scrapers/genres'
require_relative 'scrapers/year'
require_relative 'genre_pruner'
require 'io/console'
require 'pry'

include GenrePruner

def show_menu
  puts "===[ song data scraper v1.0 ]===\n\n"
  puts "1) attributes (#{@attribute_updater.backlog} remaining)"
  puts "2) genres (#{@genre_updater.backlog} remaining)"
  puts "3) year (#{@year_updater.backlog} remaining)"
  puts "4) genre pruner (#{to_be_pruned} remaining)"
  print "\n==> "
  STDIN.getch
end

def setup
  puts 'Loading...'
  @attribute_updater = AttributeUpdater.new
  @genre_updater = GenreUpdater.new
  @year_updater = YearUpdater.new
  system 'clear'
end

loop do
  system 'clear'
  setup
  
  case show_menu
  when '1'
    @attribute_updater.run
  when '2'
    @genre_updater.run
  when '3'
    @year_updater.run
  when '4'
    prune_genres
  end

  puts "\n\nPress any key to return to the main menu or 'q' to quit"
  choice = STDIN.getch
  abort('Bye!') if %w(Q q).include? choice
end
