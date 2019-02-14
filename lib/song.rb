# Song data and actions
class Song
  attr_reader :id, :artist, :title

  def initialize(id, artist, title)
    @id = id
    @artist = artist
    @title = title
  end

  def with_artist_name
    artist + ' - ' + title
  end
end
