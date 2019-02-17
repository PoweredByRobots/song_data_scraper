require_relative '../lib/scraper'
require_relative '../lib/genre_master'

# Update genre info with data from musicbrainz
class GenreUpdater < Scraper
  def run
    songs.each do |id, artist, title, genres|
      update_song(id, artist, title, genres.split(', '))
    end
  end

  private

  def genre_master
    @genre_master ||= GenreMaster.new
  end

  def fields
    %w(ID artist title grouping)
  end

  def preserve_genres
    %w(Christmas art01 fraser18 dhr)
  end

  def sterilize(genres)
    genres.map(&:downcase) & preserve_genres.map(&:downcase)
  end

  def update_song(id, artist, title, existing_genres)
    whitelist.add(id)
    puts "\n#{artist} - #{title}..."
    genres = genre_master.lookup_genres(artist, title) || existing_genres
    return if genres == existing_genres
    genres = sterilize(genres)
    values = "grouping = \'#{genres.join(', ')}\'"
    db.update(id, values)
  end
end
