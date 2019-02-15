#!/usr/bin/env ruby

require_relative 'lib/scrapers/attributes'
require_relative 'lib/scrapers/genres'
require_relative 'lib/scrapers/year'
require 'io/console'

def show_menu
  puts "===[ song data scraper v1.0 ]===\n\n"
  puts "1) attributes (#{@attribute_updater.backlog} remaining)"
  puts "2) genres (#{@genre_updater.backlog} remaining)"
  puts "3) year (#{@year_updater.backlog} remaining)"
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
  end

  puts "\n\nPress any key to return to the main menu or 'q' to quit"
  choice = STDIN.getch
  abort('Bye!') if %w(Q q).include? choice
end
