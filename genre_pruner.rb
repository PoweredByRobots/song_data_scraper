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
        translations << to_acceptable(genre, key, values)
      end
    end
    translations.uniq.compact.join(', ')
  end

  def to_acceptable(genre, acceptable, synonyms)
    acceptable = acceptable.downcase.to_s
    synonyms = synonyms.map(&:downcase)
    genre = genre.downcase
    return unless acceptable == genre || synonyms.include?(genre)
    acceptable
  end

  def fields
    %w(ID artist title grouping)
  end

  def update_song(id, existing_genres)
    return if existing_genres.empty?
    genres = translate(existing_genres)
    print "b: [#{existing_genres}]\n" \
          "a: [#{genres}]\n"
    values = "grouping = \'#{genres}\'"
    sleep 0.5
    puts
    db.update(id, values)
  end
end
