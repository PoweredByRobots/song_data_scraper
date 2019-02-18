require_relative 'lib/acceptable_genres'
require 'io/console'

# Limit genres per song to a recognizable list
class GenrePruner < Scraper
  def run
    songs.each do |id, artist, title, genres|
      whitelist.add(id)
      puts "\n#{artist} - #{title}..."
      genres = translate(genres)
      update_song(id, genres.split(', '))
    end
  end

  def translate(genres)
    return genres if genres.empty?
    translations = []
    genres.split(', ').each do |genre|
      acceptable_genres.each do |key, values|
        next unless key.to_s == genre || values.include?(genre.downcase)
        translations << key.to_s
      end
    end
    puts "Before: #{genres}\nAfter:#{translations.uniq}"
    gets
  end

  def fields
    %w(ID artist title grouping)
  end

  def preserve_genres
    special_tags + acceptable_genres
  end

  def special_tags
    %w(Christmas art01 fraser18 dhr)
  end

  def prune(genres)
    genres.map(&:downcase) & preserve_genres.map(&:downcase)
  end

  def update_song(id, existing_genres)
    genres = prune(existing_genres).join(', ')
    return if existing_genres == genres.split(', ')
    print "\nPress any key to update from\n[#{existing_genres.join(', ')}]" \
          "\nto\n[#{genres}]\n('s' to skip, q to quit) ==> "
    values = "grouping = \'#{genres}\'"
    response = STDIN.getch
    return if response == 's'
    abort if response == 'q'
    db.update(id, values)
  end
end
