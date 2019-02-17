require_relative 'mysql'
require_relative 'whitelister'

# Things a scraper needs to know and do
class Scraper
  def songs
    @songs ||= prepare_songs
  end

  def backlog
    songs.count
  end

  private

  def db
    @db ||= Mysql.new
  end

  def whitelist
    @whitelist ||= Whitelister.new(self.class.to_s)
  end

  def fields
    %w(ID artist title)
  end

  def criteria
    ''
  end

  def prepare_songs
    db_songs = db.songs(fields, criteria)
    whitelist.check_against(db_songs)
  end
end
