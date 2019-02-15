require_relative '../genre_master'
require_relative '../mysql'
require_relative '../whitelister'

# Update genre info with data from musicbrainz
class GenreUpdater
  def run
    songs.each do |id, artist, title, genres|
      update_song(id, artist, title, genres.split(', '))
    end
  end

  def backlog
    songs.count
  end

  private

  def songs
    @songs ||= prepare_songs
  end

  def whitelist
    @whitelist ||= Whitelister.new('genre_updater')
  end

  def genre_master
    @genre_master ||= GenreMaster.new
  end

  def db
    @db ||= Mysql.new
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

  def prepare_songs
    db_songs = db.songs(fields)
    whitelist.check_against(db_songs)
  end
end
