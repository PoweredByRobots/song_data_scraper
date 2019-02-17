require_relative 'lib/mysql'
require_relative 'lib/whitelister'
require_relative 'lib/acceptable_genres'

# Limit genres per song to a recognizable list
module GenrePruner
  def prune_genres
    songs.each do |id, artist, title, genres|
      update_song(id, artist, title, genres.split(', '))
    end
  end

  def to_be_pruned
    songs.count
  end

  def songs
    @songs ||= prepare_songs
  end

  def whitelist
    @whitelist ||= Whitelister.new('genre_pruner')
  end

  def db
    @db ||= Mysql.new
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

  def update_song(id, artist, title, existing_genres)
    whitelist.add(id)
    puts "\n#{artist} - #{title}..."
    genres = prune(existing_genres)
    values = "grouping = \'#{genres.join(', ')}\'"
    sleep 2
    db.update(id, values)
  end

  def prepare_songs
    db_songs = db.songs(fields)
    whitelist.check_against(db_songs)
  end
end
