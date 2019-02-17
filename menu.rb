#!/usr/bin/env ruby

require_relative 'scrapers/attributes'
require_relative 'scrapers/genres'
require_relative 'scrapers/year'
require_relative 'genre_pruner'
require 'io/console'
require 'pry'

def show_menu
  puts "===[ song data scraper v1.0 ]===\n\n"
  puts "1) scrape attributes [#{@attribute_updater.backlog}]"
  puts "2) scrape genres [#{@genre_updater.backlog}]"
  puts "3) scrape years [#{@year_updater.backlog}]"
  puts "4) clean genre data [#{@genre_pruner.backlog}]"
  print "\n==> "
  STDIN.getch
end

def setup
  puts 'Loading...'
  @attribute_updater = AttributeUpdater.new
  @genre_updater = GenreUpdater.new
  @year_updater = YearUpdater.new
  @genre_pruner = GenrePruner.new
  system 'clear'
end

loop do
  system 'clear'
  setup
  
  case show_menu
  when '1'
    puts "Updating attributes for #{@attribute_updater.backlog} songs..."
    @attribute_updater.run
  when '2'
    puts "Updating genres for #{@genre_updater.backlog} songs..."
    @genre_updater.run
  when '3'
    puts "Updating release dates for #{@year_updater.backlog} songs..."
    @year_updater.run
  when '4'
    puts "Pruning genres for #{@genre_pruner.backlog} songs..."
    @genre_pruner.run
  end

  puts "\n\nPress any key to return to the main menu or 'q' to quit"
  choice = STDIN.getch
  abort('Bye!') if %w(Q q).include? choice
end
