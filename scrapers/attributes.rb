require_relative '../lib/scraper'
require_relative '../lib/tunebat_song'

# Update various song attributes with data from Tunebat
class AttributeUpdater < Scraper
  def run
    songs.each do |id, artist, title|
      song = TuneBatSong.new(id, artist, title)
      update_song(song)
    end
  end

  private

  def update_song(song)
    system 'clear'
    puts "#{song.artist} - #{song.title}"
    whitelist.add(song.id)
    data = song.attributes
    sleep 2 # mostly to see any messages
    return unless data
    db.update(song.id, data)
  end

  def criteria
    'AND happiness = 0'
  end
end
