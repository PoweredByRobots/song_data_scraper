require_relative '../lib/scraper'
require_relative '../lib/genre_master'

# Update genre info with data from musicbrainz
class GenreUpdater < Scraper
  def run
    songs.each do |id, artist, title, genres|
      puts "\n#{artist} - #{title}..."
      update_song(id, artist, title, genres.split(', '))
      whitelist.add(id)
    end
  end

  private

  def genre_master
    @genre_master ||= GenreMaster.new
  end

  def fields
    %w(ID artist title grouping)
  end

  def translate(genres)
    return [] if genres.empty?
    translations = []
    genres.each do |genre|
      acceptable_genres.each do |key, values|
        translations << to_acceptable(genre, key, values)
      end
    end
    translations.uniq.compact
  end

  def to_acceptable(genre, acceptable, synonyms)
    acceptable = acceptable.downcase.to_s
    synonyms = synonyms.map(&:downcase)
    genre = genre.downcase
    return unless acceptable == genre || synonyms.include?(genre)
    acceptable
  end

  def update_song(id, artist, title, existing_genres)
    additional_genres = genre_master.lookup_genres(artist, title) || []
    genres = translate(additional_genres + existing_genres)
    puts "[#{existing_genres}] -> [#{genres}]"
    return if genres == existing_genres
    values = "grouping = \'#{genres.join(', ')}\'"
    pause
    db.update(id, values)
  end

  def pause
    0.5
  end
end
