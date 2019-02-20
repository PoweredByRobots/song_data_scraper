require_relative '../lib/scraper'
require_relative '../lib/genre_master'
require_relative '../lib/genre_pruner'

# Update genre info with data from musicbrainz
class GenreUpdater < Scraper
  include GenrePruner

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

  def update_song(id, artist, title, existing_genres)
    additional_genres = genre_master.lookup_genres(artist, title) || []
    genres = prune(additional_genres + existing_genres)
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
