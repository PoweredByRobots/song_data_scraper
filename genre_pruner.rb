require_relative 'lib/acceptable_genres'
require 'io/console'

# Limit genres per song to a recognizable list
class GenrePruner < Scraper
  def run
    songs.each do |id, artist, title, genres|
      puts "-> #{artist} - #{title}"
      update_song(id, genres)
      whitelist.add(id)
    end
  end

  def translate(genres)
    return [] if genres.empty?
    translations = []
    genres.split(', ').each do |genre|
      acceptable_genres.each do |key, values|
        next unless key.to_s == genre.downcase || values.include?(genre.downcase)
        translations << key.to_s
      end
    end
    translations.uniq.join(', ')
  end

  def fields
    %w(ID artist title grouping)
  end

  def update_song(id, existing_genres)
    return if existing_genres.empty?
    genres = translate(existing_genres)
    print "b: [#{existing_genres}]\n" \
          "a: [#{genres}]\n" \
          "Press any key to update ('s' to skip, q to quit) ==> "
    values = "grouping = \'#{genres}\'"
    response = STDIN.getch
    return if response == 's'
    abort if response == 'q'
    db.update(id, values)
  end
end
